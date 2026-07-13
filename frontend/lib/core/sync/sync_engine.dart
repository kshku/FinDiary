import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';

import '../../generated/findiary/v1/sync_service.pb.dart';
import '../database/database.dart';
import '../database/daos/category_dao.dart';
import '../database/daos/sync_meta_dao.dart';
import '../database/daos/transaction_dao.dart';
import '../network/connectivity_notifier.dart';
import 'sync_service.dart';

enum SyncResult { success, failure }
enum SyncStatus { idle, syncing, success, failure }

class SyncEngine with WidgetsBindingObserver {
  final SyncService _syncService;
  final SyncMetaDao _syncMetaDao;
  final TransactionDao _transactionDao;
  final CategoryDao _categoryDao;
  final ConnectivityNotifier _connectivityNotifier;
  final String _scopeId;
  final String _scopeType;
  StreamSubscription<bool>? _connectivitySub;

  bool _isSyncing = false;
  bool _isApplyingRemote = false;
  Timer? _debounceTimer;
  int _backoffDelay = 1;
  static const int _maxBackoff = 30;
  bool autoSyncEnabled = true;
  final StreamController<SyncStatus> _syncStatusController =
      StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  SyncEngine({
    required SyncService syncService,
    required SyncMetaDao syncMetaDao,
    required TransactionDao transactionDao,
    required CategoryDao categoryDao,
    required ConnectivityNotifier connectivityNotifier,
    required String scopeId,
    required String scopeType,
  })  : _syncService = syncService,
        _syncMetaDao = syncMetaDao,
        _transactionDao = transactionDao,
        _categoryDao = categoryDao,
        _connectivityNotifier = connectivityNotifier,
        _scopeId = scopeId,
        _scopeType = scopeType;

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _transactionDao.onPendingChange = _onPendingChange;
    _connectivitySub = _connectivityNotifier.onConnectivityChanged.listen((online) {
      if (online && autoSyncEnabled) {
        unawaited(syncNow());
      }
    });
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();
    _transactionDao.onPendingChange = null;
    _connectivitySub?.cancel();
    _syncStatusController.close();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && autoSyncEnabled) {
      unawaited(syncNow());
    }
  }

  void _onPendingChange() {
    if (_isApplyingRemote || !autoSyncEnabled) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      unawaited(syncNow());
    });
  }

  Future<SyncResult> syncNow() async {
    if (_isSyncing) return SyncResult.success;
    if (!_connectivityNotifier.isOnline) return SyncResult.failure;
    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);

    try {
      final meta = await _syncMetaDao.getMeta(_scopeId, _scopeType);
      final checkpoint = meta?.lastCheckpoint ?? 0;
      final pendingChanges = await _syncMetaDao.getPendingChanges();

      if (pendingChanges.isEmpty && meta != null) {
        _resetBackoff();
        _syncStatusController.add(SyncStatus.success);
        return SyncResult.success;
      }

      final response = await _syncService.sync(
        scopeId: _scopeId,
        scopeType: _scopeType,
        lastCheckpoint: Int64(checkpoint),
        localChanges: pendingChanges,
      );

      await _applyRemoteChanges(response.remoteChanges);

      for (final change in pendingChanges) {
        await _syncMetaDao.removePendingChange(change.id);
      }

      await _syncMetaDao.upsertMeta(SyncMetaCompanion(
        scopeId: Value(_scopeId),
        scopeType: Value(_scopeType),
        lastCheckpoint: Value(response.newCheckpoint.toInt()),
        lastSyncedAt: Value(DateTime.now().toIso8601String()),
      ));

      _resetBackoff();
      _syncStatusController.add(SyncStatus.success);
      return SyncResult.success;
    } catch (_) {
      _scheduleRetry();
      _syncStatusController.add(SyncStatus.failure);
      return SyncResult.failure;
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _applyRemoteChanges(List<SyncChangeEntry> changes) async {
    _isApplyingRemote = true;
    for (final change in changes) {
      final payload = utf8.decode(change.snapshot);
      final data = jsonDecode(payload) as Map<String, dynamic>;

      switch (change.entityType) {
        case 'transaction':
          await _transactionDao.upsertTransaction(TransactionsCompanion(
            id: Value(data['id'] as String),
            createdBy: Value(data['created_by'] as String? ?? ''),
            type: Value(data['type'] as String? ?? ''),
            amount: Value((data['amount'] as num).toDouble()),
            currency: Value(data['currency'] as String? ?? 'INR'),
            categoryId: Value(data['category_id'] as String? ?? ''),
            date: Value(data['date'] as String? ?? ''),
            createdAt: Value(data['created_at'] as String? ?? DateTime.now().toIso8601String()),
            updatedAt: Value(data['updated_at'] as String? ?? DateTime.now().toIso8601String()),
          ), skipHook: true);
        case 'category':
          await _categoryDao.upsertCategory(CategoriesCompanion(
            id: Value(data['id'] as String),
            scope: Value(data['scope'] as String? ?? 'personal'),
            name: Value(data['name'] as String? ?? ''),
            type: Value(data['type'] as String? ?? ''),
            icon: Value<String?>(data['icon'] as String?),
            color: Value<String?>(data['color'] as String?),
            createdAt: Value(data['created_at'] as String? ?? DateTime.now().toIso8601String()),
            updatedAt: Value(data['updated_at'] as String? ?? DateTime.now().toIso8601String()),
          ));
      }
    }
    _isApplyingRemote = false;
  }

  void _resetBackoff() {
    _backoffDelay = 1;
  }

  void _scheduleRetry() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(seconds: _backoffDelay), () {
      unawaited(syncNow());
    });
    _backoffDelay = (_backoffDelay * 2).clamp(1, _maxBackoff);
  }
}
