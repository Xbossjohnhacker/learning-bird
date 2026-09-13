import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';

class BackupSummary {
  const BackupSummary({
    required this.exportedAt,
    required this.schemaVersion,
    required this.recordsByTable,
  });

  final DateTime exportedAt;
  final int schemaVersion;
  final Map<String, int> recordsByTable;

  int get totalRecords =>
      recordsByTable.values.fold(0, (sum, value) => sum + value);
}

class BackupValidationException implements Exception {
  const BackupValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class BackupRepository {
  BackupRepository(this.database);

  final AppDatabase database;

  static const _format = 'learning_bird_backup';
  static const _backupVersion = 1;

  static const _tableOrder = [
    'word_books',
    'words',
    'categories',
    'course_schedules',
    'plans',
    'word_book_items',
    'review_schedules',
    'review_records',
    'reminders',
    'pomodoro_sessions',
    'import_records',
    'import_errors',
    'app_settings',
  ];

  Future<String> createBackup() async {
    final data = <String, List<Map<String, Object?>>>{};
    await database.transaction(() async {
      for (final table in _tableOrder) {
        final rows = await database.customSelect('SELECT * FROM $table').get();
        data[table] = rows
            .map((row) => Map<String, Object?>.from(row.data))
            .toList(growable: false);
      }
    });
    final checksum = sha256.convert(utf8.encode(jsonEncode(data))).toString();
    return const JsonEncoder.withIndent('  ').convert({
      'format': _format,
      'backupVersion': _backupVersion,
      'schemaVersion': database.schemaVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'checksum': checksum,
      'data': data,
    });
  }

  BackupSummary inspectBackup(String source) {
    final document = _decodeAndValidate(source);
    final data = document['data']! as Map<String, Object?>;
    return BackupSummary(
      exportedAt: DateTime.parse(document['exportedAt']! as String).toLocal(),
      schemaVersion: document['schemaVersion']! as int,
      recordsByTable: {
        for (final table in _tableOrder)
          table: (data[table]! as List<Object?>).length,
      },
    );
  }

  Future<BackupSummary> restoreBackup(String source) async {
    final document = _decodeAndValidate(source);
    final data = document['data']! as Map<String, Object?>;
    final columnsByTable = <String, Set<String>>{};
    for (final table in _tableOrder) {
      final columns = await database
          .customSelect('PRAGMA table_info($table)')
          .get();
      columnsByTable[table] = {
        for (final row in columns) row.read<String>('name'),
      };
    }

    await database.transaction(() async {
      for (final table in _tableOrder.reversed) {
        await database.customStatement('DELETE FROM $table');
      }
      for (final table in _tableOrder) {
        final rows = data[table]! as List<Object?>;
        for (final rawRow in rows) {
          final row = Map<String, Object?>.from(rawRow! as Map);
          final unknown = row.keys.toSet().difference(columnsByTable[table]!);
          if (unknown.isNotEmpty) {
            throw BackupValidationException(
              '备份中的 $table 包含未知字段：${unknown.join(', ')}',
            );
          }
          if (row.isEmpty) continue;
          final columns = row.keys.toList(growable: false);
          final placeholders = List.filled(columns.length, '?').join(', ');
          final quotedColumns = columns.map((column) => '"$column"').join(', ');
          await database.customStatement(
            'INSERT INTO $table ($quotedColumns) VALUES ($placeholders)',
            columns.map((column) => row[column]).toList(growable: false),
          );
        }
      }
      if ((document['schemaVersion']! as int) < 3) {
        final legacyCourses = await (database.select(
          database.plans,
        )..where((plan) => plan.note.like('[课表导入]%'))).get();
        if (legacyCourses.isNotEmpty) {
          final scheduleId = await database
              .into(database.courseSchedules)
              .insert(
                CourseSchedulesCompanion.insert(
                  name: '历史导入课表',
                  sourceType: 'legacy',
                ),
              );
          await (database.update(database.plans)..where(
                (plan) => plan.id.isIn(legacyCourses.map((item) => item.id)),
              ))
              .write(PlansCompanion(courseScheduleId: Value(scheduleId)));
        }
      }
    });
    database.notifyUpdates({
      for (final table in database.allTables) TableUpdate.onTable(table),
    });
    return inspectBackup(source);
  }

  Map<String, Object?> _decodeAndValidate(String source) {
    Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      throw const BackupValidationException('文件不是有效的 JSON 备份。');
    }
    if (decoded is! Map) {
      throw const BackupValidationException('备份文件结构无效。');
    }
    final document = Map<String, Object?>.from(decoded);
    if (document['format'] != _format ||
        document['backupVersion'] != _backupVersion) {
      throw const BackupValidationException('这不是受支持的 Learning Bird 备份。');
    }
    final rawSchemaVersion = document['schemaVersion'];
    if (rawSchemaVersion is! int ||
        rawSchemaVersion < 1 ||
        rawSchemaVersion > database.schemaVersion) {
      throw BackupValidationException(
        '备份数据库版本 $rawSchemaVersion 与当前版本 '
        '${database.schemaVersion} 不兼容。',
      );
    }
    final backupSchemaVersion = rawSchemaVersion;
    final exportedAt = document['exportedAt'];
    if (exportedAt is! String || DateTime.tryParse(exportedAt) == null) {
      throw const BackupValidationException('备份时间无效。');
    }
    final rawData = document['data'];
    if (rawData is! Map) {
      throw const BackupValidationException('备份缺少数据内容。');
    }
    final data = Map<String, Object?>.from(rawData);
    final expectedTables = backupSchemaVersion < 3
        ? _tableOrder.where((table) => table != 'course_schedules').toSet()
        : _tableOrder.toSet();
    final actualTables = data.keys.toSet();
    if (actualTables.length != expectedTables.length ||
        actualTables.difference(expectedTables).isNotEmpty ||
        expectedTables.difference(actualTables).isNotEmpty ||
        expectedTables.any((table) => data[table] is! List)) {
      throw const BackupValidationException('备份中的数据表不完整或无法识别。');
    }
    for (final table in expectedTables) {
      for (final row in data[table]! as List<Object?>) {
        if (row is! Map) {
          throw BackupValidationException('$table 中存在无效记录。');
        }
      }
    }
    final checksum = document['checksum'];
    final actual = sha256.convert(utf8.encode(jsonEncode(data))).toString();
    if (checksum is! String || checksum != actual) {
      throw const BackupValidationException('备份校验失败，文件可能已损坏或被修改。');
    }
    if (backupSchemaVersion < 3) {
      data['course_schedules'] = <Object?>[];
    }
    document['data'] = data;
    return document;
  }
}
