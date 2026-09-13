// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WordBooksTable extends WordBooks
    with TableInfo<$WordBooksTable, WordBook> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordBooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dailyNewLimitMeta = const VerificationMeta(
    'dailyNewLimit',
  );
  @override
  late final GeneratedColumn<int> dailyNewLimit = GeneratedColumn<int>(
    'daily_new_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(20),
  );
  static const VerificationMeta _dailyReviewLimitMeta = const VerificationMeta(
    'dailyReviewLimit',
  );
  @override
  late final GeneratedColumn<int> dailyReviewLimit = GeneratedColumn<int>(
    'daily_review_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    dailyNewLimit,
    dailyReviewLimit,
    isArchived,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_books';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordBook> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('daily_new_limit')) {
      context.handle(
        _dailyNewLimitMeta,
        dailyNewLimit.isAcceptableOrUnknown(
          data['daily_new_limit']!,
          _dailyNewLimitMeta,
        ),
      );
    }
    if (data.containsKey('daily_review_limit')) {
      context.handle(
        _dailyReviewLimitMeta,
        dailyReviewLimit.isAcceptableOrUnknown(
          data['daily_review_limit']!,
          _dailyReviewLimitMeta,
        ),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WordBook map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordBook(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      dailyNewLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_new_limit'],
      )!,
      dailyReviewLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_review_limit'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $WordBooksTable createAlias(String alias) {
    return $WordBooksTable(attachedDatabase, alias);
  }
}

class WordBook extends DataClass implements Insertable<WordBook> {
  final int id;
  final String name;
  final String? description;
  final int dailyNewLimit;
  final int dailyReviewLimit;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const WordBook({
    required this.id,
    required this.name,
    this.description,
    required this.dailyNewLimit,
    required this.dailyReviewLimit,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['daily_new_limit'] = Variable<int>(dailyNewLimit);
    map['daily_review_limit'] = Variable<int>(dailyReviewLimit);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  WordBooksCompanion toCompanion(bool nullToAbsent) {
    return WordBooksCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      dailyNewLimit: Value(dailyNewLimit),
      dailyReviewLimit: Value(dailyReviewLimit),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory WordBook.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordBook(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      dailyNewLimit: serializer.fromJson<int>(json['dailyNewLimit']),
      dailyReviewLimit: serializer.fromJson<int>(json['dailyReviewLimit']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'dailyNewLimit': serializer.toJson<int>(dailyNewLimit),
      'dailyReviewLimit': serializer.toJson<int>(dailyReviewLimit),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  WordBook copyWith({
    int? id,
    String? name,
    Value<String?> description = const Value.absent(),
    int? dailyNewLimit,
    int? dailyReviewLimit,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => WordBook(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    dailyNewLimit: dailyNewLimit ?? this.dailyNewLimit,
    dailyReviewLimit: dailyReviewLimit ?? this.dailyReviewLimit,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  WordBook copyWithCompanion(WordBooksCompanion data) {
    return WordBook(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      dailyNewLimit: data.dailyNewLimit.present
          ? data.dailyNewLimit.value
          : this.dailyNewLimit,
      dailyReviewLimit: data.dailyReviewLimit.present
          ? data.dailyReviewLimit.value
          : this.dailyReviewLimit,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordBook(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('dailyNewLimit: $dailyNewLimit, ')
          ..write('dailyReviewLimit: $dailyReviewLimit, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    dailyNewLimit,
    dailyReviewLimit,
    isArchived,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordBook &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.dailyNewLimit == this.dailyNewLimit &&
          other.dailyReviewLimit == this.dailyReviewLimit &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class WordBooksCompanion extends UpdateCompanion<WordBook> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<int> dailyNewLimit;
  final Value<int> dailyReviewLimit;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  const WordBooksCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.dailyNewLimit = const Value.absent(),
    this.dailyReviewLimit = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  WordBooksCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.dailyNewLimit = const Value.absent(),
    this.dailyReviewLimit = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<WordBook> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? dailyNewLimit,
    Expression<int>? dailyReviewLimit,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (dailyNewLimit != null) 'daily_new_limit': dailyNewLimit,
      if (dailyReviewLimit != null) 'daily_review_limit': dailyReviewLimit,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  WordBooksCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<int>? dailyNewLimit,
    Value<int>? dailyReviewLimit,
    Value<bool>? isArchived,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return WordBooksCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      dailyNewLimit: dailyNewLimit ?? this.dailyNewLimit,
      dailyReviewLimit: dailyReviewLimit ?? this.dailyReviewLimit,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (dailyNewLimit.present) {
      map['daily_new_limit'] = Variable<int>(dailyNewLimit.value);
    }
    if (dailyReviewLimit.present) {
      map['daily_review_limit'] = Variable<int>(dailyReviewLimit.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordBooksCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('dailyNewLimit: $dailyNewLimit, ')
          ..write('dailyReviewLimit: $dailyReviewLimit, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $WordsTable extends Words with TableInfo<$WordsTable, Word> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
    'word',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedWordMeta = const VerificationMeta(
    'normalizedWord',
  );
  @override
  late final GeneratedColumn<String> normalizedWord = GeneratedColumn<String>(
    'normalized_word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _meaningMeta = const VerificationMeta(
    'meaning',
  );
  @override
  late final GeneratedColumn<String> meaning = GeneratedColumn<String>(
    'meaning',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneticMeta = const VerificationMeta(
    'phonetic',
  );
  @override
  late final GeneratedColumn<String> phonetic = GeneratedColumn<String>(
    'phonetic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exampleMeta = const VerificationMeta(
    'example',
  );
  @override
  late final GeneratedColumn<String> example = GeneratedColumn<String>(
    'example',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exampleTranslationMeta =
      const VerificationMeta('exampleTranslation');
  @override
  late final GeneratedColumn<String> exampleTranslation =
      GeneratedColumn<String>(
        'example_translation',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _phraseMeta = const VerificationMeta('phrase');
  @override
  late final GeneratedColumn<String> phrase = GeneratedColumn<String>(
    'phrase',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    word,
    normalizedWord,
    meaning,
    phonetic,
    example,
    exampleTranslation,
    phrase,
    note,
    tags,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'words';
  @override
  VerificationContext validateIntegrity(
    Insertable<Word> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('word')) {
      context.handle(
        _wordMeta,
        word.isAcceptableOrUnknown(data['word']!, _wordMeta),
      );
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('normalized_word')) {
      context.handle(
        _normalizedWordMeta,
        normalizedWord.isAcceptableOrUnknown(
          data['normalized_word']!,
          _normalizedWordMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedWordMeta);
    }
    if (data.containsKey('meaning')) {
      context.handle(
        _meaningMeta,
        meaning.isAcceptableOrUnknown(data['meaning']!, _meaningMeta),
      );
    } else if (isInserting) {
      context.missing(_meaningMeta);
    }
    if (data.containsKey('phonetic')) {
      context.handle(
        _phoneticMeta,
        phonetic.isAcceptableOrUnknown(data['phonetic']!, _phoneticMeta),
      );
    }
    if (data.containsKey('example')) {
      context.handle(
        _exampleMeta,
        example.isAcceptableOrUnknown(data['example']!, _exampleMeta),
      );
    }
    if (data.containsKey('example_translation')) {
      context.handle(
        _exampleTranslationMeta,
        exampleTranslation.isAcceptableOrUnknown(
          data['example_translation']!,
          _exampleTranslationMeta,
        ),
      );
    }
    if (data.containsKey('phrase')) {
      context.handle(
        _phraseMeta,
        phrase.isAcceptableOrUnknown(data['phrase']!, _phraseMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Word map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Word(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      word: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word'],
      )!,
      normalizedWord: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_word'],
      )!,
      meaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning'],
      )!,
      phonetic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phonetic'],
      ),
      example: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example'],
      ),
      exampleTranslation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example_translation'],
      ),
      phrase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phrase'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WordsTable createAlias(String alias) {
    return $WordsTable(attachedDatabase, alias);
  }
}

class Word extends DataClass implements Insertable<Word> {
  final int id;
  final String word;
  final String normalizedWord;
  final String meaning;
  final String? phonetic;
  final String? example;
  final String? exampleTranslation;
  final String? phrase;
  final String? note;
  final String? tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Word({
    required this.id,
    required this.word,
    required this.normalizedWord,
    required this.meaning,
    this.phonetic,
    this.example,
    this.exampleTranslation,
    this.phrase,
    this.note,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['word'] = Variable<String>(word);
    map['normalized_word'] = Variable<String>(normalizedWord);
    map['meaning'] = Variable<String>(meaning);
    if (!nullToAbsent || phonetic != null) {
      map['phonetic'] = Variable<String>(phonetic);
    }
    if (!nullToAbsent || example != null) {
      map['example'] = Variable<String>(example);
    }
    if (!nullToAbsent || exampleTranslation != null) {
      map['example_translation'] = Variable<String>(exampleTranslation);
    }
    if (!nullToAbsent || phrase != null) {
      map['phrase'] = Variable<String>(phrase);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WordsCompanion toCompanion(bool nullToAbsent) {
    return WordsCompanion(
      id: Value(id),
      word: Value(word),
      normalizedWord: Value(normalizedWord),
      meaning: Value(meaning),
      phonetic: phonetic == null && nullToAbsent
          ? const Value.absent()
          : Value(phonetic),
      example: example == null && nullToAbsent
          ? const Value.absent()
          : Value(example),
      exampleTranslation: exampleTranslation == null && nullToAbsent
          ? const Value.absent()
          : Value(exampleTranslation),
      phrase: phrase == null && nullToAbsent
          ? const Value.absent()
          : Value(phrase),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Word.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Word(
      id: serializer.fromJson<int>(json['id']),
      word: serializer.fromJson<String>(json['word']),
      normalizedWord: serializer.fromJson<String>(json['normalizedWord']),
      meaning: serializer.fromJson<String>(json['meaning']),
      phonetic: serializer.fromJson<String?>(json['phonetic']),
      example: serializer.fromJson<String?>(json['example']),
      exampleTranslation: serializer.fromJson<String?>(
        json['exampleTranslation'],
      ),
      phrase: serializer.fromJson<String?>(json['phrase']),
      note: serializer.fromJson<String?>(json['note']),
      tags: serializer.fromJson<String?>(json['tags']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'word': serializer.toJson<String>(word),
      'normalizedWord': serializer.toJson<String>(normalizedWord),
      'meaning': serializer.toJson<String>(meaning),
      'phonetic': serializer.toJson<String?>(phonetic),
      'example': serializer.toJson<String?>(example),
      'exampleTranslation': serializer.toJson<String?>(exampleTranslation),
      'phrase': serializer.toJson<String?>(phrase),
      'note': serializer.toJson<String?>(note),
      'tags': serializer.toJson<String?>(tags),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Word copyWith({
    int? id,
    String? word,
    String? normalizedWord,
    String? meaning,
    Value<String?> phonetic = const Value.absent(),
    Value<String?> example = const Value.absent(),
    Value<String?> exampleTranslation = const Value.absent(),
    Value<String?> phrase = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<String?> tags = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Word(
    id: id ?? this.id,
    word: word ?? this.word,
    normalizedWord: normalizedWord ?? this.normalizedWord,
    meaning: meaning ?? this.meaning,
    phonetic: phonetic.present ? phonetic.value : this.phonetic,
    example: example.present ? example.value : this.example,
    exampleTranslation: exampleTranslation.present
        ? exampleTranslation.value
        : this.exampleTranslation,
    phrase: phrase.present ? phrase.value : this.phrase,
    note: note.present ? note.value : this.note,
    tags: tags.present ? tags.value : this.tags,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Word copyWithCompanion(WordsCompanion data) {
    return Word(
      id: data.id.present ? data.id.value : this.id,
      word: data.word.present ? data.word.value : this.word,
      normalizedWord: data.normalizedWord.present
          ? data.normalizedWord.value
          : this.normalizedWord,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      phonetic: data.phonetic.present ? data.phonetic.value : this.phonetic,
      example: data.example.present ? data.example.value : this.example,
      exampleTranslation: data.exampleTranslation.present
          ? data.exampleTranslation.value
          : this.exampleTranslation,
      phrase: data.phrase.present ? data.phrase.value : this.phrase,
      note: data.note.present ? data.note.value : this.note,
      tags: data.tags.present ? data.tags.value : this.tags,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Word(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('normalizedWord: $normalizedWord, ')
          ..write('meaning: $meaning, ')
          ..write('phonetic: $phonetic, ')
          ..write('example: $example, ')
          ..write('exampleTranslation: $exampleTranslation, ')
          ..write('phrase: $phrase, ')
          ..write('note: $note, ')
          ..write('tags: $tags, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    word,
    normalizedWord,
    meaning,
    phonetic,
    example,
    exampleTranslation,
    phrase,
    note,
    tags,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Word &&
          other.id == this.id &&
          other.word == this.word &&
          other.normalizedWord == this.normalizedWord &&
          other.meaning == this.meaning &&
          other.phonetic == this.phonetic &&
          other.example == this.example &&
          other.exampleTranslation == this.exampleTranslation &&
          other.phrase == this.phrase &&
          other.note == this.note &&
          other.tags == this.tags &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WordsCompanion extends UpdateCompanion<Word> {
  final Value<int> id;
  final Value<String> word;
  final Value<String> normalizedWord;
  final Value<String> meaning;
  final Value<String?> phonetic;
  final Value<String?> example;
  final Value<String?> exampleTranslation;
  final Value<String?> phrase;
  final Value<String?> note;
  final Value<String?> tags;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const WordsCompanion({
    this.id = const Value.absent(),
    this.word = const Value.absent(),
    this.normalizedWord = const Value.absent(),
    this.meaning = const Value.absent(),
    this.phonetic = const Value.absent(),
    this.example = const Value.absent(),
    this.exampleTranslation = const Value.absent(),
    this.phrase = const Value.absent(),
    this.note = const Value.absent(),
    this.tags = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  WordsCompanion.insert({
    this.id = const Value.absent(),
    required String word,
    required String normalizedWord,
    required String meaning,
    this.phonetic = const Value.absent(),
    this.example = const Value.absent(),
    this.exampleTranslation = const Value.absent(),
    this.phrase = const Value.absent(),
    this.note = const Value.absent(),
    this.tags = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : word = Value(word),
       normalizedWord = Value(normalizedWord),
       meaning = Value(meaning);
  static Insertable<Word> custom({
    Expression<int>? id,
    Expression<String>? word,
    Expression<String>? normalizedWord,
    Expression<String>? meaning,
    Expression<String>? phonetic,
    Expression<String>? example,
    Expression<String>? exampleTranslation,
    Expression<String>? phrase,
    Expression<String>? note,
    Expression<String>? tags,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (word != null) 'word': word,
      if (normalizedWord != null) 'normalized_word': normalizedWord,
      if (meaning != null) 'meaning': meaning,
      if (phonetic != null) 'phonetic': phonetic,
      if (example != null) 'example': example,
      if (exampleTranslation != null) 'example_translation': exampleTranslation,
      if (phrase != null) 'phrase': phrase,
      if (note != null) 'note': note,
      if (tags != null) 'tags': tags,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  WordsCompanion copyWith({
    Value<int>? id,
    Value<String>? word,
    Value<String>? normalizedWord,
    Value<String>? meaning,
    Value<String?>? phonetic,
    Value<String?>? example,
    Value<String?>? exampleTranslation,
    Value<String?>? phrase,
    Value<String?>? note,
    Value<String?>? tags,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return WordsCompanion(
      id: id ?? this.id,
      word: word ?? this.word,
      normalizedWord: normalizedWord ?? this.normalizedWord,
      meaning: meaning ?? this.meaning,
      phonetic: phonetic ?? this.phonetic,
      example: example ?? this.example,
      exampleTranslation: exampleTranslation ?? this.exampleTranslation,
      phrase: phrase ?? this.phrase,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (normalizedWord.present) {
      map['normalized_word'] = Variable<String>(normalizedWord.value);
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (phonetic.present) {
      map['phonetic'] = Variable<String>(phonetic.value);
    }
    if (example.present) {
      map['example'] = Variable<String>(example.value);
    }
    if (exampleTranslation.present) {
      map['example_translation'] = Variable<String>(exampleTranslation.value);
    }
    if (phrase.present) {
      map['phrase'] = Variable<String>(phrase.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordsCompanion(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('normalizedWord: $normalizedWord, ')
          ..write('meaning: $meaning, ')
          ..write('phonetic: $phonetic, ')
          ..write('example: $example, ')
          ..write('exampleTranslation: $exampleTranslation, ')
          ..write('phrase: $phrase, ')
          ..write('note: $note, ')
          ..write('tags: $tags, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $WordBookItemsTable extends WordBookItems
    with TableInfo<$WordBookItemsTable, WordBookItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordBookItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _wordBookIdMeta = const VerificationMeta(
    'wordBookId',
  );
  @override
  late final GeneratedColumn<int> wordBookId = GeneratedColumn<int>(
    'word_book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES word_books (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
    'word_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES words (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _learningStateMeta = const VerificationMeta(
    'learningState',
  );
  @override
  late final GeneratedColumn<String> learningState = GeneratedColumn<String>(
    'learning_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('new'),
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _suspendedAtMeta = const VerificationMeta(
    'suspendedAt',
  );
  @override
  late final GeneratedColumn<DateTime> suspendedAt = GeneratedColumn<DateTime>(
    'suspended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    wordBookId,
    wordId,
    learningState,
    addedAt,
    suspendedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_book_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordBookItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('word_book_id')) {
      context.handle(
        _wordBookIdMeta,
        wordBookId.isAcceptableOrUnknown(
          data['word_book_id']!,
          _wordBookIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_wordBookIdMeta);
    }
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('learning_state')) {
      context.handle(
        _learningStateMeta,
        learningState.isAcceptableOrUnknown(
          data['learning_state']!,
          _learningStateMeta,
        ),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    if (data.containsKey('suspended_at')) {
      context.handle(
        _suspendedAtMeta,
        suspendedAt.isAcceptableOrUnknown(
          data['suspended_at']!,
          _suspendedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {wordBookId, wordId},
  ];
  @override
  WordBookItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordBookItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      wordBookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_book_id'],
      )!,
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_id'],
      )!,
      learningState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}learning_state'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
      suspendedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}suspended_at'],
      ),
    );
  }

  @override
  $WordBookItemsTable createAlias(String alias) {
    return $WordBookItemsTable(attachedDatabase, alias);
  }
}

class WordBookItem extends DataClass implements Insertable<WordBookItem> {
  final int id;
  final int wordBookId;
  final int wordId;
  final String learningState;
  final DateTime addedAt;
  final DateTime? suspendedAt;
  const WordBookItem({
    required this.id,
    required this.wordBookId,
    required this.wordId,
    required this.learningState,
    required this.addedAt,
    this.suspendedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['word_book_id'] = Variable<int>(wordBookId);
    map['word_id'] = Variable<int>(wordId);
    map['learning_state'] = Variable<String>(learningState);
    map['added_at'] = Variable<DateTime>(addedAt);
    if (!nullToAbsent || suspendedAt != null) {
      map['suspended_at'] = Variable<DateTime>(suspendedAt);
    }
    return map;
  }

  WordBookItemsCompanion toCompanion(bool nullToAbsent) {
    return WordBookItemsCompanion(
      id: Value(id),
      wordBookId: Value(wordBookId),
      wordId: Value(wordId),
      learningState: Value(learningState),
      addedAt: Value(addedAt),
      suspendedAt: suspendedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(suspendedAt),
    );
  }

  factory WordBookItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordBookItem(
      id: serializer.fromJson<int>(json['id']),
      wordBookId: serializer.fromJson<int>(json['wordBookId']),
      wordId: serializer.fromJson<int>(json['wordId']),
      learningState: serializer.fromJson<String>(json['learningState']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      suspendedAt: serializer.fromJson<DateTime?>(json['suspendedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'wordBookId': serializer.toJson<int>(wordBookId),
      'wordId': serializer.toJson<int>(wordId),
      'learningState': serializer.toJson<String>(learningState),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'suspendedAt': serializer.toJson<DateTime?>(suspendedAt),
    };
  }

  WordBookItem copyWith({
    int? id,
    int? wordBookId,
    int? wordId,
    String? learningState,
    DateTime? addedAt,
    Value<DateTime?> suspendedAt = const Value.absent(),
  }) => WordBookItem(
    id: id ?? this.id,
    wordBookId: wordBookId ?? this.wordBookId,
    wordId: wordId ?? this.wordId,
    learningState: learningState ?? this.learningState,
    addedAt: addedAt ?? this.addedAt,
    suspendedAt: suspendedAt.present ? suspendedAt.value : this.suspendedAt,
  );
  WordBookItem copyWithCompanion(WordBookItemsCompanion data) {
    return WordBookItem(
      id: data.id.present ? data.id.value : this.id,
      wordBookId: data.wordBookId.present
          ? data.wordBookId.value
          : this.wordBookId,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      learningState: data.learningState.present
          ? data.learningState.value
          : this.learningState,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      suspendedAt: data.suspendedAt.present
          ? data.suspendedAt.value
          : this.suspendedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordBookItem(')
          ..write('id: $id, ')
          ..write('wordBookId: $wordBookId, ')
          ..write('wordId: $wordId, ')
          ..write('learningState: $learningState, ')
          ..write('addedAt: $addedAt, ')
          ..write('suspendedAt: $suspendedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, wordBookId, wordId, learningState, addedAt, suspendedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordBookItem &&
          other.id == this.id &&
          other.wordBookId == this.wordBookId &&
          other.wordId == this.wordId &&
          other.learningState == this.learningState &&
          other.addedAt == this.addedAt &&
          other.suspendedAt == this.suspendedAt);
}

class WordBookItemsCompanion extends UpdateCompanion<WordBookItem> {
  final Value<int> id;
  final Value<int> wordBookId;
  final Value<int> wordId;
  final Value<String> learningState;
  final Value<DateTime> addedAt;
  final Value<DateTime?> suspendedAt;
  const WordBookItemsCompanion({
    this.id = const Value.absent(),
    this.wordBookId = const Value.absent(),
    this.wordId = const Value.absent(),
    this.learningState = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.suspendedAt = const Value.absent(),
  });
  WordBookItemsCompanion.insert({
    this.id = const Value.absent(),
    required int wordBookId,
    required int wordId,
    this.learningState = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.suspendedAt = const Value.absent(),
  }) : wordBookId = Value(wordBookId),
       wordId = Value(wordId);
  static Insertable<WordBookItem> custom({
    Expression<int>? id,
    Expression<int>? wordBookId,
    Expression<int>? wordId,
    Expression<String>? learningState,
    Expression<DateTime>? addedAt,
    Expression<DateTime>? suspendedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (wordBookId != null) 'word_book_id': wordBookId,
      if (wordId != null) 'word_id': wordId,
      if (learningState != null) 'learning_state': learningState,
      if (addedAt != null) 'added_at': addedAt,
      if (suspendedAt != null) 'suspended_at': suspendedAt,
    });
  }

  WordBookItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? wordBookId,
    Value<int>? wordId,
    Value<String>? learningState,
    Value<DateTime>? addedAt,
    Value<DateTime?>? suspendedAt,
  }) {
    return WordBookItemsCompanion(
      id: id ?? this.id,
      wordBookId: wordBookId ?? this.wordBookId,
      wordId: wordId ?? this.wordId,
      learningState: learningState ?? this.learningState,
      addedAt: addedAt ?? this.addedAt,
      suspendedAt: suspendedAt ?? this.suspendedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (wordBookId.present) {
      map['word_book_id'] = Variable<int>(wordBookId.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (learningState.present) {
      map['learning_state'] = Variable<String>(learningState.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (suspendedAt.present) {
      map['suspended_at'] = Variable<DateTime>(suspendedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordBookItemsCompanion(')
          ..write('id: $id, ')
          ..write('wordBookId: $wordBookId, ')
          ..write('wordId: $wordId, ')
          ..write('learningState: $learningState, ')
          ..write('addedAt: $addedAt, ')
          ..write('suspendedAt: $suspendedAt')
          ..write(')'))
        .toString();
  }
}

class $ReviewSchedulesTable extends ReviewSchedules
    with TableInfo<$ReviewSchedulesTable, ReviewSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _wordBookItemIdMeta = const VerificationMeta(
    'wordBookItemId',
  );
  @override
  late final GeneratedColumn<int> wordBookItemId = GeneratedColumn<int>(
    'word_book_item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES word_book_items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
    'interval_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _streakMeta = const VerificationMeta('streak');
  @override
  late final GeneratedColumn<int> streak = GeneratedColumn<int>(
    'streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lapseCountMeta = const VerificationMeta(
    'lapseCount',
  );
  @override
  late final GeneratedColumn<int> lapseCount = GeneratedColumn<int>(
    'lapse_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastRatingMeta = const VerificationMeta(
    'lastRating',
  );
  @override
  late final GeneratedColumn<String> lastRating = GeneratedColumn<String>(
    'last_rating',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastReviewedAtMeta = const VerificationMeta(
    'lastReviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReviewedAt =
      GeneratedColumn<DateTime>(
        'last_reviewed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    wordBookItemId,
    dueAt,
    intervalDays,
    streak,
    lapseCount,
    lastRating,
    lastReviewedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewSchedule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('word_book_item_id')) {
      context.handle(
        _wordBookItemIdMeta,
        wordBookItemId.isAcceptableOrUnknown(
          data['word_book_item_id']!,
          _wordBookItemIdMeta,
        ),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    } else if (isInserting) {
      context.missing(_dueAtMeta);
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('streak')) {
      context.handle(
        _streakMeta,
        streak.isAcceptableOrUnknown(data['streak']!, _streakMeta),
      );
    }
    if (data.containsKey('lapse_count')) {
      context.handle(
        _lapseCountMeta,
        lapseCount.isAcceptableOrUnknown(data['lapse_count']!, _lapseCountMeta),
      );
    }
    if (data.containsKey('last_rating')) {
      context.handle(
        _lastRatingMeta,
        lastRating.isAcceptableOrUnknown(data['last_rating']!, _lastRatingMeta),
      );
    }
    if (data.containsKey('last_reviewed_at')) {
      context.handle(
        _lastReviewedAtMeta,
        lastReviewedAt.isAcceptableOrUnknown(
          data['last_reviewed_at']!,
          _lastReviewedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {wordBookItemId};
  @override
  ReviewSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewSchedule(
      wordBookItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_book_item_id'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      )!,
      intervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_days'],
      )!,
      streak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}streak'],
      )!,
      lapseCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lapse_count'],
      )!,
      lastRating: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_rating'],
      ),
      lastReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reviewed_at'],
      ),
    );
  }

  @override
  $ReviewSchedulesTable createAlias(String alias) {
    return $ReviewSchedulesTable(attachedDatabase, alias);
  }
}

class ReviewSchedule extends DataClass implements Insertable<ReviewSchedule> {
  final int wordBookItemId;
  final DateTime dueAt;
  final int intervalDays;
  final int streak;
  final int lapseCount;
  final String? lastRating;
  final DateTime? lastReviewedAt;
  const ReviewSchedule({
    required this.wordBookItemId,
    required this.dueAt,
    required this.intervalDays,
    required this.streak,
    required this.lapseCount,
    this.lastRating,
    this.lastReviewedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['word_book_item_id'] = Variable<int>(wordBookItemId);
    map['due_at'] = Variable<DateTime>(dueAt);
    map['interval_days'] = Variable<int>(intervalDays);
    map['streak'] = Variable<int>(streak);
    map['lapse_count'] = Variable<int>(lapseCount);
    if (!nullToAbsent || lastRating != null) {
      map['last_rating'] = Variable<String>(lastRating);
    }
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt);
    }
    return map;
  }

  ReviewSchedulesCompanion toCompanion(bool nullToAbsent) {
    return ReviewSchedulesCompanion(
      wordBookItemId: Value(wordBookItemId),
      dueAt: Value(dueAt),
      intervalDays: Value(intervalDays),
      streak: Value(streak),
      lapseCount: Value(lapseCount),
      lastRating: lastRating == null && nullToAbsent
          ? const Value.absent()
          : Value(lastRating),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
    );
  }

  factory ReviewSchedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewSchedule(
      wordBookItemId: serializer.fromJson<int>(json['wordBookItemId']),
      dueAt: serializer.fromJson<DateTime>(json['dueAt']),
      intervalDays: serializer.fromJson<int>(json['intervalDays']),
      streak: serializer.fromJson<int>(json['streak']),
      lapseCount: serializer.fromJson<int>(json['lapseCount']),
      lastRating: serializer.fromJson<String?>(json['lastRating']),
      lastReviewedAt: serializer.fromJson<DateTime?>(json['lastReviewedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'wordBookItemId': serializer.toJson<int>(wordBookItemId),
      'dueAt': serializer.toJson<DateTime>(dueAt),
      'intervalDays': serializer.toJson<int>(intervalDays),
      'streak': serializer.toJson<int>(streak),
      'lapseCount': serializer.toJson<int>(lapseCount),
      'lastRating': serializer.toJson<String?>(lastRating),
      'lastReviewedAt': serializer.toJson<DateTime?>(lastReviewedAt),
    };
  }

  ReviewSchedule copyWith({
    int? wordBookItemId,
    DateTime? dueAt,
    int? intervalDays,
    int? streak,
    int? lapseCount,
    Value<String?> lastRating = const Value.absent(),
    Value<DateTime?> lastReviewedAt = const Value.absent(),
  }) => ReviewSchedule(
    wordBookItemId: wordBookItemId ?? this.wordBookItemId,
    dueAt: dueAt ?? this.dueAt,
    intervalDays: intervalDays ?? this.intervalDays,
    streak: streak ?? this.streak,
    lapseCount: lapseCount ?? this.lapseCount,
    lastRating: lastRating.present ? lastRating.value : this.lastRating,
    lastReviewedAt: lastReviewedAt.present
        ? lastReviewedAt.value
        : this.lastReviewedAt,
  );
  ReviewSchedule copyWithCompanion(ReviewSchedulesCompanion data) {
    return ReviewSchedule(
      wordBookItemId: data.wordBookItemId.present
          ? data.wordBookItemId.value
          : this.wordBookItemId,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      streak: data.streak.present ? data.streak.value : this.streak,
      lapseCount: data.lapseCount.present
          ? data.lapseCount.value
          : this.lapseCount,
      lastRating: data.lastRating.present
          ? data.lastRating.value
          : this.lastRating,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewSchedule(')
          ..write('wordBookItemId: $wordBookItemId, ')
          ..write('dueAt: $dueAt, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('streak: $streak, ')
          ..write('lapseCount: $lapseCount, ')
          ..write('lastRating: $lastRating, ')
          ..write('lastReviewedAt: $lastReviewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    wordBookItemId,
    dueAt,
    intervalDays,
    streak,
    lapseCount,
    lastRating,
    lastReviewedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewSchedule &&
          other.wordBookItemId == this.wordBookItemId &&
          other.dueAt == this.dueAt &&
          other.intervalDays == this.intervalDays &&
          other.streak == this.streak &&
          other.lapseCount == this.lapseCount &&
          other.lastRating == this.lastRating &&
          other.lastReviewedAt == this.lastReviewedAt);
}

class ReviewSchedulesCompanion extends UpdateCompanion<ReviewSchedule> {
  final Value<int> wordBookItemId;
  final Value<DateTime> dueAt;
  final Value<int> intervalDays;
  final Value<int> streak;
  final Value<int> lapseCount;
  final Value<String?> lastRating;
  final Value<DateTime?> lastReviewedAt;
  const ReviewSchedulesCompanion({
    this.wordBookItemId = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.streak = const Value.absent(),
    this.lapseCount = const Value.absent(),
    this.lastRating = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
  });
  ReviewSchedulesCompanion.insert({
    this.wordBookItemId = const Value.absent(),
    required DateTime dueAt,
    this.intervalDays = const Value.absent(),
    this.streak = const Value.absent(),
    this.lapseCount = const Value.absent(),
    this.lastRating = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
  }) : dueAt = Value(dueAt);
  static Insertable<ReviewSchedule> custom({
    Expression<int>? wordBookItemId,
    Expression<DateTime>? dueAt,
    Expression<int>? intervalDays,
    Expression<int>? streak,
    Expression<int>? lapseCount,
    Expression<String>? lastRating,
    Expression<DateTime>? lastReviewedAt,
  }) {
    return RawValuesInsertable({
      if (wordBookItemId != null) 'word_book_item_id': wordBookItemId,
      if (dueAt != null) 'due_at': dueAt,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (streak != null) 'streak': streak,
      if (lapseCount != null) 'lapse_count': lapseCount,
      if (lastRating != null) 'last_rating': lastRating,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
    });
  }

  ReviewSchedulesCompanion copyWith({
    Value<int>? wordBookItemId,
    Value<DateTime>? dueAt,
    Value<int>? intervalDays,
    Value<int>? streak,
    Value<int>? lapseCount,
    Value<String?>? lastRating,
    Value<DateTime?>? lastReviewedAt,
  }) {
    return ReviewSchedulesCompanion(
      wordBookItemId: wordBookItemId ?? this.wordBookItemId,
      dueAt: dueAt ?? this.dueAt,
      intervalDays: intervalDays ?? this.intervalDays,
      streak: streak ?? this.streak,
      lapseCount: lapseCount ?? this.lapseCount,
      lastRating: lastRating ?? this.lastRating,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (wordBookItemId.present) {
      map['word_book_item_id'] = Variable<int>(wordBookItemId.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (streak.present) {
      map['streak'] = Variable<int>(streak.value);
    }
    if (lapseCount.present) {
      map['lapse_count'] = Variable<int>(lapseCount.value);
    }
    if (lastRating.present) {
      map['last_rating'] = Variable<String>(lastRating.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewSchedulesCompanion(')
          ..write('wordBookItemId: $wordBookItemId, ')
          ..write('dueAt: $dueAt, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('streak: $streak, ')
          ..write('lapseCount: $lapseCount, ')
          ..write('lastRating: $lastRating, ')
          ..write('lastReviewedAt: $lastReviewedAt')
          ..write(')'))
        .toString();
  }
}

class $ReviewRecordsTable extends ReviewRecords
    with TableInfo<$ReviewRecordsTable, ReviewRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _wordBookItemIdMeta = const VerificationMeta(
    'wordBookItemId',
  );
  @override
  late final GeneratedColumn<int> wordBookItemId = GeneratedColumn<int>(
    'word_book_item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES word_book_items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<String> rating = GeneratedColumn<String>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewedAtMeta = const VerificationMeta(
    'reviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> reviewedAt = GeneratedColumn<DateTime>(
    'reviewed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previousDueAtMeta = const VerificationMeta(
    'previousDueAt',
  );
  @override
  late final GeneratedColumn<DateTime> previousDueAt =
      GeneratedColumn<DateTime>(
        'previous_due_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _nextDueAtMeta = const VerificationMeta(
    'nextDueAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextDueAt = GeneratedColumn<DateTime>(
    'next_due_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    wordBookItemId,
    rating,
    reviewedAt,
    previousDueAt,
    nextDueAt,
    durationMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('word_book_item_id')) {
      context.handle(
        _wordBookItemIdMeta,
        wordBookItemId.isAcceptableOrUnknown(
          data['word_book_item_id']!,
          _wordBookItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_wordBookItemIdMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    } else if (isInserting) {
      context.missing(_ratingMeta);
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
        _reviewedAtMeta,
        reviewedAt.isAcceptableOrUnknown(data['reviewed_at']!, _reviewedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_reviewedAtMeta);
    }
    if (data.containsKey('previous_due_at')) {
      context.handle(
        _previousDueAtMeta,
        previousDueAt.isAcceptableOrUnknown(
          data['previous_due_at']!,
          _previousDueAtMeta,
        ),
      );
    }
    if (data.containsKey('next_due_at')) {
      context.handle(
        _nextDueAtMeta,
        nextDueAt.isAcceptableOrUnknown(data['next_due_at']!, _nextDueAtMeta),
      );
    } else if (isInserting) {
      context.missing(_nextDueAtMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      wordBookItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_book_item_id'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rating'],
      )!,
      reviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reviewed_at'],
      )!,
      previousDueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}previous_due_at'],
      ),
      nextDueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_due_at'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
    );
  }

  @override
  $ReviewRecordsTable createAlias(String alias) {
    return $ReviewRecordsTable(attachedDatabase, alias);
  }
}

class ReviewRecord extends DataClass implements Insertable<ReviewRecord> {
  final int id;
  final int wordBookItemId;
  final String rating;
  final DateTime reviewedAt;
  final DateTime? previousDueAt;
  final DateTime nextDueAt;
  final int? durationMs;
  const ReviewRecord({
    required this.id,
    required this.wordBookItemId,
    required this.rating,
    required this.reviewedAt,
    this.previousDueAt,
    required this.nextDueAt,
    this.durationMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['word_book_item_id'] = Variable<int>(wordBookItemId);
    map['rating'] = Variable<String>(rating);
    map['reviewed_at'] = Variable<DateTime>(reviewedAt);
    if (!nullToAbsent || previousDueAt != null) {
      map['previous_due_at'] = Variable<DateTime>(previousDueAt);
    }
    map['next_due_at'] = Variable<DateTime>(nextDueAt);
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    return map;
  }

  ReviewRecordsCompanion toCompanion(bool nullToAbsent) {
    return ReviewRecordsCompanion(
      id: Value(id),
      wordBookItemId: Value(wordBookItemId),
      rating: Value(rating),
      reviewedAt: Value(reviewedAt),
      previousDueAt: previousDueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(previousDueAt),
      nextDueAt: Value(nextDueAt),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
    );
  }

  factory ReviewRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewRecord(
      id: serializer.fromJson<int>(json['id']),
      wordBookItemId: serializer.fromJson<int>(json['wordBookItemId']),
      rating: serializer.fromJson<String>(json['rating']),
      reviewedAt: serializer.fromJson<DateTime>(json['reviewedAt']),
      previousDueAt: serializer.fromJson<DateTime?>(json['previousDueAt']),
      nextDueAt: serializer.fromJson<DateTime>(json['nextDueAt']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'wordBookItemId': serializer.toJson<int>(wordBookItemId),
      'rating': serializer.toJson<String>(rating),
      'reviewedAt': serializer.toJson<DateTime>(reviewedAt),
      'previousDueAt': serializer.toJson<DateTime?>(previousDueAt),
      'nextDueAt': serializer.toJson<DateTime>(nextDueAt),
      'durationMs': serializer.toJson<int?>(durationMs),
    };
  }

  ReviewRecord copyWith({
    int? id,
    int? wordBookItemId,
    String? rating,
    DateTime? reviewedAt,
    Value<DateTime?> previousDueAt = const Value.absent(),
    DateTime? nextDueAt,
    Value<int?> durationMs = const Value.absent(),
  }) => ReviewRecord(
    id: id ?? this.id,
    wordBookItemId: wordBookItemId ?? this.wordBookItemId,
    rating: rating ?? this.rating,
    reviewedAt: reviewedAt ?? this.reviewedAt,
    previousDueAt: previousDueAt.present
        ? previousDueAt.value
        : this.previousDueAt,
    nextDueAt: nextDueAt ?? this.nextDueAt,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
  );
  ReviewRecord copyWithCompanion(ReviewRecordsCompanion data) {
    return ReviewRecord(
      id: data.id.present ? data.id.value : this.id,
      wordBookItemId: data.wordBookItemId.present
          ? data.wordBookItemId.value
          : this.wordBookItemId,
      rating: data.rating.present ? data.rating.value : this.rating,
      reviewedAt: data.reviewedAt.present
          ? data.reviewedAt.value
          : this.reviewedAt,
      previousDueAt: data.previousDueAt.present
          ? data.previousDueAt.value
          : this.previousDueAt,
      nextDueAt: data.nextDueAt.present ? data.nextDueAt.value : this.nextDueAt,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewRecord(')
          ..write('id: $id, ')
          ..write('wordBookItemId: $wordBookItemId, ')
          ..write('rating: $rating, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('previousDueAt: $previousDueAt, ')
          ..write('nextDueAt: $nextDueAt, ')
          ..write('durationMs: $durationMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    wordBookItemId,
    rating,
    reviewedAt,
    previousDueAt,
    nextDueAt,
    durationMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewRecord &&
          other.id == this.id &&
          other.wordBookItemId == this.wordBookItemId &&
          other.rating == this.rating &&
          other.reviewedAt == this.reviewedAt &&
          other.previousDueAt == this.previousDueAt &&
          other.nextDueAt == this.nextDueAt &&
          other.durationMs == this.durationMs);
}

class ReviewRecordsCompanion extends UpdateCompanion<ReviewRecord> {
  final Value<int> id;
  final Value<int> wordBookItemId;
  final Value<String> rating;
  final Value<DateTime> reviewedAt;
  final Value<DateTime?> previousDueAt;
  final Value<DateTime> nextDueAt;
  final Value<int?> durationMs;
  const ReviewRecordsCompanion({
    this.id = const Value.absent(),
    this.wordBookItemId = const Value.absent(),
    this.rating = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.previousDueAt = const Value.absent(),
    this.nextDueAt = const Value.absent(),
    this.durationMs = const Value.absent(),
  });
  ReviewRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int wordBookItemId,
    required String rating,
    required DateTime reviewedAt,
    this.previousDueAt = const Value.absent(),
    required DateTime nextDueAt,
    this.durationMs = const Value.absent(),
  }) : wordBookItemId = Value(wordBookItemId),
       rating = Value(rating),
       reviewedAt = Value(reviewedAt),
       nextDueAt = Value(nextDueAt);
  static Insertable<ReviewRecord> custom({
    Expression<int>? id,
    Expression<int>? wordBookItemId,
    Expression<String>? rating,
    Expression<DateTime>? reviewedAt,
    Expression<DateTime>? previousDueAt,
    Expression<DateTime>? nextDueAt,
    Expression<int>? durationMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (wordBookItemId != null) 'word_book_item_id': wordBookItemId,
      if (rating != null) 'rating': rating,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (previousDueAt != null) 'previous_due_at': previousDueAt,
      if (nextDueAt != null) 'next_due_at': nextDueAt,
      if (durationMs != null) 'duration_ms': durationMs,
    });
  }

  ReviewRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? wordBookItemId,
    Value<String>? rating,
    Value<DateTime>? reviewedAt,
    Value<DateTime?>? previousDueAt,
    Value<DateTime>? nextDueAt,
    Value<int?>? durationMs,
  }) {
    return ReviewRecordsCompanion(
      id: id ?? this.id,
      wordBookItemId: wordBookItemId ?? this.wordBookItemId,
      rating: rating ?? this.rating,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      previousDueAt: previousDueAt ?? this.previousDueAt,
      nextDueAt: nextDueAt ?? this.nextDueAt,
      durationMs: durationMs ?? this.durationMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (wordBookItemId.present) {
      map['word_book_item_id'] = Variable<int>(wordBookItemId.value);
    }
    if (rating.present) {
      map['rating'] = Variable<String>(rating.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt.value);
    }
    if (previousDueAt.present) {
      map['previous_due_at'] = Variable<DateTime>(previousDueAt.value);
    }
    if (nextDueAt.present) {
      map['next_due_at'] = Variable<DateTime>(nextDueAt.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewRecordsCompanion(')
          ..write('id: $id, ')
          ..write('wordBookItemId: $wordBookItemId, ')
          ..write('rating: $rating, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('previousDueAt: $previousDueAt, ')
          ..write('nextDueAt: $nextDueAt, ')
          ..write('durationMs: $durationMs')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    colorValue,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  final int? colorValue;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Category({
    required this.id,
    required this.name,
    this.colorValue,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || colorValue != null) {
      map['color_value'] = Variable<int>(colorValue);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      colorValue: colorValue == null && nullToAbsent
          ? const Value.absent()
          : Value(colorValue),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorValue: serializer.fromJson<int?>(json['colorValue']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'colorValue': serializer.toJson<int?>(colorValue),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Category copyWith({
    int? id,
    String? name,
    Value<int?> colorValue = const Value.absent(),
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    colorValue: colorValue.present ? colorValue.value : this.colorValue,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, colorValue, sortOrder, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorValue == this.colorValue &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> colorValue;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.colorValue = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? colorValue,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorValue != null) 'color_value': colorValue,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? colorValue,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CourseSchedulesTable extends CourseSchedules
    with TableInfo<$CourseSchedulesTable, CourseSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CourseSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    sourceType,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'course_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<CourseSchedule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CourseSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CourseSchedule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CourseSchedulesTable createAlias(String alias) {
    return $CourseSchedulesTable(attachedDatabase, alias);
  }
}

class CourseSchedule extends DataClass implements Insertable<CourseSchedule> {
  final int id;
  final String name;
  final String sourceType;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CourseSchedule({
    required this.id,
    required this.name,
    required this.sourceType,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['source_type'] = Variable<String>(sourceType);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CourseSchedulesCompanion toCompanion(bool nullToAbsent) {
    return CourseSchedulesCompanion(
      id: Value(id),
      name: Value(name),
      sourceType: Value(sourceType),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CourseSchedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CourseSchedule(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'sourceType': serializer.toJson<String>(sourceType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CourseSchedule copyWith({
    int? id,
    String? name,
    String? sourceType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CourseSchedule(
    id: id ?? this.id,
    name: name ?? this.name,
    sourceType: sourceType ?? this.sourceType,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CourseSchedule copyWithCompanion(CourseSchedulesCompanion data) {
    return CourseSchedule(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CourseSchedule(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sourceType: $sourceType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, sourceType, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CourseSchedule &&
          other.id == this.id &&
          other.name == this.name &&
          other.sourceType == this.sourceType &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CourseSchedulesCompanion extends UpdateCompanion<CourseSchedule> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> sourceType;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CourseSchedulesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CourseSchedulesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String sourceType,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       sourceType = Value(sourceType);
  static Insertable<CourseSchedule> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? sourceType,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sourceType != null) 'source_type': sourceType,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CourseSchedulesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? sourceType,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return CourseSchedulesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sourceType: sourceType ?? this.sourceType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CourseSchedulesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sourceType: $sourceType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PlansTable extends Plans with TableInfo<$PlansTable, Plan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<int> templateId = GeneratedColumn<int>(
    'template_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _wordBookIdMeta = const VerificationMeta(
    'wordBookId',
  );
  @override
  late final GeneratedColumn<int> wordBookId = GeneratedColumn<int>(
    'word_book_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES word_books (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _courseScheduleIdMeta = const VerificationMeta(
    'courseScheduleId',
  );
  @override
  late final GeneratedColumn<int> courseScheduleId = GeneratedColumn<int>(
    'course_schedule_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES course_schedules (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _linkedAppPackageMeta = const VerificationMeta(
    'linkedAppPackage',
  );
  @override
  late final GeneratedColumn<String> linkedAppPackage = GeneratedColumn<String>(
    'linked_app_package',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkedAppNameMeta = const VerificationMeta(
    'linkedAppName',
  );
  @override
  late final GeneratedColumn<String> linkedAppName = GeneratedColumn<String>(
    'linked_app_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startsAtMeta = const VerificationMeta(
    'startsAt',
  );
  @override
  late final GeneratedColumn<DateTime> startsAt = GeneratedColumn<DateTime>(
    'starts_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estimatedMinutesMeta = const VerificationMeta(
    'estimatedMinutes',
  );
  @override
  late final GeneratedColumn<int> estimatedMinutes = GeneratedColumn<int>(
    'estimated_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(25),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _repeatRuleMeta = const VerificationMeta(
    'repeatRule',
  );
  @override
  late final GeneratedColumn<String> repeatRule = GeneratedColumn<String>(
    'repeat_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _instanceDateMeta = const VerificationMeta(
    'instanceDate',
  );
  @override
  late final GeneratedColumn<String> instanceDate = GeneratedColumn<String>(
    'instance_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetPomodorosMeta = const VerificationMeta(
    'targetPomodoros',
  );
  @override
  late final GeneratedColumn<int> targetPomodoros = GeneratedColumn<int>(
    'target_pomodoros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _actualMinutesMeta = const VerificationMeta(
    'actualMinutes',
  );
  @override
  late final GeneratedColumn<int> actualMinutes = GeneratedColumn<int>(
    'actual_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    templateId,
    categoryId,
    wordBookId,
    courseScheduleId,
    linkedAppPackage,
    linkedAppName,
    title,
    note,
    startsAt,
    estimatedMinutes,
    priority,
    status,
    repeatRule,
    instanceDate,
    targetPomodoros,
    actualMinutes,
    completedAt,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<Plan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('word_book_id')) {
      context.handle(
        _wordBookIdMeta,
        wordBookId.isAcceptableOrUnknown(
          data['word_book_id']!,
          _wordBookIdMeta,
        ),
      );
    }
    if (data.containsKey('course_schedule_id')) {
      context.handle(
        _courseScheduleIdMeta,
        courseScheduleId.isAcceptableOrUnknown(
          data['course_schedule_id']!,
          _courseScheduleIdMeta,
        ),
      );
    }
    if (data.containsKey('linked_app_package')) {
      context.handle(
        _linkedAppPackageMeta,
        linkedAppPackage.isAcceptableOrUnknown(
          data['linked_app_package']!,
          _linkedAppPackageMeta,
        ),
      );
    }
    if (data.containsKey('linked_app_name')) {
      context.handle(
        _linkedAppNameMeta,
        linkedAppName.isAcceptableOrUnknown(
          data['linked_app_name']!,
          _linkedAppNameMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('starts_at')) {
      context.handle(
        _startsAtMeta,
        startsAt.isAcceptableOrUnknown(data['starts_at']!, _startsAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startsAtMeta);
    }
    if (data.containsKey('estimated_minutes')) {
      context.handle(
        _estimatedMinutesMeta,
        estimatedMinutes.isAcceptableOrUnknown(
          data['estimated_minutes']!,
          _estimatedMinutesMeta,
        ),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('repeat_rule')) {
      context.handle(
        _repeatRuleMeta,
        repeatRule.isAcceptableOrUnknown(data['repeat_rule']!, _repeatRuleMeta),
      );
    }
    if (data.containsKey('instance_date')) {
      context.handle(
        _instanceDateMeta,
        instanceDate.isAcceptableOrUnknown(
          data['instance_date']!,
          _instanceDateMeta,
        ),
      );
    }
    if (data.containsKey('target_pomodoros')) {
      context.handle(
        _targetPomodorosMeta,
        targetPomodoros.isAcceptableOrUnknown(
          data['target_pomodoros']!,
          _targetPomodorosMeta,
        ),
      );
    }
    if (data.containsKey('actual_minutes')) {
      context.handle(
        _actualMinutesMeta,
        actualMinutes.isAcceptableOrUnknown(
          data['actual_minutes']!,
          _actualMinutesMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Plan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Plan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}template_id'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      wordBookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_book_id'],
      ),
      courseScheduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}course_schedule_id'],
      ),
      linkedAppPackage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_app_package'],
      ),
      linkedAppName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_app_name'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      startsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}starts_at'],
      )!,
      estimatedMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_minutes'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      repeatRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_rule'],
      ),
      instanceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instance_date'],
      ),
      targetPomodoros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_pomodoros'],
      )!,
      actualMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_minutes'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $PlansTable createAlias(String alias) {
    return $PlansTable(attachedDatabase, alias);
  }
}

class Plan extends DataClass implements Insertable<Plan> {
  final int id;
  final int? templateId;
  final int? categoryId;
  final int? wordBookId;
  final int? courseScheduleId;
  final String? linkedAppPackage;
  final String? linkedAppName;
  final String title;
  final String? note;
  final DateTime startsAt;
  final int estimatedMinutes;
  final int priority;
  final String status;
  final String? repeatRule;
  final String? instanceDate;
  final int targetPomodoros;
  final int actualMinutes;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Plan({
    required this.id,
    this.templateId,
    this.categoryId,
    this.wordBookId,
    this.courseScheduleId,
    this.linkedAppPackage,
    this.linkedAppName,
    required this.title,
    this.note,
    required this.startsAt,
    required this.estimatedMinutes,
    required this.priority,
    required this.status,
    this.repeatRule,
    this.instanceDate,
    required this.targetPomodoros,
    required this.actualMinutes,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || templateId != null) {
      map['template_id'] = Variable<int>(templateId);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    if (!nullToAbsent || wordBookId != null) {
      map['word_book_id'] = Variable<int>(wordBookId);
    }
    if (!nullToAbsent || courseScheduleId != null) {
      map['course_schedule_id'] = Variable<int>(courseScheduleId);
    }
    if (!nullToAbsent || linkedAppPackage != null) {
      map['linked_app_package'] = Variable<String>(linkedAppPackage);
    }
    if (!nullToAbsent || linkedAppName != null) {
      map['linked_app_name'] = Variable<String>(linkedAppName);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['starts_at'] = Variable<DateTime>(startsAt);
    map['estimated_minutes'] = Variable<int>(estimatedMinutes);
    map['priority'] = Variable<int>(priority);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || repeatRule != null) {
      map['repeat_rule'] = Variable<String>(repeatRule);
    }
    if (!nullToAbsent || instanceDate != null) {
      map['instance_date'] = Variable<String>(instanceDate);
    }
    map['target_pomodoros'] = Variable<int>(targetPomodoros);
    map['actual_minutes'] = Variable<int>(actualMinutes);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  PlansCompanion toCompanion(bool nullToAbsent) {
    return PlansCompanion(
      id: Value(id),
      templateId: templateId == null && nullToAbsent
          ? const Value.absent()
          : Value(templateId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      wordBookId: wordBookId == null && nullToAbsent
          ? const Value.absent()
          : Value(wordBookId),
      courseScheduleId: courseScheduleId == null && nullToAbsent
          ? const Value.absent()
          : Value(courseScheduleId),
      linkedAppPackage: linkedAppPackage == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedAppPackage),
      linkedAppName: linkedAppName == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedAppName),
      title: Value(title),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      startsAt: Value(startsAt),
      estimatedMinutes: Value(estimatedMinutes),
      priority: Value(priority),
      status: Value(status),
      repeatRule: repeatRule == null && nullToAbsent
          ? const Value.absent()
          : Value(repeatRule),
      instanceDate: instanceDate == null && nullToAbsent
          ? const Value.absent()
          : Value(instanceDate),
      targetPomodoros: Value(targetPomodoros),
      actualMinutes: Value(actualMinutes),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Plan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Plan(
      id: serializer.fromJson<int>(json['id']),
      templateId: serializer.fromJson<int?>(json['templateId']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      wordBookId: serializer.fromJson<int?>(json['wordBookId']),
      courseScheduleId: serializer.fromJson<int?>(json['courseScheduleId']),
      linkedAppPackage: serializer.fromJson<String?>(json['linkedAppPackage']),
      linkedAppName: serializer.fromJson<String?>(json['linkedAppName']),
      title: serializer.fromJson<String>(json['title']),
      note: serializer.fromJson<String?>(json['note']),
      startsAt: serializer.fromJson<DateTime>(json['startsAt']),
      estimatedMinutes: serializer.fromJson<int>(json['estimatedMinutes']),
      priority: serializer.fromJson<int>(json['priority']),
      status: serializer.fromJson<String>(json['status']),
      repeatRule: serializer.fromJson<String?>(json['repeatRule']),
      instanceDate: serializer.fromJson<String?>(json['instanceDate']),
      targetPomodoros: serializer.fromJson<int>(json['targetPomodoros']),
      actualMinutes: serializer.fromJson<int>(json['actualMinutes']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'templateId': serializer.toJson<int?>(templateId),
      'categoryId': serializer.toJson<int?>(categoryId),
      'wordBookId': serializer.toJson<int?>(wordBookId),
      'courseScheduleId': serializer.toJson<int?>(courseScheduleId),
      'linkedAppPackage': serializer.toJson<String?>(linkedAppPackage),
      'linkedAppName': serializer.toJson<String?>(linkedAppName),
      'title': serializer.toJson<String>(title),
      'note': serializer.toJson<String?>(note),
      'startsAt': serializer.toJson<DateTime>(startsAt),
      'estimatedMinutes': serializer.toJson<int>(estimatedMinutes),
      'priority': serializer.toJson<int>(priority),
      'status': serializer.toJson<String>(status),
      'repeatRule': serializer.toJson<String?>(repeatRule),
      'instanceDate': serializer.toJson<String?>(instanceDate),
      'targetPomodoros': serializer.toJson<int>(targetPomodoros),
      'actualMinutes': serializer.toJson<int>(actualMinutes),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Plan copyWith({
    int? id,
    Value<int?> templateId = const Value.absent(),
    Value<int?> categoryId = const Value.absent(),
    Value<int?> wordBookId = const Value.absent(),
    Value<int?> courseScheduleId = const Value.absent(),
    Value<String?> linkedAppPackage = const Value.absent(),
    Value<String?> linkedAppName = const Value.absent(),
    String? title,
    Value<String?> note = const Value.absent(),
    DateTime? startsAt,
    int? estimatedMinutes,
    int? priority,
    String? status,
    Value<String?> repeatRule = const Value.absent(),
    Value<String?> instanceDate = const Value.absent(),
    int? targetPomodoros,
    int? actualMinutes,
    Value<DateTime?> completedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Plan(
    id: id ?? this.id,
    templateId: templateId.present ? templateId.value : this.templateId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    wordBookId: wordBookId.present ? wordBookId.value : this.wordBookId,
    courseScheduleId: courseScheduleId.present
        ? courseScheduleId.value
        : this.courseScheduleId,
    linkedAppPackage: linkedAppPackage.present
        ? linkedAppPackage.value
        : this.linkedAppPackage,
    linkedAppName: linkedAppName.present
        ? linkedAppName.value
        : this.linkedAppName,
    title: title ?? this.title,
    note: note.present ? note.value : this.note,
    startsAt: startsAt ?? this.startsAt,
    estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    repeatRule: repeatRule.present ? repeatRule.value : this.repeatRule,
    instanceDate: instanceDate.present ? instanceDate.value : this.instanceDate,
    targetPomodoros: targetPomodoros ?? this.targetPomodoros,
    actualMinutes: actualMinutes ?? this.actualMinutes,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Plan copyWithCompanion(PlansCompanion data) {
    return Plan(
      id: data.id.present ? data.id.value : this.id,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      wordBookId: data.wordBookId.present
          ? data.wordBookId.value
          : this.wordBookId,
      courseScheduleId: data.courseScheduleId.present
          ? data.courseScheduleId.value
          : this.courseScheduleId,
      linkedAppPackage: data.linkedAppPackage.present
          ? data.linkedAppPackage.value
          : this.linkedAppPackage,
      linkedAppName: data.linkedAppName.present
          ? data.linkedAppName.value
          : this.linkedAppName,
      title: data.title.present ? data.title.value : this.title,
      note: data.note.present ? data.note.value : this.note,
      startsAt: data.startsAt.present ? data.startsAt.value : this.startsAt,
      estimatedMinutes: data.estimatedMinutes.present
          ? data.estimatedMinutes.value
          : this.estimatedMinutes,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      repeatRule: data.repeatRule.present
          ? data.repeatRule.value
          : this.repeatRule,
      instanceDate: data.instanceDate.present
          ? data.instanceDate.value
          : this.instanceDate,
      targetPomodoros: data.targetPomodoros.present
          ? data.targetPomodoros.value
          : this.targetPomodoros,
      actualMinutes: data.actualMinutes.present
          ? data.actualMinutes.value
          : this.actualMinutes,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Plan(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('categoryId: $categoryId, ')
          ..write('wordBookId: $wordBookId, ')
          ..write('courseScheduleId: $courseScheduleId, ')
          ..write('linkedAppPackage: $linkedAppPackage, ')
          ..write('linkedAppName: $linkedAppName, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('startsAt: $startsAt, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('instanceDate: $instanceDate, ')
          ..write('targetPomodoros: $targetPomodoros, ')
          ..write('actualMinutes: $actualMinutes, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    templateId,
    categoryId,
    wordBookId,
    courseScheduleId,
    linkedAppPackage,
    linkedAppName,
    title,
    note,
    startsAt,
    estimatedMinutes,
    priority,
    status,
    repeatRule,
    instanceDate,
    targetPomodoros,
    actualMinutes,
    completedAt,
    createdAt,
    updatedAt,
    deletedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Plan &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.categoryId == this.categoryId &&
          other.wordBookId == this.wordBookId &&
          other.courseScheduleId == this.courseScheduleId &&
          other.linkedAppPackage == this.linkedAppPackage &&
          other.linkedAppName == this.linkedAppName &&
          other.title == this.title &&
          other.note == this.note &&
          other.startsAt == this.startsAt &&
          other.estimatedMinutes == this.estimatedMinutes &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.repeatRule == this.repeatRule &&
          other.instanceDate == this.instanceDate &&
          other.targetPomodoros == this.targetPomodoros &&
          other.actualMinutes == this.actualMinutes &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class PlansCompanion extends UpdateCompanion<Plan> {
  final Value<int> id;
  final Value<int?> templateId;
  final Value<int?> categoryId;
  final Value<int?> wordBookId;
  final Value<int?> courseScheduleId;
  final Value<String?> linkedAppPackage;
  final Value<String?> linkedAppName;
  final Value<String> title;
  final Value<String?> note;
  final Value<DateTime> startsAt;
  final Value<int> estimatedMinutes;
  final Value<int> priority;
  final Value<String> status;
  final Value<String?> repeatRule;
  final Value<String?> instanceDate;
  final Value<int> targetPomodoros;
  final Value<int> actualMinutes;
  final Value<DateTime?> completedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  const PlansCompanion({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.wordBookId = const Value.absent(),
    this.courseScheduleId = const Value.absent(),
    this.linkedAppPackage = const Value.absent(),
    this.linkedAppName = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.startsAt = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.repeatRule = const Value.absent(),
    this.instanceDate = const Value.absent(),
    this.targetPomodoros = const Value.absent(),
    this.actualMinutes = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  PlansCompanion.insert({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.wordBookId = const Value.absent(),
    this.courseScheduleId = const Value.absent(),
    this.linkedAppPackage = const Value.absent(),
    this.linkedAppName = const Value.absent(),
    required String title,
    this.note = const Value.absent(),
    required DateTime startsAt,
    this.estimatedMinutes = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.repeatRule = const Value.absent(),
    this.instanceDate = const Value.absent(),
    this.targetPomodoros = const Value.absent(),
    this.actualMinutes = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : title = Value(title),
       startsAt = Value(startsAt);
  static Insertable<Plan> custom({
    Expression<int>? id,
    Expression<int>? templateId,
    Expression<int>? categoryId,
    Expression<int>? wordBookId,
    Expression<int>? courseScheduleId,
    Expression<String>? linkedAppPackage,
    Expression<String>? linkedAppName,
    Expression<String>? title,
    Expression<String>? note,
    Expression<DateTime>? startsAt,
    Expression<int>? estimatedMinutes,
    Expression<int>? priority,
    Expression<String>? status,
    Expression<String>? repeatRule,
    Expression<String>? instanceDate,
    Expression<int>? targetPomodoros,
    Expression<int>? actualMinutes,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (categoryId != null) 'category_id': categoryId,
      if (wordBookId != null) 'word_book_id': wordBookId,
      if (courseScheduleId != null) 'course_schedule_id': courseScheduleId,
      if (linkedAppPackage != null) 'linked_app_package': linkedAppPackage,
      if (linkedAppName != null) 'linked_app_name': linkedAppName,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (startsAt != null) 'starts_at': startsAt,
      if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (repeatRule != null) 'repeat_rule': repeatRule,
      if (instanceDate != null) 'instance_date': instanceDate,
      if (targetPomodoros != null) 'target_pomodoros': targetPomodoros,
      if (actualMinutes != null) 'actual_minutes': actualMinutes,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  PlansCompanion copyWith({
    Value<int>? id,
    Value<int?>? templateId,
    Value<int?>? categoryId,
    Value<int?>? wordBookId,
    Value<int?>? courseScheduleId,
    Value<String?>? linkedAppPackage,
    Value<String?>? linkedAppName,
    Value<String>? title,
    Value<String?>? note,
    Value<DateTime>? startsAt,
    Value<int>? estimatedMinutes,
    Value<int>? priority,
    Value<String>? status,
    Value<String?>? repeatRule,
    Value<String?>? instanceDate,
    Value<int>? targetPomodoros,
    Value<int>? actualMinutes,
    Value<DateTime?>? completedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return PlansCompanion(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      categoryId: categoryId ?? this.categoryId,
      wordBookId: wordBookId ?? this.wordBookId,
      courseScheduleId: courseScheduleId ?? this.courseScheduleId,
      linkedAppPackage: linkedAppPackage ?? this.linkedAppPackage,
      linkedAppName: linkedAppName ?? this.linkedAppName,
      title: title ?? this.title,
      note: note ?? this.note,
      startsAt: startsAt ?? this.startsAt,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      repeatRule: repeatRule ?? this.repeatRule,
      instanceDate: instanceDate ?? this.instanceDate,
      targetPomodoros: targetPomodoros ?? this.targetPomodoros,
      actualMinutes: actualMinutes ?? this.actualMinutes,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<int>(templateId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (wordBookId.present) {
      map['word_book_id'] = Variable<int>(wordBookId.value);
    }
    if (courseScheduleId.present) {
      map['course_schedule_id'] = Variable<int>(courseScheduleId.value);
    }
    if (linkedAppPackage.present) {
      map['linked_app_package'] = Variable<String>(linkedAppPackage.value);
    }
    if (linkedAppName.present) {
      map['linked_app_name'] = Variable<String>(linkedAppName.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (startsAt.present) {
      map['starts_at'] = Variable<DateTime>(startsAt.value);
    }
    if (estimatedMinutes.present) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (repeatRule.present) {
      map['repeat_rule'] = Variable<String>(repeatRule.value);
    }
    if (instanceDate.present) {
      map['instance_date'] = Variable<String>(instanceDate.value);
    }
    if (targetPomodoros.present) {
      map['target_pomodoros'] = Variable<int>(targetPomodoros.value);
    }
    if (actualMinutes.present) {
      map['actual_minutes'] = Variable<int>(actualMinutes.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlansCompanion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('categoryId: $categoryId, ')
          ..write('wordBookId: $wordBookId, ')
          ..write('courseScheduleId: $courseScheduleId, ')
          ..write('linkedAppPackage: $linkedAppPackage, ')
          ..write('linkedAppName: $linkedAppName, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('startsAt: $startsAt, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('instanceDate: $instanceDate, ')
          ..write('targetPomodoros: $targetPomodoros, ')
          ..write('actualMinutes: $actualMinutes, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plans (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _triggerAtMeta = const VerificationMeta(
    'triggerAt',
  );
  @override
  late final GeneratedColumn<DateTime> triggerAt = GeneratedColumn<DateTime>(
    'trigger_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _offsetMinutesMeta = const VerificationMeta(
    'offsetMinutes',
  );
  @override
  late final GeneratedColumn<int> offsetMinutes = GeneratedColumn<int>(
    'offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _platformNotificationIdMeta =
      const VerificationMeta('platformNotificationId');
  @override
  late final GeneratedColumn<int> platformNotificationId = GeneratedColumn<int>(
    'platform_notification_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _snoozeCountMeta = const VerificationMeta(
    'snoozeCount',
  );
  @override
  late final GeneratedColumn<int> snoozeCount = GeneratedColumn<int>(
    'snooze_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    planId,
    triggerAt,
    offsetMinutes,
    platformNotificationId,
    status,
    snoozeCount,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('trigger_at')) {
      context.handle(
        _triggerAtMeta,
        triggerAt.isAcceptableOrUnknown(data['trigger_at']!, _triggerAtMeta),
      );
    } else if (isInserting) {
      context.missing(_triggerAtMeta);
    }
    if (data.containsKey('offset_minutes')) {
      context.handle(
        _offsetMinutesMeta,
        offsetMinutes.isAcceptableOrUnknown(
          data['offset_minutes']!,
          _offsetMinutesMeta,
        ),
      );
    }
    if (data.containsKey('platform_notification_id')) {
      context.handle(
        _platformNotificationIdMeta,
        platformNotificationId.isAcceptableOrUnknown(
          data['platform_notification_id']!,
          _platformNotificationIdMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('snooze_count')) {
      context.handle(
        _snoozeCountMeta,
        snoozeCount.isAcceptableOrUnknown(
          data['snooze_count']!,
          _snoozeCountMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_id'],
      )!,
      triggerAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}trigger_at'],
      )!,
      offsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}offset_minutes'],
      )!,
      platformNotificationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}platform_notification_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      snoozeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snooze_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final int id;
  final int planId;
  final DateTime triggerAt;
  final int offsetMinutes;
  final int? platformNotificationId;
  final String status;
  final int snoozeCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Reminder({
    required this.id,
    required this.planId,
    required this.triggerAt,
    required this.offsetMinutes,
    this.platformNotificationId,
    required this.status,
    required this.snoozeCount,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plan_id'] = Variable<int>(planId);
    map['trigger_at'] = Variable<DateTime>(triggerAt);
    map['offset_minutes'] = Variable<int>(offsetMinutes);
    if (!nullToAbsent || platformNotificationId != null) {
      map['platform_notification_id'] = Variable<int>(platformNotificationId);
    }
    map['status'] = Variable<String>(status);
    map['snooze_count'] = Variable<int>(snoozeCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      planId: Value(planId),
      triggerAt: Value(triggerAt),
      offsetMinutes: Value(offsetMinutes),
      platformNotificationId: platformNotificationId == null && nullToAbsent
          ? const Value.absent()
          : Value(platformNotificationId),
      status: Value(status),
      snoozeCount: Value(snoozeCount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Reminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      id: serializer.fromJson<int>(json['id']),
      planId: serializer.fromJson<int>(json['planId']),
      triggerAt: serializer.fromJson<DateTime>(json['triggerAt']),
      offsetMinutes: serializer.fromJson<int>(json['offsetMinutes']),
      platformNotificationId: serializer.fromJson<int?>(
        json['platformNotificationId'],
      ),
      status: serializer.fromJson<String>(json['status']),
      snoozeCount: serializer.fromJson<int>(json['snoozeCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'planId': serializer.toJson<int>(planId),
      'triggerAt': serializer.toJson<DateTime>(triggerAt),
      'offsetMinutes': serializer.toJson<int>(offsetMinutes),
      'platformNotificationId': serializer.toJson<int?>(platformNotificationId),
      'status': serializer.toJson<String>(status),
      'snoozeCount': serializer.toJson<int>(snoozeCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Reminder copyWith({
    int? id,
    int? planId,
    DateTime? triggerAt,
    int? offsetMinutes,
    Value<int?> platformNotificationId = const Value.absent(),
    String? status,
    int? snoozeCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Reminder(
    id: id ?? this.id,
    planId: planId ?? this.planId,
    triggerAt: triggerAt ?? this.triggerAt,
    offsetMinutes: offsetMinutes ?? this.offsetMinutes,
    platformNotificationId: platformNotificationId.present
        ? platformNotificationId.value
        : this.platformNotificationId,
    status: status ?? this.status,
    snoozeCount: snoozeCount ?? this.snoozeCount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      triggerAt: data.triggerAt.present ? data.triggerAt.value : this.triggerAt,
      offsetMinutes: data.offsetMinutes.present
          ? data.offsetMinutes.value
          : this.offsetMinutes,
      platformNotificationId: data.platformNotificationId.present
          ? data.platformNotificationId.value
          : this.platformNotificationId,
      status: data.status.present ? data.status.value : this.status,
      snoozeCount: data.snoozeCount.present
          ? data.snoozeCount.value
          : this.snoozeCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('triggerAt: $triggerAt, ')
          ..write('offsetMinutes: $offsetMinutes, ')
          ..write('platformNotificationId: $platformNotificationId, ')
          ..write('status: $status, ')
          ..write('snoozeCount: $snoozeCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    planId,
    triggerAt,
    offsetMinutes,
    platformNotificationId,
    status,
    snoozeCount,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.triggerAt == this.triggerAt &&
          other.offsetMinutes == this.offsetMinutes &&
          other.platformNotificationId == this.platformNotificationId &&
          other.status == this.status &&
          other.snoozeCount == this.snoozeCount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<int> id;
  final Value<int> planId;
  final Value<DateTime> triggerAt;
  final Value<int> offsetMinutes;
  final Value<int?> platformNotificationId;
  final Value<String> status;
  final Value<int> snoozeCount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.triggerAt = const Value.absent(),
    this.offsetMinutes = const Value.absent(),
    this.platformNotificationId = const Value.absent(),
    this.status = const Value.absent(),
    this.snoozeCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  RemindersCompanion.insert({
    this.id = const Value.absent(),
    required int planId,
    required DateTime triggerAt,
    this.offsetMinutes = const Value.absent(),
    this.platformNotificationId = const Value.absent(),
    this.status = const Value.absent(),
    this.snoozeCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : planId = Value(planId),
       triggerAt = Value(triggerAt);
  static Insertable<Reminder> custom({
    Expression<int>? id,
    Expression<int>? planId,
    Expression<DateTime>? triggerAt,
    Expression<int>? offsetMinutes,
    Expression<int>? platformNotificationId,
    Expression<String>? status,
    Expression<int>? snoozeCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (triggerAt != null) 'trigger_at': triggerAt,
      if (offsetMinutes != null) 'offset_minutes': offsetMinutes,
      if (platformNotificationId != null)
        'platform_notification_id': platformNotificationId,
      if (status != null) 'status': status,
      if (snoozeCount != null) 'snooze_count': snoozeCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  RemindersCompanion copyWith({
    Value<int>? id,
    Value<int>? planId,
    Value<DateTime>? triggerAt,
    Value<int>? offsetMinutes,
    Value<int?>? platformNotificationId,
    Value<String>? status,
    Value<int>? snoozeCount,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      triggerAt: triggerAt ?? this.triggerAt,
      offsetMinutes: offsetMinutes ?? this.offsetMinutes,
      platformNotificationId:
          platformNotificationId ?? this.platformNotificationId,
      status: status ?? this.status,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (triggerAt.present) {
      map['trigger_at'] = Variable<DateTime>(triggerAt.value);
    }
    if (offsetMinutes.present) {
      map['offset_minutes'] = Variable<int>(offsetMinutes.value);
    }
    if (platformNotificationId.present) {
      map['platform_notification_id'] = Variable<int>(
        platformNotificationId.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (snoozeCount.present) {
      map['snooze_count'] = Variable<int>(snoozeCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('triggerAt: $triggerAt, ')
          ..write('offsetMinutes: $offsetMinutes, ')
          ..write('platformNotificationId: $platformNotificationId, ')
          ..write('status: $status, ')
          ..write('snoozeCount: $snoozeCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PomodoroSessionsTable extends PomodoroSessions
    with TableInfo<$PomodoroSessionsTable, PomodoroSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PomodoroSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
    'plan_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plans (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _phaseMeta = const VerificationMeta('phase');
  @override
  late final GeneratedColumn<String> phase = GeneratedColumn<String>(
    'phase',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('focus'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('running'),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetEndAtMeta = const VerificationMeta(
    'targetEndAt',
  );
  @override
  late final GeneratedColumn<DateTime> targetEndAt = GeneratedColumn<DateTime>(
    'target_end_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pausedAtMeta = const VerificationMeta(
    'pausedAt',
  );
  @override
  late final GeneratedColumn<DateTime> pausedAt = GeneratedColumn<DateTime>(
    'paused_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pausedTotalMsMeta = const VerificationMeta(
    'pausedTotalMs',
  );
  @override
  late final GeneratedColumn<int> pausedTotalMs = GeneratedColumn<int>(
    'paused_total_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualDurationMsMeta = const VerificationMeta(
    'actualDurationMs',
  );
  @override
  late final GeneratedColumn<int> actualDurationMs = GeneratedColumn<int>(
    'actual_duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    planId,
    phase,
    status,
    startedAt,
    targetEndAt,
    pausedAt,
    pausedTotalMs,
    completedAt,
    actualDurationMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pomodoro_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PomodoroSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    }
    if (data.containsKey('phase')) {
      context.handle(
        _phaseMeta,
        phase.isAcceptableOrUnknown(data['phase']!, _phaseMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('target_end_at')) {
      context.handle(
        _targetEndAtMeta,
        targetEndAt.isAcceptableOrUnknown(
          data['target_end_at']!,
          _targetEndAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetEndAtMeta);
    }
    if (data.containsKey('paused_at')) {
      context.handle(
        _pausedAtMeta,
        pausedAt.isAcceptableOrUnknown(data['paused_at']!, _pausedAtMeta),
      );
    }
    if (data.containsKey('paused_total_ms')) {
      context.handle(
        _pausedTotalMsMeta,
        pausedTotalMs.isAcceptableOrUnknown(
          data['paused_total_ms']!,
          _pausedTotalMsMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('actual_duration_ms')) {
      context.handle(
        _actualDurationMsMeta,
        actualDurationMs.isAcceptableOrUnknown(
          data['actual_duration_ms']!,
          _actualDurationMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PomodoroSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PomodoroSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_id'],
      ),
      phase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phase'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      targetEndAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}target_end_at'],
      )!,
      pausedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paused_at'],
      ),
      pausedTotalMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paused_total_ms'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      actualDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_duration_ms'],
      )!,
    );
  }

  @override
  $PomodoroSessionsTable createAlias(String alias) {
    return $PomodoroSessionsTable(attachedDatabase, alias);
  }
}

class PomodoroSession extends DataClass implements Insertable<PomodoroSession> {
  final int id;
  final int? planId;
  final String phase;
  final String status;
  final DateTime startedAt;
  final DateTime targetEndAt;
  final DateTime? pausedAt;
  final int pausedTotalMs;
  final DateTime? completedAt;
  final int actualDurationMs;
  const PomodoroSession({
    required this.id,
    this.planId,
    required this.phase,
    required this.status,
    required this.startedAt,
    required this.targetEndAt,
    this.pausedAt,
    required this.pausedTotalMs,
    this.completedAt,
    required this.actualDurationMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || planId != null) {
      map['plan_id'] = Variable<int>(planId);
    }
    map['phase'] = Variable<String>(phase);
    map['status'] = Variable<String>(status);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['target_end_at'] = Variable<DateTime>(targetEndAt);
    if (!nullToAbsent || pausedAt != null) {
      map['paused_at'] = Variable<DateTime>(pausedAt);
    }
    map['paused_total_ms'] = Variable<int>(pausedTotalMs);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['actual_duration_ms'] = Variable<int>(actualDurationMs);
    return map;
  }

  PomodoroSessionsCompanion toCompanion(bool nullToAbsent) {
    return PomodoroSessionsCompanion(
      id: Value(id),
      planId: planId == null && nullToAbsent
          ? const Value.absent()
          : Value(planId),
      phase: Value(phase),
      status: Value(status),
      startedAt: Value(startedAt),
      targetEndAt: Value(targetEndAt),
      pausedAt: pausedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pausedAt),
      pausedTotalMs: Value(pausedTotalMs),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      actualDurationMs: Value(actualDurationMs),
    );
  }

  factory PomodoroSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PomodoroSession(
      id: serializer.fromJson<int>(json['id']),
      planId: serializer.fromJson<int?>(json['planId']),
      phase: serializer.fromJson<String>(json['phase']),
      status: serializer.fromJson<String>(json['status']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      targetEndAt: serializer.fromJson<DateTime>(json['targetEndAt']),
      pausedAt: serializer.fromJson<DateTime?>(json['pausedAt']),
      pausedTotalMs: serializer.fromJson<int>(json['pausedTotalMs']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      actualDurationMs: serializer.fromJson<int>(json['actualDurationMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'planId': serializer.toJson<int?>(planId),
      'phase': serializer.toJson<String>(phase),
      'status': serializer.toJson<String>(status),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'targetEndAt': serializer.toJson<DateTime>(targetEndAt),
      'pausedAt': serializer.toJson<DateTime?>(pausedAt),
      'pausedTotalMs': serializer.toJson<int>(pausedTotalMs),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'actualDurationMs': serializer.toJson<int>(actualDurationMs),
    };
  }

  PomodoroSession copyWith({
    int? id,
    Value<int?> planId = const Value.absent(),
    String? phase,
    String? status,
    DateTime? startedAt,
    DateTime? targetEndAt,
    Value<DateTime?> pausedAt = const Value.absent(),
    int? pausedTotalMs,
    Value<DateTime?> completedAt = const Value.absent(),
    int? actualDurationMs,
  }) => PomodoroSession(
    id: id ?? this.id,
    planId: planId.present ? planId.value : this.planId,
    phase: phase ?? this.phase,
    status: status ?? this.status,
    startedAt: startedAt ?? this.startedAt,
    targetEndAt: targetEndAt ?? this.targetEndAt,
    pausedAt: pausedAt.present ? pausedAt.value : this.pausedAt,
    pausedTotalMs: pausedTotalMs ?? this.pausedTotalMs,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    actualDurationMs: actualDurationMs ?? this.actualDurationMs,
  );
  PomodoroSession copyWithCompanion(PomodoroSessionsCompanion data) {
    return PomodoroSession(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      phase: data.phase.present ? data.phase.value : this.phase,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      targetEndAt: data.targetEndAt.present
          ? data.targetEndAt.value
          : this.targetEndAt,
      pausedAt: data.pausedAt.present ? data.pausedAt.value : this.pausedAt,
      pausedTotalMs: data.pausedTotalMs.present
          ? data.pausedTotalMs.value
          : this.pausedTotalMs,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      actualDurationMs: data.actualDurationMs.present
          ? data.actualDurationMs.value
          : this.actualDurationMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PomodoroSession(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('phase: $phase, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('targetEndAt: $targetEndAt, ')
          ..write('pausedAt: $pausedAt, ')
          ..write('pausedTotalMs: $pausedTotalMs, ')
          ..write('completedAt: $completedAt, ')
          ..write('actualDurationMs: $actualDurationMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    planId,
    phase,
    status,
    startedAt,
    targetEndAt,
    pausedAt,
    pausedTotalMs,
    completedAt,
    actualDurationMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PomodoroSession &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.phase == this.phase &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.targetEndAt == this.targetEndAt &&
          other.pausedAt == this.pausedAt &&
          other.pausedTotalMs == this.pausedTotalMs &&
          other.completedAt == this.completedAt &&
          other.actualDurationMs == this.actualDurationMs);
}

class PomodoroSessionsCompanion extends UpdateCompanion<PomodoroSession> {
  final Value<int> id;
  final Value<int?> planId;
  final Value<String> phase;
  final Value<String> status;
  final Value<DateTime> startedAt;
  final Value<DateTime> targetEndAt;
  final Value<DateTime?> pausedAt;
  final Value<int> pausedTotalMs;
  final Value<DateTime?> completedAt;
  final Value<int> actualDurationMs;
  const PomodoroSessionsCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.phase = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.targetEndAt = const Value.absent(),
    this.pausedAt = const Value.absent(),
    this.pausedTotalMs = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.actualDurationMs = const Value.absent(),
  });
  PomodoroSessionsCompanion.insert({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.phase = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime startedAt,
    required DateTime targetEndAt,
    this.pausedAt = const Value.absent(),
    this.pausedTotalMs = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.actualDurationMs = const Value.absent(),
  }) : startedAt = Value(startedAt),
       targetEndAt = Value(targetEndAt);
  static Insertable<PomodoroSession> custom({
    Expression<int>? id,
    Expression<int>? planId,
    Expression<String>? phase,
    Expression<String>? status,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? targetEndAt,
    Expression<DateTime>? pausedAt,
    Expression<int>? pausedTotalMs,
    Expression<DateTime>? completedAt,
    Expression<int>? actualDurationMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (phase != null) 'phase': phase,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (targetEndAt != null) 'target_end_at': targetEndAt,
      if (pausedAt != null) 'paused_at': pausedAt,
      if (pausedTotalMs != null) 'paused_total_ms': pausedTotalMs,
      if (completedAt != null) 'completed_at': completedAt,
      if (actualDurationMs != null) 'actual_duration_ms': actualDurationMs,
    });
  }

  PomodoroSessionsCompanion copyWith({
    Value<int>? id,
    Value<int?>? planId,
    Value<String>? phase,
    Value<String>? status,
    Value<DateTime>? startedAt,
    Value<DateTime>? targetEndAt,
    Value<DateTime?>? pausedAt,
    Value<int>? pausedTotalMs,
    Value<DateTime?>? completedAt,
    Value<int>? actualDurationMs,
  }) {
    return PomodoroSessionsCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      phase: phase ?? this.phase,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      targetEndAt: targetEndAt ?? this.targetEndAt,
      pausedAt: pausedAt ?? this.pausedAt,
      pausedTotalMs: pausedTotalMs ?? this.pausedTotalMs,
      completedAt: completedAt ?? this.completedAt,
      actualDurationMs: actualDurationMs ?? this.actualDurationMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (phase.present) {
      map['phase'] = Variable<String>(phase.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (targetEndAt.present) {
      map['target_end_at'] = Variable<DateTime>(targetEndAt.value);
    }
    if (pausedAt.present) {
      map['paused_at'] = Variable<DateTime>(pausedAt.value);
    }
    if (pausedTotalMs.present) {
      map['paused_total_ms'] = Variable<int>(pausedTotalMs.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (actualDurationMs.present) {
      map['actual_duration_ms'] = Variable<int>(actualDurationMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PomodoroSessionsCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('phase: $phase, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('targetEndAt: $targetEndAt, ')
          ..write('pausedAt: $pausedAt, ')
          ..write('pausedTotalMs: $pausedTotalMs, ')
          ..write('completedAt: $completedAt, ')
          ..write('actualDurationMs: $actualDurationMs')
          ..write(')'))
        .toString();
  }
}

class $ImportRecordsTable extends ImportRecords
    with TableInfo<$ImportRecordsTable, ImportRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _batchUuidMeta = const VerificationMeta(
    'batchUuid',
  );
  @override
  late final GeneratedColumn<String> batchUuid = GeneratedColumn<String>(
    'batch_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceFingerprintMeta = const VerificationMeta(
    'sourceFingerprint',
  );
  @override
  late final GeneratedColumn<String> sourceFingerprint =
      GeneratedColumn<String>(
        'source_fingerprint',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetWordBookIdMeta = const VerificationMeta(
    'targetWordBookId',
  );
  @override
  late final GeneratedColumn<int> targetWordBookId = GeneratedColumn<int>(
    'target_word_book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES word_books (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalRowsMeta = const VerificationMeta(
    'totalRows',
  );
  @override
  late final GeneratedColumn<int> totalRows = GeneratedColumn<int>(
    'total_rows',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _successCountMeta = const VerificationMeta(
    'successCount',
  );
  @override
  late final GeneratedColumn<int> successCount = GeneratedColumn<int>(
    'success_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _skippedCountMeta = const VerificationMeta(
    'skippedCount',
  );
  @override
  late final GeneratedColumn<int> skippedCount = GeneratedColumn<int>(
    'skipped_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _failedCountMeta = const VerificationMeta(
    'failedCount',
  );
  @override
  late final GeneratedColumn<int> failedCount = GeneratedColumn<int>(
    'failed_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('running'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    batchUuid,
    fileName,
    sourceFingerprint,
    sourceType,
    targetWordBookId,
    startedAt,
    finishedAt,
    totalRows,
    successCount,
    skippedCount,
    failedCount,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'import_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('batch_uuid')) {
      context.handle(
        _batchUuidMeta,
        batchUuid.isAcceptableOrUnknown(data['batch_uuid']!, _batchUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_batchUuidMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('source_fingerprint')) {
      context.handle(
        _sourceFingerprintMeta,
        sourceFingerprint.isAcceptableOrUnknown(
          data['source_fingerprint']!,
          _sourceFingerprintMeta,
        ),
      );
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('target_word_book_id')) {
      context.handle(
        _targetWordBookIdMeta,
        targetWordBookId.isAcceptableOrUnknown(
          data['target_word_book_id']!,
          _targetWordBookIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetWordBookIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('total_rows')) {
      context.handle(
        _totalRowsMeta,
        totalRows.isAcceptableOrUnknown(data['total_rows']!, _totalRowsMeta),
      );
    }
    if (data.containsKey('success_count')) {
      context.handle(
        _successCountMeta,
        successCount.isAcceptableOrUnknown(
          data['success_count']!,
          _successCountMeta,
        ),
      );
    }
    if (data.containsKey('skipped_count')) {
      context.handle(
        _skippedCountMeta,
        skippedCount.isAcceptableOrUnknown(
          data['skipped_count']!,
          _skippedCountMeta,
        ),
      );
    }
    if (data.containsKey('failed_count')) {
      context.handle(
        _failedCountMeta,
        failedCount.isAcceptableOrUnknown(
          data['failed_count']!,
          _failedCountMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImportRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      batchUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_uuid'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      sourceFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_fingerprint'],
      ),
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      targetWordBookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_word_book_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
      totalRows: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_rows'],
      )!,
      successCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}success_count'],
      )!,
      skippedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skipped_count'],
      )!,
      failedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}failed_count'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $ImportRecordsTable createAlias(String alias) {
    return $ImportRecordsTable(attachedDatabase, alias);
  }
}

class ImportRecord extends DataClass implements Insertable<ImportRecord> {
  final int id;
  final String batchUuid;
  final String fileName;
  final String? sourceFingerprint;
  final String sourceType;
  final int targetWordBookId;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int totalRows;
  final int successCount;
  final int skippedCount;
  final int failedCount;
  final String status;
  const ImportRecord({
    required this.id,
    required this.batchUuid,
    required this.fileName,
    this.sourceFingerprint,
    required this.sourceType,
    required this.targetWordBookId,
    required this.startedAt,
    this.finishedAt,
    required this.totalRows,
    required this.successCount,
    required this.skippedCount,
    required this.failedCount,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['batch_uuid'] = Variable<String>(batchUuid);
    map['file_name'] = Variable<String>(fileName);
    if (!nullToAbsent || sourceFingerprint != null) {
      map['source_fingerprint'] = Variable<String>(sourceFingerprint);
    }
    map['source_type'] = Variable<String>(sourceType);
    map['target_word_book_id'] = Variable<int>(targetWordBookId);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    map['total_rows'] = Variable<int>(totalRows);
    map['success_count'] = Variable<int>(successCount);
    map['skipped_count'] = Variable<int>(skippedCount);
    map['failed_count'] = Variable<int>(failedCount);
    map['status'] = Variable<String>(status);
    return map;
  }

  ImportRecordsCompanion toCompanion(bool nullToAbsent) {
    return ImportRecordsCompanion(
      id: Value(id),
      batchUuid: Value(batchUuid),
      fileName: Value(fileName),
      sourceFingerprint: sourceFingerprint == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceFingerprint),
      sourceType: Value(sourceType),
      targetWordBookId: Value(targetWordBookId),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      totalRows: Value(totalRows),
      successCount: Value(successCount),
      skippedCount: Value(skippedCount),
      failedCount: Value(failedCount),
      status: Value(status),
    );
  }

  factory ImportRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportRecord(
      id: serializer.fromJson<int>(json['id']),
      batchUuid: serializer.fromJson<String>(json['batchUuid']),
      fileName: serializer.fromJson<String>(json['fileName']),
      sourceFingerprint: serializer.fromJson<String?>(
        json['sourceFingerprint'],
      ),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      targetWordBookId: serializer.fromJson<int>(json['targetWordBookId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      totalRows: serializer.fromJson<int>(json['totalRows']),
      successCount: serializer.fromJson<int>(json['successCount']),
      skippedCount: serializer.fromJson<int>(json['skippedCount']),
      failedCount: serializer.fromJson<int>(json['failedCount']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'batchUuid': serializer.toJson<String>(batchUuid),
      'fileName': serializer.toJson<String>(fileName),
      'sourceFingerprint': serializer.toJson<String?>(sourceFingerprint),
      'sourceType': serializer.toJson<String>(sourceType),
      'targetWordBookId': serializer.toJson<int>(targetWordBookId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'totalRows': serializer.toJson<int>(totalRows),
      'successCount': serializer.toJson<int>(successCount),
      'skippedCount': serializer.toJson<int>(skippedCount),
      'failedCount': serializer.toJson<int>(failedCount),
      'status': serializer.toJson<String>(status),
    };
  }

  ImportRecord copyWith({
    int? id,
    String? batchUuid,
    String? fileName,
    Value<String?> sourceFingerprint = const Value.absent(),
    String? sourceType,
    int? targetWordBookId,
    DateTime? startedAt,
    Value<DateTime?> finishedAt = const Value.absent(),
    int? totalRows,
    int? successCount,
    int? skippedCount,
    int? failedCount,
    String? status,
  }) => ImportRecord(
    id: id ?? this.id,
    batchUuid: batchUuid ?? this.batchUuid,
    fileName: fileName ?? this.fileName,
    sourceFingerprint: sourceFingerprint.present
        ? sourceFingerprint.value
        : this.sourceFingerprint,
    sourceType: sourceType ?? this.sourceType,
    targetWordBookId: targetWordBookId ?? this.targetWordBookId,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    totalRows: totalRows ?? this.totalRows,
    successCount: successCount ?? this.successCount,
    skippedCount: skippedCount ?? this.skippedCount,
    failedCount: failedCount ?? this.failedCount,
    status: status ?? this.status,
  );
  ImportRecord copyWithCompanion(ImportRecordsCompanion data) {
    return ImportRecord(
      id: data.id.present ? data.id.value : this.id,
      batchUuid: data.batchUuid.present ? data.batchUuid.value : this.batchUuid,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      sourceFingerprint: data.sourceFingerprint.present
          ? data.sourceFingerprint.value
          : this.sourceFingerprint,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      targetWordBookId: data.targetWordBookId.present
          ? data.targetWordBookId.value
          : this.targetWordBookId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      totalRows: data.totalRows.present ? data.totalRows.value : this.totalRows,
      successCount: data.successCount.present
          ? data.successCount.value
          : this.successCount,
      skippedCount: data.skippedCount.present
          ? data.skippedCount.value
          : this.skippedCount,
      failedCount: data.failedCount.present
          ? data.failedCount.value
          : this.failedCount,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportRecord(')
          ..write('id: $id, ')
          ..write('batchUuid: $batchUuid, ')
          ..write('fileName: $fileName, ')
          ..write('sourceFingerprint: $sourceFingerprint, ')
          ..write('sourceType: $sourceType, ')
          ..write('targetWordBookId: $targetWordBookId, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('totalRows: $totalRows, ')
          ..write('successCount: $successCount, ')
          ..write('skippedCount: $skippedCount, ')
          ..write('failedCount: $failedCount, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    batchUuid,
    fileName,
    sourceFingerprint,
    sourceType,
    targetWordBookId,
    startedAt,
    finishedAt,
    totalRows,
    successCount,
    skippedCount,
    failedCount,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportRecord &&
          other.id == this.id &&
          other.batchUuid == this.batchUuid &&
          other.fileName == this.fileName &&
          other.sourceFingerprint == this.sourceFingerprint &&
          other.sourceType == this.sourceType &&
          other.targetWordBookId == this.targetWordBookId &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.totalRows == this.totalRows &&
          other.successCount == this.successCount &&
          other.skippedCount == this.skippedCount &&
          other.failedCount == this.failedCount &&
          other.status == this.status);
}

class ImportRecordsCompanion extends UpdateCompanion<ImportRecord> {
  final Value<int> id;
  final Value<String> batchUuid;
  final Value<String> fileName;
  final Value<String?> sourceFingerprint;
  final Value<String> sourceType;
  final Value<int> targetWordBookId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<int> totalRows;
  final Value<int> successCount;
  final Value<int> skippedCount;
  final Value<int> failedCount;
  final Value<String> status;
  const ImportRecordsCompanion({
    this.id = const Value.absent(),
    this.batchUuid = const Value.absent(),
    this.fileName = const Value.absent(),
    this.sourceFingerprint = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.targetWordBookId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.totalRows = const Value.absent(),
    this.successCount = const Value.absent(),
    this.skippedCount = const Value.absent(),
    this.failedCount = const Value.absent(),
    this.status = const Value.absent(),
  });
  ImportRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String batchUuid,
    required String fileName,
    this.sourceFingerprint = const Value.absent(),
    required String sourceType,
    required int targetWordBookId,
    required DateTime startedAt,
    this.finishedAt = const Value.absent(),
    this.totalRows = const Value.absent(),
    this.successCount = const Value.absent(),
    this.skippedCount = const Value.absent(),
    this.failedCount = const Value.absent(),
    this.status = const Value.absent(),
  }) : batchUuid = Value(batchUuid),
       fileName = Value(fileName),
       sourceType = Value(sourceType),
       targetWordBookId = Value(targetWordBookId),
       startedAt = Value(startedAt);
  static Insertable<ImportRecord> custom({
    Expression<int>? id,
    Expression<String>? batchUuid,
    Expression<String>? fileName,
    Expression<String>? sourceFingerprint,
    Expression<String>? sourceType,
    Expression<int>? targetWordBookId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<int>? totalRows,
    Expression<int>? successCount,
    Expression<int>? skippedCount,
    Expression<int>? failedCount,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (batchUuid != null) 'batch_uuid': batchUuid,
      if (fileName != null) 'file_name': fileName,
      if (sourceFingerprint != null) 'source_fingerprint': sourceFingerprint,
      if (sourceType != null) 'source_type': sourceType,
      if (targetWordBookId != null) 'target_word_book_id': targetWordBookId,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (totalRows != null) 'total_rows': totalRows,
      if (successCount != null) 'success_count': successCount,
      if (skippedCount != null) 'skipped_count': skippedCount,
      if (failedCount != null) 'failed_count': failedCount,
      if (status != null) 'status': status,
    });
  }

  ImportRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? batchUuid,
    Value<String>? fileName,
    Value<String?>? sourceFingerprint,
    Value<String>? sourceType,
    Value<int>? targetWordBookId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<int>? totalRows,
    Value<int>? successCount,
    Value<int>? skippedCount,
    Value<int>? failedCount,
    Value<String>? status,
  }) {
    return ImportRecordsCompanion(
      id: id ?? this.id,
      batchUuid: batchUuid ?? this.batchUuid,
      fileName: fileName ?? this.fileName,
      sourceFingerprint: sourceFingerprint ?? this.sourceFingerprint,
      sourceType: sourceType ?? this.sourceType,
      targetWordBookId: targetWordBookId ?? this.targetWordBookId,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      totalRows: totalRows ?? this.totalRows,
      successCount: successCount ?? this.successCount,
      skippedCount: skippedCount ?? this.skippedCount,
      failedCount: failedCount ?? this.failedCount,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (batchUuid.present) {
      map['batch_uuid'] = Variable<String>(batchUuid.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (sourceFingerprint.present) {
      map['source_fingerprint'] = Variable<String>(sourceFingerprint.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (targetWordBookId.present) {
      map['target_word_book_id'] = Variable<int>(targetWordBookId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (totalRows.present) {
      map['total_rows'] = Variable<int>(totalRows.value);
    }
    if (successCount.present) {
      map['success_count'] = Variable<int>(successCount.value);
    }
    if (skippedCount.present) {
      map['skipped_count'] = Variable<int>(skippedCount.value);
    }
    if (failedCount.present) {
      map['failed_count'] = Variable<int>(failedCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportRecordsCompanion(')
          ..write('id: $id, ')
          ..write('batchUuid: $batchUuid, ')
          ..write('fileName: $fileName, ')
          ..write('sourceFingerprint: $sourceFingerprint, ')
          ..write('sourceType: $sourceType, ')
          ..write('targetWordBookId: $targetWordBookId, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('totalRows: $totalRows, ')
          ..write('successCount: $successCount, ')
          ..write('skippedCount: $skippedCount, ')
          ..write('failedCount: $failedCount, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $ImportErrorsTable extends ImportErrors
    with TableInfo<$ImportErrorsTable, ImportError> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportErrorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _importRecordIdMeta = const VerificationMeta(
    'importRecordId',
  );
  @override
  late final GeneratedColumn<int> importRecordId = GeneratedColumn<int>(
    'import_record_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES import_records (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceRowMeta = const VerificationMeta(
    'sourceRow',
  );
  @override
  late final GeneratedColumn<int> sourceRow = GeneratedColumn<int>(
    'source_row',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorCodeMeta = const VerificationMeta(
    'errorCode',
  );
  @override
  late final GeneratedColumn<String> errorCode = GeneratedColumn<String>(
    'error_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawDataMeta = const VerificationMeta(
    'rawData',
  );
  @override
  late final GeneratedColumn<String> rawData = GeneratedColumn<String>(
    'raw_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    importRecordId,
    sourceRow,
    errorCode,
    message,
    rawData,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'import_errors';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportError> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('import_record_id')) {
      context.handle(
        _importRecordIdMeta,
        importRecordId.isAcceptableOrUnknown(
          data['import_record_id']!,
          _importRecordIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_importRecordIdMeta);
    }
    if (data.containsKey('source_row')) {
      context.handle(
        _sourceRowMeta,
        sourceRow.isAcceptableOrUnknown(data['source_row']!, _sourceRowMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceRowMeta);
    }
    if (data.containsKey('error_code')) {
      context.handle(
        _errorCodeMeta,
        errorCode.isAcceptableOrUnknown(data['error_code']!, _errorCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_errorCodeMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('raw_data')) {
      context.handle(
        _rawDataMeta,
        rawData.isAcceptableOrUnknown(data['raw_data']!, _rawDataMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImportError map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportError(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      importRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}import_record_id'],
      )!,
      sourceRow: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_row'],
      )!,
      errorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_code'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      rawData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_data'],
      ),
    );
  }

  @override
  $ImportErrorsTable createAlias(String alias) {
    return $ImportErrorsTable(attachedDatabase, alias);
  }
}

class ImportError extends DataClass implements Insertable<ImportError> {
  final int id;
  final int importRecordId;
  final int sourceRow;
  final String errorCode;
  final String message;
  final String? rawData;
  const ImportError({
    required this.id,
    required this.importRecordId,
    required this.sourceRow,
    required this.errorCode,
    required this.message,
    this.rawData,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['import_record_id'] = Variable<int>(importRecordId);
    map['source_row'] = Variable<int>(sourceRow);
    map['error_code'] = Variable<String>(errorCode);
    map['message'] = Variable<String>(message);
    if (!nullToAbsent || rawData != null) {
      map['raw_data'] = Variable<String>(rawData);
    }
    return map;
  }

  ImportErrorsCompanion toCompanion(bool nullToAbsent) {
    return ImportErrorsCompanion(
      id: Value(id),
      importRecordId: Value(importRecordId),
      sourceRow: Value(sourceRow),
      errorCode: Value(errorCode),
      message: Value(message),
      rawData: rawData == null && nullToAbsent
          ? const Value.absent()
          : Value(rawData),
    );
  }

  factory ImportError.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportError(
      id: serializer.fromJson<int>(json['id']),
      importRecordId: serializer.fromJson<int>(json['importRecordId']),
      sourceRow: serializer.fromJson<int>(json['sourceRow']),
      errorCode: serializer.fromJson<String>(json['errorCode']),
      message: serializer.fromJson<String>(json['message']),
      rawData: serializer.fromJson<String?>(json['rawData']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'importRecordId': serializer.toJson<int>(importRecordId),
      'sourceRow': serializer.toJson<int>(sourceRow),
      'errorCode': serializer.toJson<String>(errorCode),
      'message': serializer.toJson<String>(message),
      'rawData': serializer.toJson<String?>(rawData),
    };
  }

  ImportError copyWith({
    int? id,
    int? importRecordId,
    int? sourceRow,
    String? errorCode,
    String? message,
    Value<String?> rawData = const Value.absent(),
  }) => ImportError(
    id: id ?? this.id,
    importRecordId: importRecordId ?? this.importRecordId,
    sourceRow: sourceRow ?? this.sourceRow,
    errorCode: errorCode ?? this.errorCode,
    message: message ?? this.message,
    rawData: rawData.present ? rawData.value : this.rawData,
  );
  ImportError copyWithCompanion(ImportErrorsCompanion data) {
    return ImportError(
      id: data.id.present ? data.id.value : this.id,
      importRecordId: data.importRecordId.present
          ? data.importRecordId.value
          : this.importRecordId,
      sourceRow: data.sourceRow.present ? data.sourceRow.value : this.sourceRow,
      errorCode: data.errorCode.present ? data.errorCode.value : this.errorCode,
      message: data.message.present ? data.message.value : this.message,
      rawData: data.rawData.present ? data.rawData.value : this.rawData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportError(')
          ..write('id: $id, ')
          ..write('importRecordId: $importRecordId, ')
          ..write('sourceRow: $sourceRow, ')
          ..write('errorCode: $errorCode, ')
          ..write('message: $message, ')
          ..write('rawData: $rawData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, importRecordId, sourceRow, errorCode, message, rawData);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportError &&
          other.id == this.id &&
          other.importRecordId == this.importRecordId &&
          other.sourceRow == this.sourceRow &&
          other.errorCode == this.errorCode &&
          other.message == this.message &&
          other.rawData == this.rawData);
}

class ImportErrorsCompanion extends UpdateCompanion<ImportError> {
  final Value<int> id;
  final Value<int> importRecordId;
  final Value<int> sourceRow;
  final Value<String> errorCode;
  final Value<String> message;
  final Value<String?> rawData;
  const ImportErrorsCompanion({
    this.id = const Value.absent(),
    this.importRecordId = const Value.absent(),
    this.sourceRow = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.message = const Value.absent(),
    this.rawData = const Value.absent(),
  });
  ImportErrorsCompanion.insert({
    this.id = const Value.absent(),
    required int importRecordId,
    required int sourceRow,
    required String errorCode,
    required String message,
    this.rawData = const Value.absent(),
  }) : importRecordId = Value(importRecordId),
       sourceRow = Value(sourceRow),
       errorCode = Value(errorCode),
       message = Value(message);
  static Insertable<ImportError> custom({
    Expression<int>? id,
    Expression<int>? importRecordId,
    Expression<int>? sourceRow,
    Expression<String>? errorCode,
    Expression<String>? message,
    Expression<String>? rawData,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (importRecordId != null) 'import_record_id': importRecordId,
      if (sourceRow != null) 'source_row': sourceRow,
      if (errorCode != null) 'error_code': errorCode,
      if (message != null) 'message': message,
      if (rawData != null) 'raw_data': rawData,
    });
  }

  ImportErrorsCompanion copyWith({
    Value<int>? id,
    Value<int>? importRecordId,
    Value<int>? sourceRow,
    Value<String>? errorCode,
    Value<String>? message,
    Value<String?>? rawData,
  }) {
    return ImportErrorsCompanion(
      id: id ?? this.id,
      importRecordId: importRecordId ?? this.importRecordId,
      sourceRow: sourceRow ?? this.sourceRow,
      errorCode: errorCode ?? this.errorCode,
      message: message ?? this.message,
      rawData: rawData ?? this.rawData,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (importRecordId.present) {
      map['import_record_id'] = Variable<int>(importRecordId.value);
    }
    if (sourceRow.present) {
      map['source_row'] = Variable<int>(sourceRow.value);
    }
    if (errorCode.present) {
      map['error_code'] = Variable<String>(errorCode.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (rawData.present) {
      map['raw_data'] = Variable<String>(rawData.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportErrorsCompanion(')
          ..write('id: $id, ')
          ..write('importRecordId: $importRecordId, ')
          ..write('sourceRow: $sourceRow, ')
          ..write('errorCode: $errorCode, ')
          ..write('message: $message, ')
          ..write('rawData: $rawData')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppSetting({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSetting copyWith({String? key, String? value, DateTime? updatedAt}) =>
      AppSetting(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WordBooksTable wordBooks = $WordBooksTable(this);
  late final $WordsTable words = $WordsTable(this);
  late final $WordBookItemsTable wordBookItems = $WordBookItemsTable(this);
  late final $ReviewSchedulesTable reviewSchedules = $ReviewSchedulesTable(
    this,
  );
  late final $ReviewRecordsTable reviewRecords = $ReviewRecordsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $CourseSchedulesTable courseSchedules = $CourseSchedulesTable(
    this,
  );
  late final $PlansTable plans = $PlansTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $PomodoroSessionsTable pomodoroSessions = $PomodoroSessionsTable(
    this,
  );
  late final $ImportRecordsTable importRecords = $ImportRecordsTable(this);
  late final $ImportErrorsTable importErrors = $ImportErrorsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    wordBooks,
    words,
    wordBookItems,
    reviewSchedules,
    reviewRecords,
    categories,
    courseSchedules,
    plans,
    reminders,
    pomodoroSessions,
    importRecords,
    importErrors,
    appSettings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'word_books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('word_book_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'words',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('word_book_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'word_book_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('review_schedules', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'word_book_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('review_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('plans', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'word_books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('plans', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'course_schedules',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('plans', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'plans',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reminders', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'plans',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pomodoro_sessions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'word_books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('import_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'import_records',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('import_errors', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$WordBooksTableCreateCompanionBuilder =
    WordBooksCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> description,
      Value<int> dailyNewLimit,
      Value<int> dailyReviewLimit,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$WordBooksTableUpdateCompanionBuilder =
    WordBooksCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> description,
      Value<int> dailyNewLimit,
      Value<int> dailyReviewLimit,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
    });

final class $$WordBooksTableReferences
    extends BaseReferences<_$AppDatabase, $WordBooksTable, WordBook> {
  $$WordBooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WordBookItemsTable, List<WordBookItem>>
  _wordBookItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordBookItems,
    aliasName: 'word_books__id__word_book_items__word_book_id',
  );

  $$WordBookItemsTableProcessedTableManager get wordBookItemsRefs {
    final manager = $$WordBookItemsTableTableManager(
      $_db,
      $_db.wordBookItems,
    ).filter((f) => f.wordBookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordBookItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlansTable, List<Plan>> _plansRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.plans,
    aliasName: 'word_books__id__plans__word_book_id',
  );

  $$PlansTableProcessedTableManager get plansRefs {
    final manager = $$PlansTableTableManager(
      $_db,
      $_db.plans,
    ).filter((f) => f.wordBookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_plansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ImportRecordsTable, List<ImportRecord>>
  _importRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.importRecords,
    aliasName: 'word_books__id__import_records__target_word_book_id',
  );

  $$ImportRecordsTableProcessedTableManager get importRecordsRefs {
    final manager = $$ImportRecordsTableTableManager(
      $_db,
      $_db.importRecords,
    ).filter((f) => f.targetWordBookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_importRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WordBooksTableFilterComposer
    extends Composer<_$AppDatabase, $WordBooksTable> {
  $$WordBooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyNewLimit => $composableBuilder(
    column: $table.dailyNewLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyReviewLimit => $composableBuilder(
    column: $table.dailyReviewLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> wordBookItemsRefs(
    Expression<bool> Function($$WordBookItemsTableFilterComposer f) f,
  ) {
    final $$WordBookItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordBookItems,
      getReferencedColumn: (t) => t.wordBookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordBookItemsTableFilterComposer(
            $db: $db,
            $table: $db.wordBookItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> plansRefs(
    Expression<bool> Function($$PlansTableFilterComposer f) f,
  ) {
    final $$PlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.wordBookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableFilterComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> importRecordsRefs(
    Expression<bool> Function($$ImportRecordsTableFilterComposer f) f,
  ) {
    final $$ImportRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importRecords,
      getReferencedColumn: (t) => t.targetWordBookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportRecordsTableFilterComposer(
            $db: $db,
            $table: $db.importRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordBooksTableOrderingComposer
    extends Composer<_$AppDatabase, $WordBooksTable> {
  $$WordBooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyNewLimit => $composableBuilder(
    column: $table.dailyNewLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyReviewLimit => $composableBuilder(
    column: $table.dailyReviewLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WordBooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordBooksTable> {
  $$WordBooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailyNewLimit => $composableBuilder(
    column: $table.dailyNewLimit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailyReviewLimit => $composableBuilder(
    column: $table.dailyReviewLimit,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> wordBookItemsRefs<T extends Object>(
    Expression<T> Function($$WordBookItemsTableAnnotationComposer a) f,
  ) {
    final $$WordBookItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordBookItems,
      getReferencedColumn: (t) => t.wordBookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordBookItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.wordBookItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> plansRefs<T extends Object>(
    Expression<T> Function($$PlansTableAnnotationComposer a) f,
  ) {
    final $$PlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.wordBookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableAnnotationComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> importRecordsRefs<T extends Object>(
    Expression<T> Function($$ImportRecordsTableAnnotationComposer a) f,
  ) {
    final $$ImportRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importRecords,
      getReferencedColumn: (t) => t.targetWordBookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.importRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordBooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordBooksTable,
          WordBook,
          $$WordBooksTableFilterComposer,
          $$WordBooksTableOrderingComposer,
          $$WordBooksTableAnnotationComposer,
          $$WordBooksTableCreateCompanionBuilder,
          $$WordBooksTableUpdateCompanionBuilder,
          (WordBook, $$WordBooksTableReferences),
          WordBook,
          PrefetchHooks Function({
            bool wordBookItemsRefs,
            bool plansRefs,
            bool importRecordsRefs,
          })
        > {
  $$WordBooksTableTableManager(_$AppDatabase db, $WordBooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordBooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordBooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordBooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> dailyNewLimit = const Value.absent(),
                Value<int> dailyReviewLimit = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => WordBooksCompanion(
                id: id,
                name: name,
                description: description,
                dailyNewLimit: dailyNewLimit,
                dailyReviewLimit: dailyReviewLimit,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                Value<int> dailyNewLimit = const Value.absent(),
                Value<int> dailyReviewLimit = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => WordBooksCompanion.insert(
                id: id,
                name: name,
                description: description,
                dailyNewLimit: dailyNewLimit,
                dailyReviewLimit: dailyReviewLimit,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WordBooksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                wordBookItemsRefs = false,
                plansRefs = false,
                importRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (wordBookItemsRefs) db.wordBookItems,
                    if (plansRefs) db.plans,
                    if (importRecordsRefs) db.importRecords,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (wordBookItemsRefs)
                        await $_getPrefetchedData<
                          WordBook,
                          $WordBooksTable,
                          WordBookItem
                        >(
                          currentTable: table,
                          referencedTable: $$WordBooksTableReferences
                              ._wordBookItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordBooksTableReferences(
                                db,
                                table,
                                p0,
                              ).wordBookItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wordBookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (plansRefs)
                        await $_getPrefetchedData<
                          WordBook,
                          $WordBooksTable,
                          Plan
                        >(
                          currentTable: table,
                          referencedTable: $$WordBooksTableReferences
                              ._plansRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordBooksTableReferences(
                                db,
                                table,
                                p0,
                              ).plansRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wordBookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (importRecordsRefs)
                        await $_getPrefetchedData<
                          WordBook,
                          $WordBooksTable,
                          ImportRecord
                        >(
                          currentTable: table,
                          referencedTable: $$WordBooksTableReferences
                              ._importRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordBooksTableReferences(
                                db,
                                table,
                                p0,
                              ).importRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.targetWordBookId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WordBooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordBooksTable,
      WordBook,
      $$WordBooksTableFilterComposer,
      $$WordBooksTableOrderingComposer,
      $$WordBooksTableAnnotationComposer,
      $$WordBooksTableCreateCompanionBuilder,
      $$WordBooksTableUpdateCompanionBuilder,
      (WordBook, $$WordBooksTableReferences),
      WordBook,
      PrefetchHooks Function({
        bool wordBookItemsRefs,
        bool plansRefs,
        bool importRecordsRefs,
      })
    >;
typedef $$WordsTableCreateCompanionBuilder =
    WordsCompanion Function({
      Value<int> id,
      required String word,
      required String normalizedWord,
      required String meaning,
      Value<String?> phonetic,
      Value<String?> example,
      Value<String?> exampleTranslation,
      Value<String?> phrase,
      Value<String?> note,
      Value<String?> tags,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$WordsTableUpdateCompanionBuilder =
    WordsCompanion Function({
      Value<int> id,
      Value<String> word,
      Value<String> normalizedWord,
      Value<String> meaning,
      Value<String?> phonetic,
      Value<String?> example,
      Value<String?> exampleTranslation,
      Value<String?> phrase,
      Value<String?> note,
      Value<String?> tags,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$WordsTableReferences
    extends BaseReferences<_$AppDatabase, $WordsTable, Word> {
  $$WordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WordBookItemsTable, List<WordBookItem>>
  _wordBookItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordBookItems,
    aliasName: 'words__id__word_book_items__word_id',
  );

  $$WordBookItemsTableProcessedTableManager get wordBookItemsRefs {
    final manager = $$WordBookItemsTableTableManager(
      $_db,
      $_db.wordBookItems,
    ).filter((f) => f.wordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordBookItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WordsTableFilterComposer extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedWord => $composableBuilder(
    column: $table.normalizedWord,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phonetic => $composableBuilder(
    column: $table.phonetic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get example => $composableBuilder(
    column: $table.example,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exampleTranslation => $composableBuilder(
    column: $table.exampleTranslation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phrase => $composableBuilder(
    column: $table.phrase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> wordBookItemsRefs(
    Expression<bool> Function($$WordBookItemsTableFilterComposer f) f,
  ) {
    final $$WordBookItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordBookItems,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordBookItemsTableFilterComposer(
            $db: $db,
            $table: $db.wordBookItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedWord => $composableBuilder(
    column: $table.normalizedWord,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phonetic => $composableBuilder(
    column: $table.phonetic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get example => $composableBuilder(
    column: $table.example,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exampleTranslation => $composableBuilder(
    column: $table.exampleTranslation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phrase => $composableBuilder(
    column: $table.phrase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get normalizedWord => $composableBuilder(
    column: $table.normalizedWord,
    builder: (column) => column,
  );

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumn<String> get phonetic =>
      $composableBuilder(column: $table.phonetic, builder: (column) => column);

  GeneratedColumn<String> get example =>
      $composableBuilder(column: $table.example, builder: (column) => column);

  GeneratedColumn<String> get exampleTranslation => $composableBuilder(
    column: $table.exampleTranslation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phrase =>
      $composableBuilder(column: $table.phrase, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> wordBookItemsRefs<T extends Object>(
    Expression<T> Function($$WordBookItemsTableAnnotationComposer a) f,
  ) {
    final $$WordBookItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordBookItems,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordBookItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.wordBookItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordsTable,
          Word,
          $$WordsTableFilterComposer,
          $$WordsTableOrderingComposer,
          $$WordsTableAnnotationComposer,
          $$WordsTableCreateCompanionBuilder,
          $$WordsTableUpdateCompanionBuilder,
          (Word, $$WordsTableReferences),
          Word,
          PrefetchHooks Function({bool wordBookItemsRefs})
        > {
  $$WordsTableTableManager(_$AppDatabase db, $WordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> word = const Value.absent(),
                Value<String> normalizedWord = const Value.absent(),
                Value<String> meaning = const Value.absent(),
                Value<String?> phonetic = const Value.absent(),
                Value<String?> example = const Value.absent(),
                Value<String?> exampleTranslation = const Value.absent(),
                Value<String?> phrase = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WordsCompanion(
                id: id,
                word: word,
                normalizedWord: normalizedWord,
                meaning: meaning,
                phonetic: phonetic,
                example: example,
                exampleTranslation: exampleTranslation,
                phrase: phrase,
                note: note,
                tags: tags,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String word,
                required String normalizedWord,
                required String meaning,
                Value<String?> phonetic = const Value.absent(),
                Value<String?> example = const Value.absent(),
                Value<String?> exampleTranslation = const Value.absent(),
                Value<String?> phrase = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WordsCompanion.insert(
                id: id,
                word: word,
                normalizedWord: normalizedWord,
                meaning: meaning,
                phonetic: phonetic,
                example: example,
                exampleTranslation: exampleTranslation,
                phrase: phrase,
                note: note,
                tags: tags,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$WordsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({wordBookItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (wordBookItemsRefs) db.wordBookItems,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (wordBookItemsRefs)
                    await $_getPrefetchedData<Word, $WordsTable, WordBookItem>(
                      currentTable: table,
                      referencedTable: $$WordsTableReferences
                          ._wordBookItemsRefsTable(db),
                      managerFromTypedResult: (p0) => $$WordsTableReferences(
                        db,
                        table,
                        p0,
                      ).wordBookItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.wordId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordsTable,
      Word,
      $$WordsTableFilterComposer,
      $$WordsTableOrderingComposer,
      $$WordsTableAnnotationComposer,
      $$WordsTableCreateCompanionBuilder,
      $$WordsTableUpdateCompanionBuilder,
      (Word, $$WordsTableReferences),
      Word,
      PrefetchHooks Function({bool wordBookItemsRefs})
    >;
typedef $$WordBookItemsTableCreateCompanionBuilder =
    WordBookItemsCompanion Function({
      Value<int> id,
      required int wordBookId,
      required int wordId,
      Value<String> learningState,
      Value<DateTime> addedAt,
      Value<DateTime?> suspendedAt,
    });
typedef $$WordBookItemsTableUpdateCompanionBuilder =
    WordBookItemsCompanion Function({
      Value<int> id,
      Value<int> wordBookId,
      Value<int> wordId,
      Value<String> learningState,
      Value<DateTime> addedAt,
      Value<DateTime?> suspendedAt,
    });

final class $$WordBookItemsTableReferences
    extends BaseReferences<_$AppDatabase, $WordBookItemsTable, WordBookItem> {
  $$WordBookItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WordBooksTable _wordBookIdTable(_$AppDatabase db) =>
      db.wordBooks.createAlias('word_book_items__word_book_id__word_books__id');

  $$WordBooksTableProcessedTableManager get wordBookId {
    final $_column = $_itemColumn<int>('word_book_id')!;

    final manager = $$WordBooksTableTableManager(
      $_db,
      $_db.wordBooks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordBookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WordsTable _wordIdTable(_$AppDatabase db) =>
      db.words.createAlias('word_book_items__word_id__words__id');

  $$WordsTableProcessedTableManager get wordId {
    final $_column = $_itemColumn<int>('word_id')!;

    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ReviewSchedulesTable, List<ReviewSchedule>>
  _reviewSchedulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reviewSchedules,
    aliasName: 'word_book_items__id__review_schedules__word_book_item_id',
  );

  $$ReviewSchedulesTableProcessedTableManager get reviewSchedulesRefs {
    final manager = $$ReviewSchedulesTableTableManager(
      $_db,
      $_db.reviewSchedules,
    ).filter((f) => f.wordBookItemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _reviewSchedulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReviewRecordsTable, List<ReviewRecord>>
  _reviewRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reviewRecords,
    aliasName: 'word_book_items__id__review_records__word_book_item_id',
  );

  $$ReviewRecordsTableProcessedTableManager get reviewRecordsRefs {
    final manager = $$ReviewRecordsTableTableManager(
      $_db,
      $_db.reviewRecords,
    ).filter((f) => f.wordBookItemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_reviewRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WordBookItemsTableFilterComposer
    extends Composer<_$AppDatabase, $WordBookItemsTable> {
  $$WordBookItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get learningState => $composableBuilder(
    column: $table.learningState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get suspendedAt => $composableBuilder(
    column: $table.suspendedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WordBooksTableFilterComposer get wordBookId {
    final $$WordBooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordBookId,
      referencedTable: $db.wordBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordBooksTableFilterComposer(
            $db: $db,
            $table: $db.wordBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> reviewSchedulesRefs(
    Expression<bool> Function($$ReviewSchedulesTableFilterComposer f) f,
  ) {
    final $$ReviewSchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewSchedules,
      getReferencedColumn: (t) => t.wordBookItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewSchedulesTableFilterComposer(
            $db: $db,
            $table: $db.reviewSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reviewRecordsRefs(
    Expression<bool> Function($$ReviewRecordsTableFilterComposer f) f,
  ) {
    final $$ReviewRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewRecords,
      getReferencedColumn: (t) => t.wordBookItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewRecordsTableFilterComposer(
            $db: $db,
            $table: $db.reviewRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordBookItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordBookItemsTable> {
  $$WordBookItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get learningState => $composableBuilder(
    column: $table.learningState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get suspendedAt => $composableBuilder(
    column: $table.suspendedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WordBooksTableOrderingComposer get wordBookId {
    final $$WordBooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordBookId,
      referencedTable: $db.wordBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordBooksTableOrderingComposer(
            $db: $db,
            $table: $db.wordBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableOrderingComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordBookItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordBookItemsTable> {
  $$WordBookItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get learningState => $composableBuilder(
    column: $table.learningState,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get suspendedAt => $composableBuilder(
    column: $table.suspendedAt,
    builder: (column) => column,
  );

  $$WordBooksTableAnnotationComposer get wordBookId {
    final $$WordBooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordBookId,
      referencedTable: $db.wordBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordBooksTableAnnotationComposer(
            $db: $db,
            $table: $db.wordBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> reviewSchedulesRefs<T extends Object>(
    Expression<T> Function($$ReviewSchedulesTableAnnotationComposer a) f,
  ) {
    final $$ReviewSchedulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewSchedules,
      getReferencedColumn: (t) => t.wordBookItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewSchedulesTableAnnotationComposer(
            $db: $db,
            $table: $db.reviewSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> reviewRecordsRefs<T extends Object>(
    Expression<T> Function($$ReviewRecordsTableAnnotationComposer a) f,
  ) {
    final $$ReviewRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewRecords,
      getReferencedColumn: (t) => t.wordBookItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.reviewRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordBookItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordBookItemsTable,
          WordBookItem,
          $$WordBookItemsTableFilterComposer,
          $$WordBookItemsTableOrderingComposer,
          $$WordBookItemsTableAnnotationComposer,
          $$WordBookItemsTableCreateCompanionBuilder,
          $$WordBookItemsTableUpdateCompanionBuilder,
          (WordBookItem, $$WordBookItemsTableReferences),
          WordBookItem,
          PrefetchHooks Function({
            bool wordBookId,
            bool wordId,
            bool reviewSchedulesRefs,
            bool reviewRecordsRefs,
          })
        > {
  $$WordBookItemsTableTableManager(_$AppDatabase db, $WordBookItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordBookItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordBookItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordBookItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> wordBookId = const Value.absent(),
                Value<int> wordId = const Value.absent(),
                Value<String> learningState = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<DateTime?> suspendedAt = const Value.absent(),
              }) => WordBookItemsCompanion(
                id: id,
                wordBookId: wordBookId,
                wordId: wordId,
                learningState: learningState,
                addedAt: addedAt,
                suspendedAt: suspendedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int wordBookId,
                required int wordId,
                Value<String> learningState = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<DateTime?> suspendedAt = const Value.absent(),
              }) => WordBookItemsCompanion.insert(
                id: id,
                wordBookId: wordBookId,
                wordId: wordId,
                learningState: learningState,
                addedAt: addedAt,
                suspendedAt: suspendedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WordBookItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                wordBookId = false,
                wordId = false,
                reviewSchedulesRefs = false,
                reviewRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (reviewSchedulesRefs) db.reviewSchedules,
                    if (reviewRecordsRefs) db.reviewRecords,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (wordBookId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.wordBookId,
                                    referencedTable:
                                        $$WordBookItemsTableReferences
                                            ._wordBookIdTable(db),
                                    referencedColumn:
                                        $$WordBookItemsTableReferences
                                            ._wordBookIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (wordId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.wordId,
                                    referencedTable:
                                        $$WordBookItemsTableReferences
                                            ._wordIdTable(db),
                                    referencedColumn:
                                        $$WordBookItemsTableReferences
                                            ._wordIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (reviewSchedulesRefs)
                        await $_getPrefetchedData<
                          WordBookItem,
                          $WordBookItemsTable,
                          ReviewSchedule
                        >(
                          currentTable: table,
                          referencedTable: $$WordBookItemsTableReferences
                              ._reviewSchedulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordBookItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).reviewSchedulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wordBookItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (reviewRecordsRefs)
                        await $_getPrefetchedData<
                          WordBookItem,
                          $WordBookItemsTable,
                          ReviewRecord
                        >(
                          currentTable: table,
                          referencedTable: $$WordBookItemsTableReferences
                              ._reviewRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordBookItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).reviewRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wordBookItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WordBookItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordBookItemsTable,
      WordBookItem,
      $$WordBookItemsTableFilterComposer,
      $$WordBookItemsTableOrderingComposer,
      $$WordBookItemsTableAnnotationComposer,
      $$WordBookItemsTableCreateCompanionBuilder,
      $$WordBookItemsTableUpdateCompanionBuilder,
      (WordBookItem, $$WordBookItemsTableReferences),
      WordBookItem,
      PrefetchHooks Function({
        bool wordBookId,
        bool wordId,
        bool reviewSchedulesRefs,
        bool reviewRecordsRefs,
      })
    >;
typedef $$ReviewSchedulesTableCreateCompanionBuilder =
    ReviewSchedulesCompanion Function({
      Value<int> wordBookItemId,
      required DateTime dueAt,
      Value<int> intervalDays,
      Value<int> streak,
      Value<int> lapseCount,
      Value<String?> lastRating,
      Value<DateTime?> lastReviewedAt,
    });
typedef $$ReviewSchedulesTableUpdateCompanionBuilder =
    ReviewSchedulesCompanion Function({
      Value<int> wordBookItemId,
      Value<DateTime> dueAt,
      Value<int> intervalDays,
      Value<int> streak,
      Value<int> lapseCount,
      Value<String?> lastRating,
      Value<DateTime?> lastReviewedAt,
    });

final class $$ReviewSchedulesTableReferences
    extends
        BaseReferences<_$AppDatabase, $ReviewSchedulesTable, ReviewSchedule> {
  $$ReviewSchedulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WordBookItemsTable _wordBookItemIdTable(_$AppDatabase db) => db
      .wordBookItems
      .createAlias('review_schedules__word_book_item_id__word_book_items__id');

  $$WordBookItemsTableProcessedTableManager get wordBookItemId {
    final $_column = $_itemColumn<int>('word_book_item_id')!;

    final manager = $$WordBookItemsTableTableManager(
      $_db,
      $_db.wordBookItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordBookItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReviewSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewSchedulesTable> {
  $$ReviewSchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streak => $composableBuilder(
    column: $table.streak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lapseCount => $composableBuilder(
    column: $table.lapseCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastRating => $composableBuilder(
    column: $table.lastRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WordBookItemsTableFilterComposer get wordBookItemId {
    final $$WordBookItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordBookItemId,
      referencedTable: $db.wordBookItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordBookItemsTableFilterComposer(
            $db: $db,
            $table: $db.wordBookItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewSchedulesTable> {
  $$ReviewSchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streak => $composableBuilder(
    column: $table.streak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lapseCount => $composableBuilder(
    column: $table.lapseCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastRating => $composableBuilder(
    column: $table.lastRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WordBookItemsTableOrderingComposer get wordBookItemId {
    final $$WordBookItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordBookItemId,
      referencedTable: $db.wordBookItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordBookItemsTableOrderingComposer(
            $db: $db,
            $table: $db.wordBookItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewSchedulesTable> {
  $$ReviewSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get streak =>
      $composableBuilder(column: $table.streak, builder: (column) => column);

  GeneratedColumn<int> get lapseCount => $composableBuilder(
    column: $table.lapseCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastRating => $composableBuilder(
    column: $table.lastRating,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => column,
  );

  $$WordBookItemsTableAnnotationComposer get wordBookItemId {
    final $$WordBookItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordBookItemId,
      referencedTable: $db.wordBookItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordBookItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.wordBookItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewSchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReviewSchedulesTable,
          ReviewSchedule,
          $$ReviewSchedulesTableFilterComposer,
          $$ReviewSchedulesTableOrderingComposer,
          $$ReviewSchedulesTableAnnotationComposer,
          $$ReviewSchedulesTableCreateCompanionBuilder,
          $$ReviewSchedulesTableUpdateCompanionBuilder,
          (ReviewSchedule, $$ReviewSchedulesTableReferences),
          ReviewSchedule,
          PrefetchHooks Function({bool wordBookItemId})
        > {
  $$ReviewSchedulesTableTableManager(
    _$AppDatabase db,
    $ReviewSchedulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewSchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewSchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> wordBookItemId = const Value.absent(),
                Value<DateTime> dueAt = const Value.absent(),
                Value<int> intervalDays = const Value.absent(),
                Value<int> streak = const Value.absent(),
                Value<int> lapseCount = const Value.absent(),
                Value<String?> lastRating = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
              }) => ReviewSchedulesCompanion(
                wordBookItemId: wordBookItemId,
                dueAt: dueAt,
                intervalDays: intervalDays,
                streak: streak,
                lapseCount: lapseCount,
                lastRating: lastRating,
                lastReviewedAt: lastReviewedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> wordBookItemId = const Value.absent(),
                required DateTime dueAt,
                Value<int> intervalDays = const Value.absent(),
                Value<int> streak = const Value.absent(),
                Value<int> lapseCount = const Value.absent(),
                Value<String?> lastRating = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
              }) => ReviewSchedulesCompanion.insert(
                wordBookItemId: wordBookItemId,
                dueAt: dueAt,
                intervalDays: intervalDays,
                streak: streak,
                lapseCount: lapseCount,
                lastRating: lastRating,
                lastReviewedAt: lastReviewedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReviewSchedulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wordBookItemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (wordBookItemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.wordBookItemId,
                                referencedTable:
                                    $$ReviewSchedulesTableReferences
                                        ._wordBookItemIdTable(db),
                                referencedColumn:
                                    $$ReviewSchedulesTableReferences
                                        ._wordBookItemIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReviewSchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReviewSchedulesTable,
      ReviewSchedule,
      $$ReviewSchedulesTableFilterComposer,
      $$ReviewSchedulesTableOrderingComposer,
      $$ReviewSchedulesTableAnnotationComposer,
      $$ReviewSchedulesTableCreateCompanionBuilder,
      $$ReviewSchedulesTableUpdateCompanionBuilder,
      (ReviewSchedule, $$ReviewSchedulesTableReferences),
      ReviewSchedule,
      PrefetchHooks Function({bool wordBookItemId})
    >;
typedef $$ReviewRecordsTableCreateCompanionBuilder =
    ReviewRecordsCompanion Function({
      Value<int> id,
      required int wordBookItemId,
      required String rating,
      required DateTime reviewedAt,
      Value<DateTime?> previousDueAt,
      required DateTime nextDueAt,
      Value<int?> durationMs,
    });
typedef $$ReviewRecordsTableUpdateCompanionBuilder =
    ReviewRecordsCompanion Function({
      Value<int> id,
      Value<int> wordBookItemId,
      Value<String> rating,
      Value<DateTime> reviewedAt,
      Value<DateTime?> previousDueAt,
      Value<DateTime> nextDueAt,
      Value<int?> durationMs,
    });

final class $$ReviewRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $ReviewRecordsTable, ReviewRecord> {
  $$ReviewRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WordBookItemsTable _wordBookItemIdTable(_$AppDatabase db) => db
      .wordBookItems
      .createAlias('review_records__word_book_item_id__word_book_items__id');

  $$WordBookItemsTableProcessedTableManager get wordBookItemId {
    final $_column = $_itemColumn<int>('word_book_item_id')!;

    final manager = $$WordBookItemsTableTableManager(
      $_db,
      $_db.wordBookItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordBookItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReviewRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewRecordsTable> {
  $$ReviewRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get previousDueAt => $composableBuilder(
    column: $table.previousDueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextDueAt => $composableBuilder(
    column: $table.nextDueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  $$WordBookItemsTableFilterComposer get wordBookItemId {
    final $$WordBookItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordBookItemId,
      referencedTable: $db.wordBookItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordBookItemsTableFilterComposer(
            $db: $db,
            $table: $db.wordBookItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewRecordsTable> {
  $$ReviewRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get previousDueAt => $composableBuilder(
    column: $table.previousDueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextDueAt => $composableBuilder(
    column: $table.nextDueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$WordBookItemsTableOrderingComposer get wordBookItemId {
    final $$WordBookItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordBookItemId,
      referencedTable: $db.wordBookItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordBookItemsTableOrderingComposer(
            $db: $db,
            $table: $db.wordBookItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewRecordsTable> {
  $$ReviewRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get previousDueAt => $composableBuilder(
    column: $table.previousDueAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextDueAt =>
      $composableBuilder(column: $table.nextDueAt, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  $$WordBookItemsTableAnnotationComposer get wordBookItemId {
    final $$WordBookItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordBookItemId,
      referencedTable: $db.wordBookItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordBookItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.wordBookItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReviewRecordsTable,
          ReviewRecord,
          $$ReviewRecordsTableFilterComposer,
          $$ReviewRecordsTableOrderingComposer,
          $$ReviewRecordsTableAnnotationComposer,
          $$ReviewRecordsTableCreateCompanionBuilder,
          $$ReviewRecordsTableUpdateCompanionBuilder,
          (ReviewRecord, $$ReviewRecordsTableReferences),
          ReviewRecord,
          PrefetchHooks Function({bool wordBookItemId})
        > {
  $$ReviewRecordsTableTableManager(_$AppDatabase db, $ReviewRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> wordBookItemId = const Value.absent(),
                Value<String> rating = const Value.absent(),
                Value<DateTime> reviewedAt = const Value.absent(),
                Value<DateTime?> previousDueAt = const Value.absent(),
                Value<DateTime> nextDueAt = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
              }) => ReviewRecordsCompanion(
                id: id,
                wordBookItemId: wordBookItemId,
                rating: rating,
                reviewedAt: reviewedAt,
                previousDueAt: previousDueAt,
                nextDueAt: nextDueAt,
                durationMs: durationMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int wordBookItemId,
                required String rating,
                required DateTime reviewedAt,
                Value<DateTime?> previousDueAt = const Value.absent(),
                required DateTime nextDueAt,
                Value<int?> durationMs = const Value.absent(),
              }) => ReviewRecordsCompanion.insert(
                id: id,
                wordBookItemId: wordBookItemId,
                rating: rating,
                reviewedAt: reviewedAt,
                previousDueAt: previousDueAt,
                nextDueAt: nextDueAt,
                durationMs: durationMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReviewRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wordBookItemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (wordBookItemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.wordBookItemId,
                                referencedTable: $$ReviewRecordsTableReferences
                                    ._wordBookItemIdTable(db),
                                referencedColumn: $$ReviewRecordsTableReferences
                                    ._wordBookItemIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReviewRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReviewRecordsTable,
      ReviewRecord,
      $$ReviewRecordsTableFilterComposer,
      $$ReviewRecordsTableOrderingComposer,
      $$ReviewRecordsTableAnnotationComposer,
      $$ReviewRecordsTableCreateCompanionBuilder,
      $$ReviewRecordsTableUpdateCompanionBuilder,
      (ReviewRecord, $$ReviewRecordsTableReferences),
      ReviewRecord,
      PrefetchHooks Function({bool wordBookItemId})
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      Value<int?> colorValue,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int?> colorValue,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlansTable, List<Plan>> _plansRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.plans,
    aliasName: 'categories__id__plans__category_id',
  );

  $$PlansTableProcessedTableManager get plansRefs {
    final manager = $$PlansTableTableManager(
      $_db,
      $_db.plans,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_plansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> plansRefs(
    Expression<bool> Function($$PlansTableFilterComposer f) f,
  ) {
    final $$PlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableFilterComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> plansRefs<T extends Object>(
    Expression<T> Function($$PlansTableAnnotationComposer a) f,
  ) {
    final $$PlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableAnnotationComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({bool plansRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> colorValue = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                colorValue: colorValue,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> colorValue = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                colorValue: colorValue,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({plansRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (plansRefs) db.plans],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (plansRefs)
                    await $_getPrefetchedData<Category, $CategoriesTable, Plan>(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._plansRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(db, table, p0).plansRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({bool plansRefs})
    >;
typedef $$CourseSchedulesTableCreateCompanionBuilder =
    CourseSchedulesCompanion Function({
      Value<int> id,
      required String name,
      required String sourceType,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$CourseSchedulesTableUpdateCompanionBuilder =
    CourseSchedulesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> sourceType,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$CourseSchedulesTableReferences
    extends
        BaseReferences<_$AppDatabase, $CourseSchedulesTable, CourseSchedule> {
  $$CourseSchedulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$PlansTable, List<Plan>> _plansRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.plans,
    aliasName: 'course_schedules__id__plans__course_schedule_id',
  );

  $$PlansTableProcessedTableManager get plansRefs {
    final manager = $$PlansTableTableManager(
      $_db,
      $_db.plans,
    ).filter((f) => f.courseScheduleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_plansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CourseSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $CourseSchedulesTable> {
  $$CourseSchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> plansRefs(
    Expression<bool> Function($$PlansTableFilterComposer f) f,
  ) {
    final $$PlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.courseScheduleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableFilterComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CourseSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $CourseSchedulesTable> {
  $$CourseSchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CourseSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CourseSchedulesTable> {
  $$CourseSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> plansRefs<T extends Object>(
    Expression<T> Function($$PlansTableAnnotationComposer a) f,
  ) {
    final $$PlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.courseScheduleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableAnnotationComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CourseSchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CourseSchedulesTable,
          CourseSchedule,
          $$CourseSchedulesTableFilterComposer,
          $$CourseSchedulesTableOrderingComposer,
          $$CourseSchedulesTableAnnotationComposer,
          $$CourseSchedulesTableCreateCompanionBuilder,
          $$CourseSchedulesTableUpdateCompanionBuilder,
          (CourseSchedule, $$CourseSchedulesTableReferences),
          CourseSchedule,
          PrefetchHooks Function({bool plansRefs})
        > {
  $$CourseSchedulesTableTableManager(
    _$AppDatabase db,
    $CourseSchedulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CourseSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CourseSchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CourseSchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CourseSchedulesCompanion(
                id: id,
                name: name,
                sourceType: sourceType,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String sourceType,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CourseSchedulesCompanion.insert(
                id: id,
                name: name,
                sourceType: sourceType,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CourseSchedulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({plansRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (plansRefs) db.plans],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (plansRefs)
                    await $_getPrefetchedData<
                      CourseSchedule,
                      $CourseSchedulesTable,
                      Plan
                    >(
                      currentTable: table,
                      referencedTable: $$CourseSchedulesTableReferences
                          ._plansRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CourseSchedulesTableReferences(
                            db,
                            table,
                            p0,
                          ).plansRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.courseScheduleId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CourseSchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CourseSchedulesTable,
      CourseSchedule,
      $$CourseSchedulesTableFilterComposer,
      $$CourseSchedulesTableOrderingComposer,
      $$CourseSchedulesTableAnnotationComposer,
      $$CourseSchedulesTableCreateCompanionBuilder,
      $$CourseSchedulesTableUpdateCompanionBuilder,
      (CourseSchedule, $$CourseSchedulesTableReferences),
      CourseSchedule,
      PrefetchHooks Function({bool plansRefs})
    >;
typedef $$PlansTableCreateCompanionBuilder =
    PlansCompanion Function({
      Value<int> id,
      Value<int?> templateId,
      Value<int?> categoryId,
      Value<int?> wordBookId,
      Value<int?> courseScheduleId,
      Value<String?> linkedAppPackage,
      Value<String?> linkedAppName,
      required String title,
      Value<String?> note,
      required DateTime startsAt,
      Value<int> estimatedMinutes,
      Value<int> priority,
      Value<String> status,
      Value<String?> repeatRule,
      Value<String?> instanceDate,
      Value<int> targetPomodoros,
      Value<int> actualMinutes,
      Value<DateTime?> completedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$PlansTableUpdateCompanionBuilder =
    PlansCompanion Function({
      Value<int> id,
      Value<int?> templateId,
      Value<int?> categoryId,
      Value<int?> wordBookId,
      Value<int?> courseScheduleId,
      Value<String?> linkedAppPackage,
      Value<String?> linkedAppName,
      Value<String> title,
      Value<String?> note,
      Value<DateTime> startsAt,
      Value<int> estimatedMinutes,
      Value<int> priority,
      Value<String> status,
      Value<String?> repeatRule,
      Value<String?> instanceDate,
      Value<int> targetPomodoros,
      Value<int> actualMinutes,
      Value<DateTime?> completedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
    });

final class $$PlansTableReferences
    extends BaseReferences<_$AppDatabase, $PlansTable, Plan> {
  $$PlansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('plans__category_id__categories__id');

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WordBooksTable _wordBookIdTable(_$AppDatabase db) =>
      db.wordBooks.createAlias('plans__word_book_id__word_books__id');

  $$WordBooksTableProcessedTableManager? get wordBookId {
    final $_column = $_itemColumn<int>('word_book_id');
    if ($_column == null) return null;
    final manager = $$WordBooksTableTableManager(
      $_db,
      $_db.wordBooks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordBookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CourseSchedulesTable _courseScheduleIdTable(_$AppDatabase db) => db
      .courseSchedules
      .createAlias('plans__course_schedule_id__course_schedules__id');

  $$CourseSchedulesTableProcessedTableManager? get courseScheduleId {
    final $_column = $_itemColumn<int>('course_schedule_id');
    if ($_column == null) return null;
    final manager = $$CourseSchedulesTableTableManager(
      $_db,
      $_db.courseSchedules,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_courseScheduleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RemindersTable, List<Reminder>>
  _remindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminders,
    aliasName: 'plans__id__reminders__plan_id',
  );

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.planId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PomodoroSessionsTable, List<PomodoroSession>>
  _pomodoroSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pomodoroSessions,
    aliasName: 'plans__id__pomodoro_sessions__plan_id',
  );

  $$PomodoroSessionsTableProcessedTableManager get pomodoroSessionsRefs {
    final manager = $$PomodoroSessionsTableTableManager(
      $_db,
      $_db.pomodoroSessions,
    ).filter((f) => f.planId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _pomodoroSessionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlansTableFilterComposer extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedAppPackage => $composableBuilder(
    column: $table.linkedAppPackage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedAppName => $composableBuilder(
    column: $table.linkedAppName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instanceDate => $composableBuilder(
    column: $table.instanceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetPomodoros => $composableBuilder(
    column: $table.targetPomodoros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualMinutes => $composableBuilder(
    column: $table.actualMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordBooksTableFilterComposer get wordBookId {
    final $$WordBooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordBookId,
      referencedTable: $db.wordBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordBooksTableFilterComposer(
            $db: $db,
            $table: $db.wordBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CourseSchedulesTableFilterComposer get courseScheduleId {
    final $$CourseSchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseScheduleId,
      referencedTable: $db.courseSchedules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseSchedulesTableFilterComposer(
            $db: $db,
            $table: $db.courseSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> remindersRefs(
    Expression<bool> Function($$RemindersTableFilterComposer f) f,
  ) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableFilterComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pomodoroSessionsRefs(
    Expression<bool> Function($$PomodoroSessionsTableFilterComposer f) f,
  ) {
    final $$PomodoroSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pomodoroSessions,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PomodoroSessionsTableFilterComposer(
            $db: $db,
            $table: $db.pomodoroSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlansTableOrderingComposer
    extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedAppPackage => $composableBuilder(
    column: $table.linkedAppPackage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedAppName => $composableBuilder(
    column: $table.linkedAppName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instanceDate => $composableBuilder(
    column: $table.instanceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetPomodoros => $composableBuilder(
    column: $table.targetPomodoros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualMinutes => $composableBuilder(
    column: $table.actualMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordBooksTableOrderingComposer get wordBookId {
    final $$WordBooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordBookId,
      referencedTable: $db.wordBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordBooksTableOrderingComposer(
            $db: $db,
            $table: $db.wordBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CourseSchedulesTableOrderingComposer get courseScheduleId {
    final $$CourseSchedulesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseScheduleId,
      referencedTable: $db.courseSchedules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseSchedulesTableOrderingComposer(
            $db: $db,
            $table: $db.courseSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get linkedAppPackage => $composableBuilder(
    column: $table.linkedAppPackage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get linkedAppName => $composableBuilder(
    column: $table.linkedAppName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get startsAt =>
      $composableBuilder(column: $table.startsAt, builder: (column) => column);

  GeneratedColumn<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => column,
  );

  GeneratedColumn<String> get instanceDate => $composableBuilder(
    column: $table.instanceDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetPomodoros => $composableBuilder(
    column: $table.targetPomodoros,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualMinutes => $composableBuilder(
    column: $table.actualMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordBooksTableAnnotationComposer get wordBookId {
    final $$WordBooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordBookId,
      referencedTable: $db.wordBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordBooksTableAnnotationComposer(
            $db: $db,
            $table: $db.wordBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CourseSchedulesTableAnnotationComposer get courseScheduleId {
    final $$CourseSchedulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseScheduleId,
      referencedTable: $db.courseSchedules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseSchedulesTableAnnotationComposer(
            $db: $db,
            $table: $db.courseSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> remindersRefs<T extends Object>(
    Expression<T> Function($$RemindersTableAnnotationComposer a) f,
  ) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pomodoroSessionsRefs<T extends Object>(
    Expression<T> Function($$PomodoroSessionsTableAnnotationComposer a) f,
  ) {
    final $$PomodoroSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pomodoroSessions,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PomodoroSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.pomodoroSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlansTable,
          Plan,
          $$PlansTableFilterComposer,
          $$PlansTableOrderingComposer,
          $$PlansTableAnnotationComposer,
          $$PlansTableCreateCompanionBuilder,
          $$PlansTableUpdateCompanionBuilder,
          (Plan, $$PlansTableReferences),
          Plan,
          PrefetchHooks Function({
            bool categoryId,
            bool wordBookId,
            bool courseScheduleId,
            bool remindersRefs,
            bool pomodoroSessionsRefs,
          })
        > {
  $$PlansTableTableManager(_$AppDatabase db, $PlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> templateId = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<int?> wordBookId = const Value.absent(),
                Value<int?> courseScheduleId = const Value.absent(),
                Value<String?> linkedAppPackage = const Value.absent(),
                Value<String?> linkedAppName = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> startsAt = const Value.absent(),
                Value<int> estimatedMinutes = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> repeatRule = const Value.absent(),
                Value<String?> instanceDate = const Value.absent(),
                Value<int> targetPomodoros = const Value.absent(),
                Value<int> actualMinutes = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => PlansCompanion(
                id: id,
                templateId: templateId,
                categoryId: categoryId,
                wordBookId: wordBookId,
                courseScheduleId: courseScheduleId,
                linkedAppPackage: linkedAppPackage,
                linkedAppName: linkedAppName,
                title: title,
                note: note,
                startsAt: startsAt,
                estimatedMinutes: estimatedMinutes,
                priority: priority,
                status: status,
                repeatRule: repeatRule,
                instanceDate: instanceDate,
                targetPomodoros: targetPomodoros,
                actualMinutes: actualMinutes,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> templateId = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<int?> wordBookId = const Value.absent(),
                Value<int?> courseScheduleId = const Value.absent(),
                Value<String?> linkedAppPackage = const Value.absent(),
                Value<String?> linkedAppName = const Value.absent(),
                required String title,
                Value<String?> note = const Value.absent(),
                required DateTime startsAt,
                Value<int> estimatedMinutes = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> repeatRule = const Value.absent(),
                Value<String?> instanceDate = const Value.absent(),
                Value<int> targetPomodoros = const Value.absent(),
                Value<int> actualMinutes = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => PlansCompanion.insert(
                id: id,
                templateId: templateId,
                categoryId: categoryId,
                wordBookId: wordBookId,
                courseScheduleId: courseScheduleId,
                linkedAppPackage: linkedAppPackage,
                linkedAppName: linkedAppName,
                title: title,
                note: note,
                startsAt: startsAt,
                estimatedMinutes: estimatedMinutes,
                priority: priority,
                status: status,
                repeatRule: repeatRule,
                instanceDate: instanceDate,
                targetPomodoros: targetPomodoros,
                actualMinutes: actualMinutes,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$PlansTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoryId = false,
                wordBookId = false,
                courseScheduleId = false,
                remindersRefs = false,
                pomodoroSessionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (remindersRefs) db.reminders,
                    if (pomodoroSessionsRefs) db.pomodoroSessions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable: $$PlansTableReferences
                                        ._categoryIdTable(db),
                                    referencedColumn: $$PlansTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (wordBookId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.wordBookId,
                                    referencedTable: $$PlansTableReferences
                                        ._wordBookIdTable(db),
                                    referencedColumn: $$PlansTableReferences
                                        ._wordBookIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (courseScheduleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.courseScheduleId,
                                    referencedTable: $$PlansTableReferences
                                        ._courseScheduleIdTable(db),
                                    referencedColumn: $$PlansTableReferences
                                        ._courseScheduleIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (remindersRefs)
                        await $_getPrefetchedData<Plan, $PlansTable, Reminder>(
                          currentTable: table,
                          referencedTable: $$PlansTableReferences
                              ._remindersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlansTableReferences(
                                db,
                                table,
                                p0,
                              ).remindersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.planId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (pomodoroSessionsRefs)
                        await $_getPrefetchedData<
                          Plan,
                          $PlansTable,
                          PomodoroSession
                        >(
                          currentTable: table,
                          referencedTable: $$PlansTableReferences
                              ._pomodoroSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlansTableReferences(
                                db,
                                table,
                                p0,
                              ).pomodoroSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.planId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlansTable,
      Plan,
      $$PlansTableFilterComposer,
      $$PlansTableOrderingComposer,
      $$PlansTableAnnotationComposer,
      $$PlansTableCreateCompanionBuilder,
      $$PlansTableUpdateCompanionBuilder,
      (Plan, $$PlansTableReferences),
      Plan,
      PrefetchHooks Function({
        bool categoryId,
        bool wordBookId,
        bool courseScheduleId,
        bool remindersRefs,
        bool pomodoroSessionsRefs,
      })
    >;
typedef $$RemindersTableCreateCompanionBuilder =
    RemindersCompanion Function({
      Value<int> id,
      required int planId,
      required DateTime triggerAt,
      Value<int> offsetMinutes,
      Value<int?> platformNotificationId,
      Value<String> status,
      Value<int> snoozeCount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$RemindersTableUpdateCompanionBuilder =
    RemindersCompanion Function({
      Value<int> id,
      Value<int> planId,
      Value<DateTime> triggerAt,
      Value<int> offsetMinutes,
      Value<int?> platformNotificationId,
      Value<String> status,
      Value<int> snoozeCount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$RemindersTableReferences
    extends BaseReferences<_$AppDatabase, $RemindersTable, Reminder> {
  $$RemindersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlansTable _planIdTable(_$AppDatabase db) =>
      db.plans.createAlias('reminders__plan_id__plans__id');

  $$PlansTableProcessedTableManager get planId {
    final $_column = $_itemColumn<int>('plan_id')!;

    final manager = $$PlansTableTableManager(
      $_db,
      $_db.plans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get triggerAt => $composableBuilder(
    column: $table.triggerAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get offsetMinutes => $composableBuilder(
    column: $table.offsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get platformNotificationId => $composableBuilder(
    column: $table.platformNotificationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snoozeCount => $composableBuilder(
    column: $table.snoozeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PlansTableFilterComposer get planId {
    final $$PlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableFilterComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get triggerAt => $composableBuilder(
    column: $table.triggerAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get offsetMinutes => $composableBuilder(
    column: $table.offsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get platformNotificationId => $composableBuilder(
    column: $table.platformNotificationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snoozeCount => $composableBuilder(
    column: $table.snoozeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlansTableOrderingComposer get planId {
    final $$PlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableOrderingComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get triggerAt =>
      $composableBuilder(column: $table.triggerAt, builder: (column) => column);

  GeneratedColumn<int> get offsetMinutes => $composableBuilder(
    column: $table.offsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get platformNotificationId => $composableBuilder(
    column: $table.platformNotificationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get snoozeCount => $composableBuilder(
    column: $table.snoozeCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$PlansTableAnnotationComposer get planId {
    final $$PlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableAnnotationComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          Reminder,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (Reminder, $$RemindersTableReferences),
          Reminder,
          PrefetchHooks Function({bool planId})
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> planId = const Value.absent(),
                Value<DateTime> triggerAt = const Value.absent(),
                Value<int> offsetMinutes = const Value.absent(),
                Value<int?> platformNotificationId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> snoozeCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                planId: planId,
                triggerAt: triggerAt,
                offsetMinutes: offsetMinutes,
                platformNotificationId: platformNotificationId,
                status: status,
                snoozeCount: snoozeCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int planId,
                required DateTime triggerAt,
                Value<int> offsetMinutes = const Value.absent(),
                Value<int?> platformNotificationId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> snoozeCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                planId: planId,
                triggerAt: triggerAt,
                offsetMinutes: offsetMinutes,
                platformNotificationId: platformNotificationId,
                status: status,
                snoozeCount: snoozeCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RemindersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({planId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (planId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.planId,
                                referencedTable: $$RemindersTableReferences
                                    ._planIdTable(db),
                                referencedColumn: $$RemindersTableReferences
                                    ._planIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      Reminder,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (Reminder, $$RemindersTableReferences),
      Reminder,
      PrefetchHooks Function({bool planId})
    >;
typedef $$PomodoroSessionsTableCreateCompanionBuilder =
    PomodoroSessionsCompanion Function({
      Value<int> id,
      Value<int?> planId,
      Value<String> phase,
      Value<String> status,
      required DateTime startedAt,
      required DateTime targetEndAt,
      Value<DateTime?> pausedAt,
      Value<int> pausedTotalMs,
      Value<DateTime?> completedAt,
      Value<int> actualDurationMs,
    });
typedef $$PomodoroSessionsTableUpdateCompanionBuilder =
    PomodoroSessionsCompanion Function({
      Value<int> id,
      Value<int?> planId,
      Value<String> phase,
      Value<String> status,
      Value<DateTime> startedAt,
      Value<DateTime> targetEndAt,
      Value<DateTime?> pausedAt,
      Value<int> pausedTotalMs,
      Value<DateTime?> completedAt,
      Value<int> actualDurationMs,
    });

final class $$PomodoroSessionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $PomodoroSessionsTable, PomodoroSession> {
  $$PomodoroSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlansTable _planIdTable(_$AppDatabase db) =>
      db.plans.createAlias('pomodoro_sessions__plan_id__plans__id');

  $$PlansTableProcessedTableManager? get planId {
    final $_column = $_itemColumn<int>('plan_id');
    if ($_column == null) return null;
    final manager = $$PlansTableTableManager(
      $_db,
      $_db.plans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PomodoroSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $PomodoroSessionsTable> {
  $$PomodoroSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get targetEndAt => $composableBuilder(
    column: $table.targetEndAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pausedAt => $composableBuilder(
    column: $table.pausedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pausedTotalMs => $composableBuilder(
    column: $table.pausedTotalMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualDurationMs => $composableBuilder(
    column: $table.actualDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  $$PlansTableFilterComposer get planId {
    final $$PlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableFilterComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PomodoroSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PomodoroSessionsTable> {
  $$PomodoroSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get targetEndAt => $composableBuilder(
    column: $table.targetEndAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pausedAt => $composableBuilder(
    column: $table.pausedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pausedTotalMs => $composableBuilder(
    column: $table.pausedTotalMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualDurationMs => $composableBuilder(
    column: $table.actualDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlansTableOrderingComposer get planId {
    final $$PlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableOrderingComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PomodoroSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PomodoroSessionsTable> {
  $$PomodoroSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get phase =>
      $composableBuilder(column: $table.phase, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get targetEndAt => $composableBuilder(
    column: $table.targetEndAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get pausedAt =>
      $composableBuilder(column: $table.pausedAt, builder: (column) => column);

  GeneratedColumn<int> get pausedTotalMs => $composableBuilder(
    column: $table.pausedTotalMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualDurationMs => $composableBuilder(
    column: $table.actualDurationMs,
    builder: (column) => column,
  );

  $$PlansTableAnnotationComposer get planId {
    final $$PlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableAnnotationComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PomodoroSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PomodoroSessionsTable,
          PomodoroSession,
          $$PomodoroSessionsTableFilterComposer,
          $$PomodoroSessionsTableOrderingComposer,
          $$PomodoroSessionsTableAnnotationComposer,
          $$PomodoroSessionsTableCreateCompanionBuilder,
          $$PomodoroSessionsTableUpdateCompanionBuilder,
          (PomodoroSession, $$PomodoroSessionsTableReferences),
          PomodoroSession,
          PrefetchHooks Function({bool planId})
        > {
  $$PomodoroSessionsTableTableManager(
    _$AppDatabase db,
    $PomodoroSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PomodoroSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PomodoroSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PomodoroSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> planId = const Value.absent(),
                Value<String> phase = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> targetEndAt = const Value.absent(),
                Value<DateTime?> pausedAt = const Value.absent(),
                Value<int> pausedTotalMs = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> actualDurationMs = const Value.absent(),
              }) => PomodoroSessionsCompanion(
                id: id,
                planId: planId,
                phase: phase,
                status: status,
                startedAt: startedAt,
                targetEndAt: targetEndAt,
                pausedAt: pausedAt,
                pausedTotalMs: pausedTotalMs,
                completedAt: completedAt,
                actualDurationMs: actualDurationMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> planId = const Value.absent(),
                Value<String> phase = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime startedAt,
                required DateTime targetEndAt,
                Value<DateTime?> pausedAt = const Value.absent(),
                Value<int> pausedTotalMs = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> actualDurationMs = const Value.absent(),
              }) => PomodoroSessionsCompanion.insert(
                id: id,
                planId: planId,
                phase: phase,
                status: status,
                startedAt: startedAt,
                targetEndAt: targetEndAt,
                pausedAt: pausedAt,
                pausedTotalMs: pausedTotalMs,
                completedAt: completedAt,
                actualDurationMs: actualDurationMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PomodoroSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({planId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (planId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.planId,
                                referencedTable:
                                    $$PomodoroSessionsTableReferences
                                        ._planIdTable(db),
                                referencedColumn:
                                    $$PomodoroSessionsTableReferences
                                        ._planIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PomodoroSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PomodoroSessionsTable,
      PomodoroSession,
      $$PomodoroSessionsTableFilterComposer,
      $$PomodoroSessionsTableOrderingComposer,
      $$PomodoroSessionsTableAnnotationComposer,
      $$PomodoroSessionsTableCreateCompanionBuilder,
      $$PomodoroSessionsTableUpdateCompanionBuilder,
      (PomodoroSession, $$PomodoroSessionsTableReferences),
      PomodoroSession,
      PrefetchHooks Function({bool planId})
    >;
typedef $$ImportRecordsTableCreateCompanionBuilder =
    ImportRecordsCompanion Function({
      Value<int> id,
      required String batchUuid,
      required String fileName,
      Value<String?> sourceFingerprint,
      required String sourceType,
      required int targetWordBookId,
      required DateTime startedAt,
      Value<DateTime?> finishedAt,
      Value<int> totalRows,
      Value<int> successCount,
      Value<int> skippedCount,
      Value<int> failedCount,
      Value<String> status,
    });
typedef $$ImportRecordsTableUpdateCompanionBuilder =
    ImportRecordsCompanion Function({
      Value<int> id,
      Value<String> batchUuid,
      Value<String> fileName,
      Value<String?> sourceFingerprint,
      Value<String> sourceType,
      Value<int> targetWordBookId,
      Value<DateTime> startedAt,
      Value<DateTime?> finishedAt,
      Value<int> totalRows,
      Value<int> successCount,
      Value<int> skippedCount,
      Value<int> failedCount,
      Value<String> status,
    });

final class $$ImportRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $ImportRecordsTable, ImportRecord> {
  $$ImportRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WordBooksTable _targetWordBookIdTable(_$AppDatabase db) => db
      .wordBooks
      .createAlias('import_records__target_word_book_id__word_books__id');

  $$WordBooksTableProcessedTableManager get targetWordBookId {
    final $_column = $_itemColumn<int>('target_word_book_id')!;

    final manager = $$WordBooksTableTableManager(
      $_db,
      $_db.wordBooks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_targetWordBookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ImportErrorsTable, List<ImportError>>
  _importErrorsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.importErrors,
    aliasName: 'import_records__id__import_errors__import_record_id',
  );

  $$ImportErrorsTableProcessedTableManager get importErrorsRefs {
    final manager = $$ImportErrorsTableTableManager(
      $_db,
      $_db.importErrors,
    ).filter((f) => f.importRecordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_importErrorsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ImportRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ImportRecordsTable> {
  $$ImportRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchUuid => $composableBuilder(
    column: $table.batchUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceFingerprint => $composableBuilder(
    column: $table.sourceFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalRows => $composableBuilder(
    column: $table.totalRows,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get successCount => $composableBuilder(
    column: $table.successCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skippedCount => $composableBuilder(
    column: $table.skippedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get failedCount => $composableBuilder(
    column: $table.failedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  $$WordBooksTableFilterComposer get targetWordBookId {
    final $$WordBooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetWordBookId,
      referencedTable: $db.wordBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordBooksTableFilterComposer(
            $db: $db,
            $table: $db.wordBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> importErrorsRefs(
    Expression<bool> Function($$ImportErrorsTableFilterComposer f) f,
  ) {
    final $$ImportErrorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importErrors,
      getReferencedColumn: (t) => t.importRecordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportErrorsTableFilterComposer(
            $db: $db,
            $table: $db.importErrors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ImportRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ImportRecordsTable> {
  $$ImportRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchUuid => $composableBuilder(
    column: $table.batchUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceFingerprint => $composableBuilder(
    column: $table.sourceFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalRows => $composableBuilder(
    column: $table.totalRows,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get successCount => $composableBuilder(
    column: $table.successCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skippedCount => $composableBuilder(
    column: $table.skippedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get failedCount => $composableBuilder(
    column: $table.failedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $$WordBooksTableOrderingComposer get targetWordBookId {
    final $$WordBooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetWordBookId,
      referencedTable: $db.wordBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordBooksTableOrderingComposer(
            $db: $db,
            $table: $db.wordBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImportRecordsTable> {
  $$ImportRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get batchUuid =>
      $composableBuilder(column: $table.batchUuid, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get sourceFingerprint => $composableBuilder(
    column: $table.sourceFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalRows =>
      $composableBuilder(column: $table.totalRows, builder: (column) => column);

  GeneratedColumn<int> get successCount => $composableBuilder(
    column: $table.successCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get skippedCount => $composableBuilder(
    column: $table.skippedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get failedCount => $composableBuilder(
    column: $table.failedCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$WordBooksTableAnnotationComposer get targetWordBookId {
    final $$WordBooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetWordBookId,
      referencedTable: $db.wordBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordBooksTableAnnotationComposer(
            $db: $db,
            $table: $db.wordBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> importErrorsRefs<T extends Object>(
    Expression<T> Function($$ImportErrorsTableAnnotationComposer a) f,
  ) {
    final $$ImportErrorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importErrors,
      getReferencedColumn: (t) => t.importRecordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportErrorsTableAnnotationComposer(
            $db: $db,
            $table: $db.importErrors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ImportRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImportRecordsTable,
          ImportRecord,
          $$ImportRecordsTableFilterComposer,
          $$ImportRecordsTableOrderingComposer,
          $$ImportRecordsTableAnnotationComposer,
          $$ImportRecordsTableCreateCompanionBuilder,
          $$ImportRecordsTableUpdateCompanionBuilder,
          (ImportRecord, $$ImportRecordsTableReferences),
          ImportRecord,
          PrefetchHooks Function({bool targetWordBookId, bool importErrorsRefs})
        > {
  $$ImportRecordsTableTableManager(_$AppDatabase db, $ImportRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> batchUuid = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String?> sourceFingerprint = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<int> targetWordBookId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int> totalRows = const Value.absent(),
                Value<int> successCount = const Value.absent(),
                Value<int> skippedCount = const Value.absent(),
                Value<int> failedCount = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => ImportRecordsCompanion(
                id: id,
                batchUuid: batchUuid,
                fileName: fileName,
                sourceFingerprint: sourceFingerprint,
                sourceType: sourceType,
                targetWordBookId: targetWordBookId,
                startedAt: startedAt,
                finishedAt: finishedAt,
                totalRows: totalRows,
                successCount: successCount,
                skippedCount: skippedCount,
                failedCount: failedCount,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String batchUuid,
                required String fileName,
                Value<String?> sourceFingerprint = const Value.absent(),
                required String sourceType,
                required int targetWordBookId,
                required DateTime startedAt,
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int> totalRows = const Value.absent(),
                Value<int> successCount = const Value.absent(),
                Value<int> skippedCount = const Value.absent(),
                Value<int> failedCount = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => ImportRecordsCompanion.insert(
                id: id,
                batchUuid: batchUuid,
                fileName: fileName,
                sourceFingerprint: sourceFingerprint,
                sourceType: sourceType,
                targetWordBookId: targetWordBookId,
                startedAt: startedAt,
                finishedAt: finishedAt,
                totalRows: totalRows,
                successCount: successCount,
                skippedCount: skippedCount,
                failedCount: failedCount,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImportRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({targetWordBookId = false, importErrorsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (importErrorsRefs) db.importErrors,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (targetWordBookId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.targetWordBookId,
                                    referencedTable:
                                        $$ImportRecordsTableReferences
                                            ._targetWordBookIdTable(db),
                                    referencedColumn:
                                        $$ImportRecordsTableReferences
                                            ._targetWordBookIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (importErrorsRefs)
                        await $_getPrefetchedData<
                          ImportRecord,
                          $ImportRecordsTable,
                          ImportError
                        >(
                          currentTable: table,
                          referencedTable: $$ImportRecordsTableReferences
                              ._importErrorsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).importErrorsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.importRecordId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ImportRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImportRecordsTable,
      ImportRecord,
      $$ImportRecordsTableFilterComposer,
      $$ImportRecordsTableOrderingComposer,
      $$ImportRecordsTableAnnotationComposer,
      $$ImportRecordsTableCreateCompanionBuilder,
      $$ImportRecordsTableUpdateCompanionBuilder,
      (ImportRecord, $$ImportRecordsTableReferences),
      ImportRecord,
      PrefetchHooks Function({bool targetWordBookId, bool importErrorsRefs})
    >;
typedef $$ImportErrorsTableCreateCompanionBuilder =
    ImportErrorsCompanion Function({
      Value<int> id,
      required int importRecordId,
      required int sourceRow,
      required String errorCode,
      required String message,
      Value<String?> rawData,
    });
typedef $$ImportErrorsTableUpdateCompanionBuilder =
    ImportErrorsCompanion Function({
      Value<int> id,
      Value<int> importRecordId,
      Value<int> sourceRow,
      Value<String> errorCode,
      Value<String> message,
      Value<String?> rawData,
    });

final class $$ImportErrorsTableReferences
    extends BaseReferences<_$AppDatabase, $ImportErrorsTable, ImportError> {
  $$ImportErrorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ImportRecordsTable _importRecordIdTable(_$AppDatabase db) => db
      .importRecords
      .createAlias('import_errors__import_record_id__import_records__id');

  $$ImportRecordsTableProcessedTableManager get importRecordId {
    final $_column = $_itemColumn<int>('import_record_id')!;

    final manager = $$ImportRecordsTableTableManager(
      $_db,
      $_db.importRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_importRecordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ImportErrorsTableFilterComposer
    extends Composer<_$AppDatabase, $ImportErrorsTable> {
  $$ImportErrorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceRow => $composableBuilder(
    column: $table.sourceRow,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawData => $composableBuilder(
    column: $table.rawData,
    builder: (column) => ColumnFilters(column),
  );

  $$ImportRecordsTableFilterComposer get importRecordId {
    final $$ImportRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importRecordId,
      referencedTable: $db.importRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportRecordsTableFilterComposer(
            $db: $db,
            $table: $db.importRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportErrorsTableOrderingComposer
    extends Composer<_$AppDatabase, $ImportErrorsTable> {
  $$ImportErrorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceRow => $composableBuilder(
    column: $table.sourceRow,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawData => $composableBuilder(
    column: $table.rawData,
    builder: (column) => ColumnOrderings(column),
  );

  $$ImportRecordsTableOrderingComposer get importRecordId {
    final $$ImportRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importRecordId,
      referencedTable: $db.importRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.importRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportErrorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImportErrorsTable> {
  $$ImportErrorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sourceRow =>
      $composableBuilder(column: $table.sourceRow, builder: (column) => column);

  GeneratedColumn<String> get errorCode =>
      $composableBuilder(column: $table.errorCode, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get rawData =>
      $composableBuilder(column: $table.rawData, builder: (column) => column);

  $$ImportRecordsTableAnnotationComposer get importRecordId {
    final $$ImportRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importRecordId,
      referencedTable: $db.importRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.importRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportErrorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImportErrorsTable,
          ImportError,
          $$ImportErrorsTableFilterComposer,
          $$ImportErrorsTableOrderingComposer,
          $$ImportErrorsTableAnnotationComposer,
          $$ImportErrorsTableCreateCompanionBuilder,
          $$ImportErrorsTableUpdateCompanionBuilder,
          (ImportError, $$ImportErrorsTableReferences),
          ImportError,
          PrefetchHooks Function({bool importRecordId})
        > {
  $$ImportErrorsTableTableManager(_$AppDatabase db, $ImportErrorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportErrorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportErrorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportErrorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> importRecordId = const Value.absent(),
                Value<int> sourceRow = const Value.absent(),
                Value<String> errorCode = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<String?> rawData = const Value.absent(),
              }) => ImportErrorsCompanion(
                id: id,
                importRecordId: importRecordId,
                sourceRow: sourceRow,
                errorCode: errorCode,
                message: message,
                rawData: rawData,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int importRecordId,
                required int sourceRow,
                required String errorCode,
                required String message,
                Value<String?> rawData = const Value.absent(),
              }) => ImportErrorsCompanion.insert(
                id: id,
                importRecordId: importRecordId,
                sourceRow: sourceRow,
                errorCode: errorCode,
                message: message,
                rawData: rawData,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImportErrorsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({importRecordId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (importRecordId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.importRecordId,
                                referencedTable: $$ImportErrorsTableReferences
                                    ._importRecordIdTable(db),
                                referencedColumn: $$ImportErrorsTableReferences
                                    ._importRecordIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ImportErrorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImportErrorsTable,
      ImportError,
      $$ImportErrorsTableFilterComposer,
      $$ImportErrorsTableOrderingComposer,
      $$ImportErrorsTableAnnotationComposer,
      $$ImportErrorsTableCreateCompanionBuilder,
      $$ImportErrorsTableUpdateCompanionBuilder,
      (ImportError, $$ImportErrorsTableReferences),
      ImportError,
      PrefetchHooks Function({bool importRecordId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WordBooksTableTableManager get wordBooks =>
      $$WordBooksTableTableManager(_db, _db.wordBooks);
  $$WordsTableTableManager get words =>
      $$WordsTableTableManager(_db, _db.words);
  $$WordBookItemsTableTableManager get wordBookItems =>
      $$WordBookItemsTableTableManager(_db, _db.wordBookItems);
  $$ReviewSchedulesTableTableManager get reviewSchedules =>
      $$ReviewSchedulesTableTableManager(_db, _db.reviewSchedules);
  $$ReviewRecordsTableTableManager get reviewRecords =>
      $$ReviewRecordsTableTableManager(_db, _db.reviewRecords);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$CourseSchedulesTableTableManager get courseSchedules =>
      $$CourseSchedulesTableTableManager(_db, _db.courseSchedules);
  $$PlansTableTableManager get plans =>
      $$PlansTableTableManager(_db, _db.plans);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$PomodoroSessionsTableTableManager get pomodoroSessions =>
      $$PomodoroSessionsTableTableManager(_db, _db.pomodoroSessions);
  $$ImportRecordsTableTableManager get importRecords =>
      $$ImportRecordsTableTableManager(_db, _db.importRecords);
  $$ImportErrorsTableTableManager get importErrors =>
      $$ImportErrorsTableTableManager(_db, _db.importErrors);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
