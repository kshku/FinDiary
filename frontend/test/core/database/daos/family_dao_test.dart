import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:findiary/core/database/database.dart';
import 'package:findiary/core/database/daos/family_dao.dart';

void main() {
  late AppDatabase db;
  late FamilyDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = FamilyDao(db);
  });

  tearDown(() => db.close());

  group('FamilyDao', () {
    test('upsertInvitation and listInvitations', () async {
      await dao.upsertInvitation(InvitationsCompanion(
        id: const Value('inv-1'),
        familyId: const Value('fam-1'),
        familyName: const Value('My Family'),
        email: const Value('test@test.com'),
        code: const Value('code-123'),
        status: const Value('pending'),
        createdBy: const Value('user-1'),
        createdAt: const Value('2026-07-18'),
        expiresAt: const Value('2026-07-25'),
      ));
      final list = await dao.listInvitations();
      expect(list.length, 1);
      expect(list.first.familyName, 'My Family');
    });

    test('removeInvitation', () async {
      await dao.upsertInvitation(InvitationsCompanion(
        id: const Value('inv-1'),
        familyId: const Value('fam-1'),
        familyName: const Value('My Family'),
        email: const Value('test@test.com'),
        code: const Value('code-123'),
        status: const Value('pending'),
        createdBy: const Value('user-1'),
        createdAt: const Value('2026-07-18'),
        expiresAt: const Value('2026-07-25'),
      ));
      await dao.removeInvitation('inv-1');
      final list = await dao.listInvitations();
      expect(list, isEmpty);
    });
  });
}