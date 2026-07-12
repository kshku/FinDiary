import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixnum/fixnum.dart';

import 'package:findiary/core/sync/sync_engine.dart';
import 'package:findiary/core/sync/sync_service.dart';
import 'package:findiary/core/network/connectivity_notifier.dart';
import 'package:findiary/core/database/database.dart';
import 'package:findiary/core/database/daos/category_dao.dart';
import 'package:findiary/core/database/daos/sync_meta_dao.dart';
import 'package:findiary/core/database/daos/transaction_dao.dart';
import 'package:findiary/generated/findiary/v1/sync_service.pb.dart';

class MockSyncMetaDao extends Mock implements SyncMetaDao {}
class MockTransactionDao extends Mock implements TransactionDao {}
class MockCategoryDao extends Mock implements CategoryDao {}
class MockConnectivityNotifier extends Mock implements ConnectivityNotifier {}

void main() {
  late MockSyncMetaDao mockSyncMetaDao;
  late MockTransactionDao mockTransactionDao;
  late MockCategoryDao mockCategoryDao;
  late MockConnectivityNotifier mockConnectivity;

  setUpAll(() {
    registerFallbackValue(const SyncMetaCompanion());
    registerFallbackValue(0);
  });

  setUp(() {
    mockSyncMetaDao = MockSyncMetaDao();
    mockTransactionDao = MockTransactionDao();
    mockCategoryDao = MockCategoryDao();
    mockConnectivity = MockConnectivityNotifier();

    when(() => mockSyncMetaDao.removePendingChange(any()))
        .thenAnswer((_) async {});
    when(() => mockSyncMetaDao.upsertMeta(any()))
        .thenAnswer((_) async {});
  });

  group('SyncEngine', () {
    test('syncNow performs full sync cycle', () async {
      when(() => mockConnectivity.isOnline).thenReturn(true);

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
        categoryDao: mockCategoryDao,
        connectivityNotifier: mockConnectivity,
        scopeId: 'user-1',
        scopeType: 'personal',
      );

      final result = await engine.syncNow();

      expect(result, SyncResult.success);
      expect(syncCalled, isTrue);
      verify(() => mockSyncMetaDao.upsertMeta(any())).called(1);
      verify(() => mockSyncMetaDao.removePendingChange(1)).called(1);
    });

    test('syncNow skips sync when offline', () async {
      when(() => mockConnectivity.isOnline).thenReturn(false);

      when(() => mockSyncMetaDao.getMeta('user-1', 'personal'))
          .thenAnswer((_) async => SyncMetaData(
            scopeId: 'user-1',
            scopeType: 'personal',
            lastCheckpoint: 10,
            lastSyncedAt: null,
          ));

      when(() => mockSyncMetaDao.getPendingChanges())
          .thenAnswer((_) async => []);

      final engine = SyncEngine(
        syncService: SyncService((request) async {
          throw Exception('Should not be called');
        }),
        syncMetaDao: mockSyncMetaDao,
        transactionDao: mockTransactionDao,
        categoryDao: mockCategoryDao,
        connectivityNotifier: mockConnectivity,
        scopeId: 'user-1',
        scopeType: 'personal',
      );

      final result = await engine.syncNow();

      expect(result, SyncResult.failure);
      verifyNever(() => mockSyncMetaDao.upsertMeta(any()));
    });

    test('syncNow handles gRPC errors gracefully', () async {
      when(() => mockConnectivity.isOnline).thenReturn(true);

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
        categoryDao: mockCategoryDao,
        connectivityNotifier: mockConnectivity,
        scopeId: 'user-1',
        scopeType: 'personal',
      );

      final result = await engine.syncNow();

      expect(result, SyncResult.failure);
    });

    test('start subscribes to connectivity changes and triggers sync on reconnect', () async {
      when(() => mockConnectivity.isOnline).thenReturn(true);

      when(() => mockSyncMetaDao.getMeta('user-1', 'personal'))
          .thenAnswer((_) async => SyncMetaData(
            scopeId: 'user-1',
            scopeType: 'personal',
            lastCheckpoint: 10,
            lastSyncedAt: null,
          ));

      when(() => mockSyncMetaDao.getPendingChanges())
          .thenAnswer((_) async => []);

      final engine = SyncEngine(
        syncService: SyncService((request) async {
          return SyncResponse(
            newCheckpoint: Int64(42),
            remoteChanges: [],
            conflicts: [],
          );
        }),
        syncMetaDao: mockSyncMetaDao,
        transactionDao: mockTransactionDao,
        categoryDao: mockCategoryDao,
        connectivityNotifier: mockConnectivity,
        scopeId: 'user-1',
        scopeType: 'personal',
      );

      final controller = StreamController<bool>.broadcast();
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => controller.stream);

      engine.start();

      controller.add(true);
      await Future.delayed(const Duration(milliseconds: 100));

      verify(() => mockSyncMetaDao.upsertMeta(any())).called(1);

      await controller.close();
      engine.dispose();
    });
  });
}
