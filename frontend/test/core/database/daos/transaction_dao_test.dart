import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

import 'package:findiary/core/database/database.dart';
import 'package:findiary/core/database/daos/transaction_dao.dart';

void main() {
  late AppDatabase db;
  late TransactionDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = TransactionDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('TransactionDao hooks', () {
    test('upsertTransaction creates PendingChange entry', () async {
      int callbackCalls = 0;
      dao.onPendingChange = () => callbackCalls++;

      await dao.upsertTransaction(TransactionsCompanion(
        id: Value('tx-1'),
        createdBy: Value('user-1'),
        type: Value('expense'),
        amount: Value(100.0),
        currency: const Value('INR'),
        categoryId: Value('cat-1'),
        date: Value('2026-07-11'),
        createdAt: Value('2026-07-11T00:00:00Z'),
        updatedAt: Value('2026-07-11T00:00:00Z'),
      ));

      final pending = await db.pendingChanges.select().get();
      expect(pending.length, 1);
      expect(pending.first.entityType, 'transaction');
      expect(pending.first.entityId, 'tx-1');
      expect(pending.first.action, 'update');
      expect(pending.first.payload, contains('"id":"tx-1"'));
      expect(callbackCalls, 1);
    });

    test('softDeleteTransaction creates PendingChange entry', () async {
      // First insert a transaction
      await dao.upsertTransaction(TransactionsCompanion(
        id: Value('tx-2'),
        createdBy: Value('user-1'),
        type: Value('income'),
        amount: Value(200.0),
        currency: const Value('INR'),
        categoryId: Value('cat-2'),
        date: Value('2026-07-11'),
        createdAt: Value('2026-07-11T00:00:00Z'),
        updatedAt: Value('2026-07-11T00:00:00Z'),
      ));

      int callbackCalls = 0;
      dao.onPendingChange = () => callbackCalls++;

      await dao.softDeleteTransaction('tx-2');

      final pending = await db.pendingChanges.select().get();
      // Should have 2: one from upsert, one from delete
      expect(pending.length, 2);
      expect(pending.last.entityType, 'transaction');
      expect(pending.last.entityId, 'tx-2');
      expect(pending.last.action, 'delete');
      expect(callbackCalls, 1);
    });
  });
}
