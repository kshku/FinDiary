import 'package:drift/drift.dart';
import '../database.dart';

class SyncMetaDao extends DatabaseAccessor<AppDatabase> {
  SyncMetaDao(super.db);

  Future<SyncMetaData?> getMeta(String scopeId, String scopeType) {
    return (select(db.syncMeta)
      ..where((m) => m.scopeId.equals(scopeId) & m.scopeType.equals(scopeType)))
      .getSingleOrNull();
  }

  Future<void> upsertMeta(SyncMetaCompanion entry) {
    return into(db.syncMeta).insertOnConflictUpdate(entry);
  }

  Future<List<SyncMetaData>> getAllMeta() {
    return select(db.syncMeta).get();
  }

  Future<void> addPendingChange(PendingChange entry) {
    return into(db.pendingChanges).insert(entry);
  }

  Future<List<PendingChange>> getPendingChanges() {
    return (select(db.pendingChanges)
      ..orderBy([(p) => OrderingTerm.asc(p.id)])).get();
  }

  Future<void> removePendingChange(int id) {
    return (delete(db.pendingChanges)..where((p) => p.id.equals(id))).go();
  }
}
