import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:fixnum/fixnum.dart';

import 'package:findiary/core/sync/sync_engine.dart';
import 'package:findiary/core/sync/sync_service.dart';
import 'package:findiary/core/database/database.dart';
import 'package:findiary/core/database/daos/sync_meta_dao.dart';
import 'package:findiary/core/database/daos/transaction_dao.dart';
import 'package:findiary/generated/findiary/v1/sync_service.pb.dart';

class MockSyncMetaDao extends Mock implements SyncMetaDao {}
class MockTransactionDao extends Mock implements TransactionDao {}

void main() {
  late MockSyncMetaDao mockSyncMetaDao;
  late MockTransactionDao mockTransactionDao;

  setUpAll(() {
    registerFallbackValue(const SyncMetaCompanion());
    registerFallbackValue(0);
  });

  setUp(() {
    mockSyncMetaDao = MockSyncMetaDao();
    mockTransactionDao = MockTransactionDao();

    when(() => mockSyncMetaDao.removePendingChange(any()))
        .thenAnswer((_) async {});
    when(() => mockSyncMetaDao.upsertMeta(any()))
        .thenAnswer((_) async {});
  });

  group('SyncEngine', () {
    test('syncNow performs full sync cycle', () async {
      when(() => mockSyncMetaDao.getMeta('user-1', 'personal'))
          .thenAnswer((_) async => SyncMetaData(
            scopeId: 'user-1',
            scopeType: 'personal',
            lastCheckpoint: 10,
            lastSyncedAt: null,
          ));

      when(() => mockSyncMetaDao.getPendingChanges())
          .thenAnswer((_) async => [
            PendingChange(
              id: 1,
              entityType: 'transaction',
              entityId: 'tx-1',
              action: 'update',
              payload: '{"id":"tx-1"}',
              createdAt: '2026-07-11T00:00:00Z',
              retryCount: 0,
            ),
          ]);

      var syncCalled = false;
      final engine = SyncEngine(
        syncService: SyncService((request) async {
          syncCalled = true;
          expect(request.scopeId, 'user-1');
          expect(request.scopeType, 'personal');
          expect(request.lastCheckpoint, Int64(10));
          expect(request.localChanges.length, 1);
          return SyncResponse(
            newCheckpoint: Int64(42),
            remoteChanges: [],
            conflicts: [],
          );
        }),
        syncMetaDao: mockSyncMetaDao,
        transactionDao: mockTransactionDao,
        scopeId: 'user-1',
        scopeType: 'personal',
      );

      final result = await engine.syncNow();

      expect(result, SyncResult.success);
      expect(syncCalled, isTrue);
      verify(() => mockSyncMetaDao.upsertMeta(any())).called(1);
      verify(() => mockSyncMetaDao.removePendingChange(1)).called(1);
    });

    test('syncNow handles gRPC errors gracefully', () async {
      when(() => mockSyncMetaDao.getMeta('user-1', 'personal'))
          .thenAnswer((_) async => SyncMetaData(
            scopeId: 'user-1',
            scopeType: 'personal',
            lastCheckpoint: 10,
            lastSyncedAt: null,
          ));

      when(() => mockSyncMetaDao.getPendingChanges())
          .thenAnswer((_) async => [
            PendingChange(
              id: 1,
              entityType: 'transaction',
              entityId: 'tx-1',
              action: 'update',
              payload: '{"id":"tx-1"}',
              createdAt: '2026-07-11T00:00:00Z',
              retryCount: 0,
            ),
          ]);

      final engine = SyncEngine(
        syncService: SyncService((request) async {
          throw Exception('Service unavailable');
        }),
        syncMetaDao: mockSyncMetaDao,
        transactionDao: mockTransactionDao,
        scopeId: 'user-1',
        scopeType: 'personal',
      );

      final result = await engine.syncNow();

      expect(result, SyncResult.failure);
    });
  });
}
