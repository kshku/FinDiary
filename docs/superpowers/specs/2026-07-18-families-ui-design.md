# Families UI Feature — Design Specification

**Date:** 2026-07-18
**Status:** Draft

## 1. Overview

Add the Families feature to the Flutter frontend: create/manage families, invite/accept members, switch scope between personal and family views, and show family-level financial data on the dashboard.

Family participation is optional. Solo users see no change. Users who create or join a family get an additional "family scope" alongside their personal scope.

## 2. Existing Code Context

The backend fully supports families (6 services, domain model, gRPC handlers, repository methods for CRUD + invitations). One gap: the `invitations` database migration is missing.

On the frontend:
- `FamilyBloc` exists with `FamiliesRequested`/`FamilyCreated` events and `FamilyInitial`/`FamilyLoading`/`FamilyLoaded`/`FamilyFailure` states
- `FamilyDao` handles local CRUD for `Families` and `FamilyMembers` tables
- `FamilyGrpcService` wraps all 9 gRPC endpoints
- `Families` and `FamilyMembers` local DB tables exist; no local `Invitations` table
- No UI pages exist — only bloc scaffolding

## 3. Pages & Navigation

### 3.1 Bottom Nav — Families Tab (Index 4)

Add a 5th `NavigationDestination` to the existing `_Shell`:

```
destinations: [
  Home,       // index 0
  Transactions, // index 1
  Categories, // index 2
  Families,   // NEW index 3
  Settings,   // move to index 4
]
```

Route: `/families` → `FamiliesPage`

### 3.2 FamiliesPage (Tab Content)

```
FamiliesPage
├── AppBar: "Families"
├── Pending Invitations banner — shows count, tap → InvitationsPage
├── Your Families list
│   └── Each row: family icon + name + member count + role badge
│       └── Tap → FamilyDetailPage(familyId)
├── FAB: Create family — opens dialog
└── Empty state: "No families yet. Create one or wait for an invitation."
```

Events to add to `FamilyBloc`:
- `FamilyListRequested` — load from local FamilyDao
- `CreateFamilySubmitted` — gRPC create + upsert local

### 3.3 CreateFamilyDialog

Simple dialog with a single text field (name). On submit: calls `FamilyGrpcService.createFamily()`, upserts to local DB, refreshes list.

### 3.4 FamilyDetailPage

Route: `/families/:familyId`

```
FamilyDetailPage
├── AppBar: family name
├── Info card: name, created date, your role
├── Members section
│   ├── List of members (avatar/initial, name, role badge)
│   └── Owner/Admin sees "Remove" button on each non-owner member
├── Invite Member button (Owner/Admin only) → opens dialog
├── Leave Family button (Member only)
└── Danger zone (Owner only): Delete Family
```

Events to add to `FamilyBloc`:
- `FamilyDetailRequested(familyId)` — load family + members
- `MemberRemoved(familyId, userId)`
- `FamilyDeleted(familyId)`
- `FamilyLeft(familyId)`

### 3.5 InviteMemberDialog

Dialog with email text field. Owner/Admin enters email, submits → `FamilyGrpcService.inviteMember()`. Shows success/error toast.

### 3.6 InvitationsPage

Shows all pending invitations for the current user. Accessed from the banner on FamiliesPage.

```
InvitationsPage
├── AppBar: "Invitations"
├── List of invitations
│   └── Each row: family name, invited by, status, accept/decline buttons
└── Empty state: "No pending invitations"
```

Events to add:
- `InvitationsRequested` — load from gRPC
- `InvitationAccepted(code)` — gRPC accept + sync families list

## 4. Scope Switcher

### 4.1 Component

A dropdown `PopupMenuButton` in the app bar of the Dashboard and Transactions pages (or as a shared widget). Displays:

```
[Personal]  ✓ (default scope)
───
[My Family]
[Other Family]
```

### 4.2 State Management

Create a `ScopeCubit` provided at the `MultiBlocProvider` level in `app.dart` (above the shell, so all pages can read it):

```dart
class ScopeCubit extends Cubit<Scope> {
  ScopeCubit() : super(const Scope.personal());

  void switchToPersonal() => emit(const Scope.personal());
  void switchToFamily(String familyId, String familyName) =>
      emit(Scope.family(familyId, familyName));
}

@immutable
class Scope {
  final String scopeId;    // "" for personal, family UUID otherwise
  final String scopeType;  // "personal" or "family"
  final String label;      // display name
}
```

The DashboardBloc and TransactionListBloc read the current scope to filter data. When scope changes, they refetch with the new scope.

### 4.3 Impact on Existing BLoCs

**DashboardBloc:** Add `scope` parameter to `DashboardRequested`. When scope is personal (`scopeId: ""`), sum personal transactions. When family (`scopeId: familyId`), sum that family's transactions via gRPC.

**TransactionListBloc:** Add `scope` filter. When personal, show transactions with `familyId = null`. When family, show transactions with `familyId = scopeId`. New transactions set `familyId` accordingly.

**SyncEngine:** Already supports scope via `scopeId`/`scopeType` parameters. The SyncEngine is initialized per-scope. For MVP, the personal scope engine is sufficient — family-scoped sync will be added when sync covers family entities. New transactions in the family scope are saved locally and synced via the personal engine's pending queue for now.

## 5. Local Database Changes

### 5.1 Invitations Table (New)

Invitations are fetched via gRPC directly (not part of the sync protocol for MVP). A local cache table prevents re-fetching on every page load.

```dart
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
```

### 5.2 FamilyDao Updates

Add methods for local cache: `listInvitations()`, `upsertInvitation()`, `removeInvitation()`. Caller fetches via gRPC then caches locally.

## 6. Backend Gaps

### 6.1 Invitations Migration

Create migration `000008_create_invitations`:

```sql
CREATE TABLE invitations (
    id          UUID PRIMARY KEY,
    family_id   UUID NOT NULL REFERENCES families(id),
    email       TEXT NOT NULL,
    code        TEXT NOT NULL UNIQUE,
    status      TEXT NOT NULL DEFAULT 'pending',
    created_by  UUID NOT NULL REFERENCES users(id),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at  TIMESTAMPTZ NOT NULL DEFAULT NOW() + INTERVAL '7 days'
);
CREATE INDEX idx_invitations_email ON invitations(email);
CREATE INDEX idx_invitations_code ON invitations(code);
```

## 7. Router Updates

```dart
GoRoute(path: '/families', builder: ...)          // FamiliesPage
GoRoute(path: '/families/:id', builder: ...)      // FamilyDetailPage
GoRoute(path: '/invitations', builder: ...)       // InvitationsPage
```

Update `_calculateIndex` and `_goTab` to handle index 3 (Families) and shift Settings to 4.

## 8. Implementation Order

1. Backend: add invitations migration (000008)
2. Local DB: add Invitations table, update FamilyDao, regenerate drift code
3. FamiliesPage + CreateFamilyDialog + FamilyBloc updates
4. InvitationsPage + InviteMemberDialog
5. FamilyDetailPage + member management
6. ScopeCubit + scope switcher widget
7. Wire scope into DashboardBloc and TransactionListBloc
8. Router updates (add tab, routes, fix indexes)
9. Tests: FamilyBloc tests, FamiliesPage widget tests, scope switching

## 9. Testing

- Update existing `family_bloc_test.dart` for new events
- Widget tests for FamiliesPage, FamilyDetailPage, InvitationsPage
- Scope cubit unit test
- Update dashboard_bloc_test and transaction_list_bloc_test for scope filtering
- Backend: manual verification that sync works per-scope
