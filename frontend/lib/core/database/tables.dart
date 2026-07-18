import 'package:drift/drift.dart';

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get scope => text()();
  TextColumn? get familyId => text().nullable()();
  TextColumn? get createdBy => text().nullable()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn? get icon => text().nullable()();
  TextColumn? get color => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn? get familyId => text().nullable()();
  TextColumn get createdBy => text()();
  TextColumn get type => text()();
  RealColumn get amount => real()();
  TextColumn get currency => text()();
  TextColumn get categoryId => text()();
  TextColumn? get description => text().nullable()();
  TextColumn get date => text()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn? get deletedAt => text().nullable()();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class Families extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get ownerId => text()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class FamilyMembers extends Table {
  TextColumn get familyId => text()();
  TextColumn get userId => text()();
  TextColumn get role => text()();
  TextColumn get joinedAt => text()();
  TextColumn? get invitedBy => text().nullable()();

  @override
  Set<Column> get primaryKey => {familyId, userId};
}

class SyncMeta extends Table {
  TextColumn get scopeId => text()();
  TextColumn get scopeType => text()();
  IntColumn get lastCheckpoint => integer().withDefault(const Constant(0))();
  TextColumn get lastSyncedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {scopeId, scopeType};
}

class PendingChanges extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get action => text()();
  TextColumn get payload => text()();
  TextColumn get createdAt => text()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
}

class Invitations extends Table {
  TextColumn get id => text()();
  TextColumn get familyId => text()();
  TextColumn get familyName => text()();
  TextColumn get email => text()();
  TextColumn get code => text()();
  TextColumn get status => text()();
  TextColumn get createdBy => text()();
  TextColumn get createdAt => text()();
  TextColumn get expiresAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}
