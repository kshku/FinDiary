import 'package:drift/drift.dart';
import '../database.dart';

class TransactionDao extends DatabaseAccessor<AppDatabase> {
  TransactionDao(super.db);

  Future<void> upsertTransaction(TransactionsCompanion entry) {
    return into(db.transactions).insertOnConflictUpdate(entry);
  }

  Future<Transaction?> getTransaction(String id) {
    return (select(db.transactions)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<Transaction>> listTransactions({
    String? familyId,
    String? type,
    String? categoryId,
    String? startDate,
    String? endDate,
    int limit = 50,
    int offset = 0,
  }) {
    var query = select(db.transactions)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.date)])
      ..limit(limit, offset: offset);

    if (familyId != null) {
      query.where((t) => t.familyId.equals(familyId));
    } else {
      query.where((t) => t.familyId.isNull());
    }
    if (type != null && type.isNotEmpty) {
      query.where((t) => t.type.equals(type));
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      query.where((t) => t.categoryId.equals(categoryId));
    }
    if (startDate != null && startDate.isNotEmpty) {
      query.where((t) => t.date.isBiggerThanValue(startDate));
    }
    if (endDate != null && endDate.isNotEmpty) {
      query.where((t) => t.date.isSmallerThanValue(endDate));
    }

    return query.get();
  }

  Future<int> countTransactions({String? familyId, String? type}) {
    var query = select(db.transactions)
      ..where((t) => t.deletedAt.isNull());

    if (familyId != null) {
      query.where((t) => t.familyId.equals(familyId));
    } else {
      query.where((t) => t.familyId.isNull());
    }
    if (type != null && type.isNotEmpty) {
      query.where((t) => t.type.equals(type));
    }

    return query.map((_) => null).get().then((rows) => rows.length);
  }

  Future<void> softDeleteTransaction(String id) {
    return (update(db.transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(deletedAt: Value(DateTime.now().toIso8601String())),
    );
  }

  Future<void> markPendingSync(String id) {
    return (update(db.transactions)..where((t) => t.id.equals(id))).write(
      const TransactionsCompanion(syncStatus: Value(1)),
    );
  }
}
