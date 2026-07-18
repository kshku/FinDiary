import 'package:drift/drift.dart';
import '../database.dart';

class FamilyDao extends DatabaseAccessor<AppDatabase> {
  FamilyDao(super.db);

  Future<List<Family>> listFamilies() {
    return select(db.families).get();
  }

  Future<Family?> getFamily(String id) {
    return (select(db.families)..where((f) => f.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsertFamily(FamiliesCompanion entry) {
    return into(db.families).insertOnConflictUpdate(entry);
  }

  Future<void> removeFamily(String id) {
    return (delete(db.families)..where((f) => f.id.equals(id))).go();
  }

  Future<List<FamilyMember>> listMembers(String familyId) {
    return (select(db.familyMembers)
      ..where((m) => m.familyId.equals(familyId))
    ).get();
  }

  Future<void> addMember(FamilyMembersCompanion entry) {
    return into(db.familyMembers).insertOnConflictUpdate(entry);
  }

  Future<void> removeMember(String familyId, String userId) {
    return (delete(db.familyMembers)
      ..where((m) => m.familyId.equals(familyId) & m.userId.equals(userId))
    ).go();
  }

  Future<List<Invitation>> listInvitations() {
    return select(db.invitations).get();
  }

  Future<void> upsertInvitation(InvitationsCompanion entry) {
    return into(db.invitations).insertOnConflictUpdate(entry);
  }

  Future<void> removeInvitation(String id) {
    return (delete(db.invitations)..where((i) => i.id.equals(id))).go();
  }
}
