import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// The single local database, the source of truth for every screen (D-1).
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
