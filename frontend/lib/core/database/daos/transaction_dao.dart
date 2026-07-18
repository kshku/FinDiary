import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import '../database.dart';

class TransactionDao extends DatabaseAccessor<AppDatabase> {
  TransactionDao(super.db);

  VoidCallback? onPendingChange;

  Future<void> upsertTransaction(TransactionsCompanion entry, {bool skipHook = false}) {
    if (skipHook) return into(db.transactions).insertOnConflictUpdate(entry);
    _onChange(entry.id.value, 'update', {
      'id': entry.id.value,
      'type': entry.type.value,
      'amount': entry.amount.value,
      'currency': entry.currency.value,
      'category_id': entry.categoryId.value,
      'date': entry.date.value,
      if (entry.description.present) 'description': entry.description.value,
      if (entry.familyId.present) 'family_id': entry.familyId.value,
    });
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

  Future<double> sumTransactions({String? familyId, String? type}) async {
    var query = selectOnly(db.transactions)
      ..addColumns([db.transactions.amount])
      ..where(db.transactions.deletedAt.isNull());

    if (familyId != null) {
      query.where(db.transactions.familyId.equals(familyId));
    } else {
      query.where(db.transactions.familyId.isNull());
    }
    if (type != null && type.isNotEmpty) {
      query.where(db.transactions.type.equals(type));
    }

    final rows = await query.get();
    double total = 0;
    for (final row in rows) {
      total += row.read(db.transactions.amount) ?? 0;
    }
    return total;
  }

  Future<void> softDeleteTransaction(String id) {
    _onChange(id, 'delete', {'id': id});
    return (update(db.transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(deletedAt: Value(DateTime.now().toIso8601String())),
    );
  }

  Future<void> markPendingSync(String id) {
    return (update(db.transactions)..where((t) => t.id.equals(id))).write(
      const TransactionsCompanion(syncStatus: Value(1)),
    );
  }

  void _onChange(String entityId, String action, Map<String, dynamic> data) {
    into(db.pendingChanges).insert(PendingChangesCompanion(
      entityType: Value('transaction'),
      entityId: Value(entityId),
      action: Value(action),
      payload: Value(jsonEncode(data)),
      createdAt: Value(DateTime.now().toIso8601String()),
    ));
    onPendingChange?.call();
  }
}
