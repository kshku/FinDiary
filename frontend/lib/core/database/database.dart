import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';
import 'daos/transaction_dao.dart';
import 'daos/category_dao.dart';
import 'daos/family_dao.dart';
import 'daos/sync_meta_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Categories,
    Transactions,
    Families,
    FamilyMembers,
    SyncMeta,
    PendingChanges,
  ],
  daos: [
    TransactionDao,
    CategoryDao,
    FamilyDao,
    SyncMetaDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'findiary.db'));
    return NativeDatabase(file);
  });
}
