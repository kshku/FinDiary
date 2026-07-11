import 'package:flutter_test/flutter_test.dart';
import 'package:fixnum/fixnum.dart';

import 'package:findiary/core/database/database.dart';
import 'package:findiary/generated/findiary/v1/sync_service.pb.dart';
import 'package:findiary/core/sync/sync_service.dart';

SyncRequest? capturedRequest;

void main() {
  late SyncService syncService;

  setUp(() {
    capturedRequest = null;
    syncService = SyncService((request) async {
      capturedRequest = request;
      return SyncResponse(
        newCheckpoint: Int64(42),
        remoteChanges: [],
        conflicts: [],
      );
    });
  });

  group('SyncService', () {
    test('sync() converts PendingChanges to SyncChangeEntry protos', () async {
      final pendingChanges = [
        PendingChange(
          id: 1,
          entityType: 'transaction',
          entityId: 'tx-1',
          action: 'update',
          payload: '{"id":"tx-1","amount":100}',
          createdAt: '2026-07-11T00:00:00Z',
          retryCount: 0,
        ),
      ];

      final response = await syncService.sync(
        scopeId: 'user-1',
        scopeType: 'personal',
        lastCheckpoint: Int64(10),
        localChanges: pendingChanges,
      );

      expect(response.newCheckpoint, Int64(42));
      expect(response.remoteChanges, isEmpty);
      expect(response.conflicts, isEmpty);

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.scopeId, 'user-1');
      expect(capturedRequest!.scopeType, 'personal');
      expect(capturedRequest!.lastCheckpoint, Int64(10));
      expect(capturedRequest!.localChanges.length, 1);
      expect(capturedRequest!.localChanges.first.entityType, 'transaction');
      expect(capturedRequest!.localChanges.first.entityId, 'tx-1');
      expect(capturedRequest!.localChanges.first.action, 'update');
      expect(capturedRequest!.localChanges.first.snapshot,
          [123, 34, 105, 100, 34, 58, 34, 116, 120, 45, 49, 34, 44, 34, 97, 109, 111, 117, 110, 116, 34, 58, 49, 48, 48, 125]);
      expect(capturedRequest!.localChanges.first.hasClientTimestamp(), isTrue);
    });
  });
}
