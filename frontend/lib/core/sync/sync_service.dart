import 'dart:convert';

import 'package:fixnum/fixnum.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

import '../../generated/findiary/v1/sync_service.pb.dart';
import '../database/database.dart';

class SyncService {
  final Future<SyncResponse> Function(SyncRequest) _performSync;

  SyncService(Future<SyncResponse> Function(SyncRequest) performSync)
      : _performSync = performSync;

  Future<SyncResponse> sync({
    required String scopeId,
    required String scopeType,
    required Int64 lastCheckpoint,
    required List<PendingChange> localChanges,
  }) async {
    final request = SyncRequest(
      scopeId: scopeId,
      scopeType: scopeType,
      lastCheckpoint: lastCheckpoint,
      localChanges: localChanges.map(_toSyncChangeEntry).toList(),
    );
    return _performSync(request);
  }

  SyncChangeEntry _toSyncChangeEntry(PendingChange change) {
    return SyncChangeEntry(
      entityType: change.entityType,
      entityId: change.entityId,
      action: change.action,
      snapshot: utf8.encode(change.payload),
      clientTimestamp: Timestamp.fromDateTime(DateTime.now()),
    );
  }
}
