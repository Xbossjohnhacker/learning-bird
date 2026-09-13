import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final databaseHealthProvider = FutureProvider<bool>((ref) async {
  final database = ref.watch(databaseProvider);
  return database.ping();
});
