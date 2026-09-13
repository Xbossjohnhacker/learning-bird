import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import 'vocabulary_repository.dart';
import 'builtin_word_catalog.dart';
import '../domain/builtin_word_book.dart';

final builtinWordCatalogProvider = Provider<BuiltinWordCatalog>(
  (ref) => BuiltinWordCatalog(),
);
final builtinWordBooksProvider = FutureProvider<List<BuiltinWordBook>>(
  (ref) => ref.watch(builtinWordCatalogProvider).loadCatalog(),
);

final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) {
  return VocabularyRepository(ref.watch(databaseProvider));
});

final wordBooksProvider = StreamProvider.autoDispose<List<WordBookSummary>>((
  ref,
) {
  return ref.watch(vocabularyRepositoryProvider).watchWordBooks();
});

final studyQueueProvider = FutureProvider.autoDispose
    .family<List<StudyWord>, int>((ref, wordBookId) {
      return ref
          .watch(vocabularyRepositoryProvider)
          .loadDailyStudyQueue(wordBookId);
    });

final extraStudyQueueProvider = FutureProvider.autoDispose
    .family<List<StudyWord>, int>((ref, bookId) {
      return ref
          .watch(vocabularyRepositoryProvider)
          .loadDailyStudyQueue(bookId, extra: true);
    });

final dailyStudyProgressProvider = FutureProvider.autoDispose
    .family<DailyStudyProgress, int>((ref, bookId) {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day + 1);
      final timer = Timer(midnight.difference(now), () {
        ref.invalidate(studyQueueProvider(bookId));
        ref.invalidateSelf();
      });
      ref.onDispose(timer.cancel);
      return ref.watch(vocabularyRepositoryProvider).loadDailyProgress(bookId);
    });

final bookWordsProvider = StreamProvider.autoDispose
    .family<List<BookWord>, int>((ref, bookId) {
      return ref.watch(vocabularyRepositoryProvider).watchBookWords(bookId);
    });

final mistakeWordsProvider = StreamProvider.autoDispose<List<MistakeWord>>((
  ref,
) {
  return ref.watch(vocabularyRepositoryProvider).watchMistakeWords();
});

final mistakeStudyQueueProvider = FutureProvider.autoDispose<List<StudyWord>>((
  ref,
) {
  return ref.watch(vocabularyRepositoryProvider).loadMistakeStudyQueue();
});
