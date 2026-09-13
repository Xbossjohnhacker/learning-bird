import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class WordBooks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get description => text().nullable()();
  IntColumn get dailyNewLimit => integer().withDefault(const Constant(20))();
  IntColumn get dailyReviewLimit =>
      integer().withDefault(const Constant(100))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

class Words extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get word => text().withLength(min: 1, max: 120)();
  TextColumn get normalizedWord => text().unique()();
  TextColumn get meaning => text()();
  TextColumn get phonetic => text().nullable()();
  TextColumn get example => text().nullable()();
  TextColumn get exampleTranslation => text().nullable()();
  TextColumn get phrase => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get tags => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
}

class WordBookItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get wordBookId =>
      integer().references(WordBooks, #id, onDelete: KeyAction.cascade)();
  IntColumn get wordId =>
      integer().references(Words, #id, onDelete: KeyAction.cascade)();
  TextColumn get learningState => text().withDefault(const Constant('new'))();
  DateTimeColumn get addedAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get suspendedAt => dateTime().nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {wordBookId, wordId},
  ];
}

class ReviewSchedules extends Table {
  IntColumn get wordBookItemId =>
      integer().references(WordBookItems, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get dueAt => dateTime()();
  IntColumn get intervalDays => integer().withDefault(const Constant(0))();
  IntColumn get streak => integer().withDefault(const Constant(0))();
  IntColumn get lapseCount => integer().withDefault(const Constant(0))();
  TextColumn get lastRating => text().nullable()();
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {wordBookItemId};
}

class ReviewRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get wordBookItemId =>
      integer().references(WordBookItems, #id, onDelete: KeyAction.cascade)();
  TextColumn get rating => text()();
  DateTimeColumn get reviewedAt => dateTime()();
  DateTimeColumn get previousDueAt => dateTime().nullable()();
  DateTimeColumn get nextDueAt => dateTime()();
  IntColumn get durationMs => integer().nullable()();
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 40)();
  IntColumn get colorValue => integer().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
}

class CourseSchedules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get sourceType => text().unique()();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
}

class Plans extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get templateId => integer().nullable()();
  IntColumn get categoryId => integer().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get wordBookId => integer().nullable().references(
    WordBooks,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get courseScheduleId => integer().nullable().references(
    CourseSchedules,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get linkedAppPackage => text().nullable()();
  TextColumn get linkedAppName => text().nullable()();
  TextColumn get title => text().withLength(min: 1, max: 120)();
  TextColumn get note => text().nullable()();
  DateTimeColumn get startsAt => dateTime()();
  IntColumn get estimatedMinutes => integer().withDefault(const Constant(25))();
  IntColumn get priority => integer().withDefault(const Constant(1))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get repeatRule => text().nullable()();
  TextColumn get instanceDate => text().nullable()();
  IntColumn get targetPomodoros => integer().withDefault(const Constant(1))();
  IntColumn get actualMinutes => integer().withDefault(const Constant(0))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get planId =>
      integer().references(Plans, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get triggerAt => dateTime()();
  IntColumn get offsetMinutes => integer().withDefault(const Constant(0))();
  IntColumn get platformNotificationId => integer().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get snoozeCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
}

class PomodoroSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get planId => integer().nullable().references(
    Plans,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get phase => text().withDefault(const Constant('focus'))();
  TextColumn get status => text().withDefault(const Constant('running'))();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get targetEndAt => dateTime()();
  DateTimeColumn get pausedAt => dateTime().nullable()();
  IntColumn get pausedTotalMs => integer().withDefault(const Constant(0))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get actualDurationMs => integer().withDefault(const Constant(0))();
}

class ImportRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get batchUuid => text().unique()();
  TextColumn get fileName => text()();
  TextColumn get sourceFingerprint => text().nullable()();
  TextColumn get sourceType => text()();
  IntColumn get targetWordBookId =>
      integer().references(WordBooks, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  IntColumn get totalRows => integer().withDefault(const Constant(0))();
  IntColumn get successCount => integer().withDefault(const Constant(0))();
  IntColumn get skippedCount => integer().withDefault(const Constant(0))();
  IntColumn get failedCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('running'))();
}

class ImportErrors extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get importRecordId =>
      integer().references(ImportRecords, #id, onDelete: KeyAction.cascade)();
  IntColumn get sourceRow => integer()();
  TextColumn get errorCode => text()();
  TextColumn get message => text()();
  TextColumn get rawData => text().nullable()();
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    WordBooks,
    Words,
    WordBookItems,
    ReviewSchedules,
    ReviewRecords,
    Categories,
    CourseSchedules,
    Plans,
    Reminders,
    PomodoroSessions,
    ImportRecords,
    ImportErrors,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _createIndexes();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(plans, plans.linkedAppPackage);
        await migrator.addColumn(plans, plans.linkedAppName);
      }
      if (from < 3) {
        await migrator.createTable(courseSchedules);
        await migrator.addColumn(plans, plans.courseScheduleId);
        final legacyCourses = await (select(
          plans,
        )..where((plan) => plan.note.like('[课表导入]%'))).get();
        if (legacyCourses.isNotEmpty) {
          final scheduleId = await into(courseSchedules).insert(
            CourseSchedulesCompanion.insert(
              name: '历史导入课表',
              sourceType: 'legacy',
            ),
          );
          await (update(plans)..where(
                (plan) => plan.id.isIn(legacyCourses.map((item) => item.id)),
              ))
              .write(PlansCompanion(courseScheduleId: Value(scheduleId)));
        }
        await customStatement(
          'CREATE INDEX idx_plans_schedule '
          'ON plans(course_schedule_id, starts_at)',
        );
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _createIndexes() async {
    const statements = [
      'CREATE INDEX idx_word_books_active '
          'ON word_books(is_archived, deleted_at)',
      'CREATE INDEX idx_book_state '
          'ON word_book_items(word_book_id, learning_state)',
      'CREATE INDEX idx_review_due '
          'ON review_schedules(due_at, word_book_item_id)',
      'CREATE INDEX idx_review_history '
          'ON review_records(word_book_item_id, reviewed_at DESC)',
      'CREATE INDEX idx_plans_day ON plans(starts_at, status)',
      'CREATE INDEX idx_plans_schedule '
          'ON plans(course_schedule_id, starts_at)',
      'CREATE INDEX idx_reminders_pending ON reminders(status, trigger_at)',
      'CREATE INDEX idx_pomodoro_day '
          'ON pomodoro_sessions(started_at, status)',
      'CREATE INDEX idx_import_target '
          'ON import_records(target_word_book_id, started_at DESC)',
    ];

    for (final statement in statements) {
      await customStatement(statement);
    }
  }

  Future<bool> ping() async {
    final row = await customSelect('SELECT 1 AS value').getSingle();
    return row.read<int>('value') == 1;
  }

  Future<void> putSetting(String key, String value) {
    return into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(
        key: key,
        value: value,
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<String?> readSetting(String key) async {
    final query = select(appSettings)..where((row) => row.key.equals(key));
    return (await query.getSingleOrNull())?.value;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(path.join(directory.path, 'learning_bird.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
