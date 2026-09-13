import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/core/backup/backup_repository.dart';
import 'package:learning_bird/core/database/app_database.dart';

void main() {
  late AppDatabase database;
  late BackupRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = BackupRepository(database);
  });

  tearDown(() => database.close());

  test('全量备份可恢复关联数据和设置', () async {
    await _seedCompleteDataset(database);
    final backup = await repository.createBackup();
    final summary = repository.inspectBackup(backup);
    expect(summary.schemaVersion, 3);
    expect(summary.totalRecords, 12);

    await database.customStatement('DELETE FROM review_records');
    await database.customStatement("UPDATE words SET meaning = '已修改'");
    await database.putSetting('theme_mode', 'light');

    final restored = await repository.restoreBackup(backup);

    expect(restored.totalRecords, 12);
    expect((await database.select(database.wordBooks).getSingle()).name, '核心词');
    expect((await database.select(database.words).getSingle()).meaning, '坚持');
    expect(await database.select(database.reviewRecords).get(), hasLength(1));
    expect((await database.select(database.plans).getSingle()).title, '数学真题');
    expect(
      (await database.select(database.pomodoroSessions).getSingle())
          .actualDurationMs,
      const Duration(minutes: 25).inMilliseconds,
    );
    expect(await database.readSetting('theme_mode'), 'dark');
    expect(await database.ping(), isTrue);
  });

  test('被修改的备份会在覆盖数据前被拒绝', () async {
    await database.putSetting('keep', 'current');
    final backup = await repository.createBackup();
    final document = jsonDecode(backup) as Map<String, Object?>;
    final data = document['data']! as Map<String, Object?>;
    final settings = data['app_settings']! as List<Object?>;
    (settings.single! as Map<String, Object?>)['value'] = 'tampered';
    final tampered = jsonEncode(document);

    expect(
      () => repository.restoreBackup(tampered),
      throwsA(isA<BackupValidationException>()),
    );
    expect(await database.readSetting('keep'), 'current');
  });

  test('不兼容的数据库版本会被明确拒绝', () async {
    final backup = await repository.createBackup();
    final document = jsonDecode(backup) as Map<String, Object?>;
    document['schemaVersion'] = 99;

    expect(
      () => repository.inspectBackup(jsonEncode(document)),
      throwsA(
        isA<BackupValidationException>().having(
          (error) => error.message,
          'message',
          contains('不兼容'),
        ),
      ),
    );
  });

  test('新增关联应用字段后仍可恢复版本 1 备份', () async {
    await _seedCompleteDataset(database);
    final backup = await repository.createBackup();
    final document = jsonDecode(backup) as Map<String, Object?>;
    document['schemaVersion'] = 1;
    final data = document['data']! as Map<String, Object?>;
    data.remove('course_schedules');
    final plans = data['plans']! as List<Object?>;
    for (final raw in plans) {
      final plan = raw! as Map<String, Object?>;
      plan.remove('linked_app_package');
      plan.remove('linked_app_name');
      plan.remove('course_schedule_id');
    }
    document['checksum'] = sha256
        .convert(utf8.encode(jsonEncode(data)))
        .toString();

    final restored = await repository.restoreBackup(jsonEncode(document));

    expect(restored.schemaVersion, 1);
    expect((await database.select(database.plans).getSingle()).title, '数学真题');
  });
}

Future<void> _seedCompleteDataset(AppDatabase database) async {
  final now = DateTime.utc(2026, 8, 28, 8);
  final bookId = await database
      .into(database.wordBooks)
      .insert(WordBooksCompanion.insert(name: '核心词'));
  final wordId = await database
      .into(database.words)
      .insert(
        WordsCompanion.insert(
          word: 'persist',
          normalizedWord: 'persist',
          meaning: '坚持',
        ),
      );
  final itemId = await database
      .into(database.wordBookItems)
      .insert(
        WordBookItemsCompanion.insert(wordBookId: bookId, wordId: wordId),
      );
  await database
      .into(database.reviewSchedules)
      .insert(
        ReviewSchedulesCompanion.insert(
          wordBookItemId: Value(itemId),
          dueAt: now,
        ),
      );
  await database
      .into(database.reviewRecords)
      .insert(
        ReviewRecordsCompanion.insert(
          wordBookItemId: itemId,
          rating: 'good',
          reviewedAt: now,
          nextDueAt: now.add(const Duration(days: 3)),
        ),
      );
  final categoryId = await database
      .into(database.categories)
      .insert(CategoriesCompanion.insert(name: '数学'));
  final planId = await database
      .into(database.plans)
      .insert(
        PlansCompanion.insert(
          title: '数学真题',
          startsAt: now,
          categoryId: Value(categoryId),
          wordBookId: Value(bookId),
        ),
      );
  await database
      .into(database.reminders)
      .insert(
        RemindersCompanion.insert(
          planId: planId,
          triggerAt: now.subtract(const Duration(minutes: 10)),
        ),
      );
  await database
      .into(database.pomodoroSessions)
      .insert(
        PomodoroSessionsCompanion.insert(
          planId: Value(planId),
          startedAt: now,
          targetEndAt: now.add(const Duration(minutes: 25)),
          status: const Value('completed'),
          completedAt: Value(now.add(const Duration(minutes: 25))),
          actualDurationMs: Value(const Duration(minutes: 25).inMilliseconds),
        ),
      );
  final importId = await database
      .into(database.importRecords)
      .insert(
        ImportRecordsCompanion.insert(
          batchUuid: 'backup-batch',
          fileName: 'words.csv',
          sourceType: 'csv',
          targetWordBookId: bookId,
          startedAt: now,
        ),
      );
  await database
      .into(database.importErrors)
      .insert(
        ImportErrorsCompanion.insert(
          importRecordId: importId,
          sourceRow: 2,
          errorCode: 'sample',
          message: '示例错误',
        ),
      );
  await database.putSetting('theme_mode', 'dark');
}
