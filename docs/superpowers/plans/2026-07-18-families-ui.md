# Families UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add families feature UI to the Flutter frontend — family CRUD, member management, invitations, and personal/family scope switching.

**Architecture:** Families get a new bottom nav tab (index 3, Settings moves to 4). `FamilyBloc` handles family CRUD + member + invitation events. A `ScopeCubit` at the app level manages personal vs family scope, which DashboardBloc and TransactionListBloc read to filter data. Invitations cached in a new local `Invitations` drift table.

**Tech Stack:** Flutter (dart), flutter_bloc, go_router, drift (SQLite), grpc, get_it

**Note:** The backend migration `000002_create_families` already creates the `invitations` table. No new backend migration needed.

---

### Task 1: Local Invitations Table + FamilyDao Updates

**Files:**
- Modify: `frontend/lib/core/database/tables.dart`
- Modify: `frontend/lib/core/database/daos/family_dao.dart`
- Modify: `frontend/lib/core/database/database.dart`
- Test: `frontend/test/core/database/daos/family_dao_test.dart`

- [ ] **Step 1: Write the failing test**

Create `frontend/test/core/database/daos/family_dao_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:findiary/core/database/database.dart';

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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/database/daos/family_dao_test.dart`
Expected: FAIL — class `Invitations` not found, `InvitationsCompanion` not found

- [ ] **Step 3: Add Invitations table to `tables.dart`**

Add before the closing `}` of the file (or after `PendingChanges`):

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

- [ ] **Step 4: Add Invitations to `database.dart` table list and run build_runner**

In `database.dart`, add `Invitations` to the tables list:

```dart
@DriftDatabase(
  tables: [
    Categories,
    Transactions,
    Families,
    FamilyMembers,
    SyncMeta,
    PendingChanges,
    Invitations, // NEW
  ],
  daos: [
    TransactionDao,
    CategoryDao,
    FamilyDao,
    SyncMetaDao,
  ],
)
```

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 5: Add invitation methods to `FamilyDao`**

Add to `frontend/lib/core/database/daos/family_dao.dart`:

```dart
  Future<List<Invitation>> listInvitations() {
    return select(db.invitations).get();
  }

  Future<void> upsertInvitation(InvitationsCompanion entry) {
    return into(db.invitations).insertOnConflictUpdate(entry);
  }

  Future<void> removeInvitation(String id) {
    return (delete(db.invitations)..where((i) => i.id.equals(id))).go();
  }
```

- [ ] **Step 6: Run test to verify it passes**

Run: `flutter test test/core/database/daos/family_dao_test.dart`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add frontend/lib/core/database/tables.dart \
       frontend/lib/core/database/database.dart \
       frontend/lib/core/database/database.g.dart \
       frontend/lib/core/database/daos/family_dao.dart \
       frontend/test/core/database/daos/family_dao_test.dart
git commit -m "feat: add Invitations table and FamilyDao methods"
```

---

### Task 2: FamilyBloc — New Events for Pages

**Files:**
- Modify: `frontend/lib/features/families/bloc/family_event.dart`
- Modify: `frontend/lib/features/families/bloc/family_state.dart`
- Modify: `frontend/lib/features/families/bloc/family_bloc.dart`
- Test: `frontend/test/features/families/family_bloc_test.dart`

- [ ] **Step 1: Write the failing test**

Update `frontend/test/features/families/family_bloc_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:findiary/core/database/database.dart';
import 'package:findiary/core/database/daos/family_dao.dart';
import 'package:findiary/core/grpc/family_service.dart';
import 'package:findiary/features/families/bloc/family_bloc.dart';
import 'package:findiary/features/families/bloc/family_event.dart';
import 'package:findiary/features/families/bloc/family_state.dart';

class MockFamilyDao extends Mock implements FamilyDao {}
class MockFamilyGrpcService extends Mock implements FamilyGrpcService {}

void main() {
  late FamilyBloc bloc;
  late MockFamilyDao mockDao;
  late MockFamilyGrpcService mockGrpc;

  setUp(() {
    mockDao = MockFamilyDao();
    mockGrpc = MockFamilyGrpcService();
    bloc = FamilyBloc(familyDao: mockDao, familyGrpcService: mockGrpc);
  });

  tearDown(() => bloc.close());

  group('FamilyBloc', () {
    test('initial state is FamilyInitial', () {
      expect(bloc.state, const FamilyInitial());
    });

    blocTest<FamilyBloc, FamilyState>(
      'emits [Loading, Loaded] on FamilyListRequested',
      build: () {
        when(() => mockDao.listFamilies()).thenAnswer((_) async => []);
        return bloc;
      },
      act: (b) => b.add(const FamilyListRequested()),
      expect: () => [
        const FamilyLoading(),
        const FamilyLoaded(families: []),
      ],
    );

    blocTest<FamilyBloc, FamilyState>(
      'emits [Loading, Loaded] on FamilyDetailRequested with family and members',
      build: () {
        when(() => mockDao.getFamily('fam-1')).thenAnswer(
          (_) async => Family(id: 'fam-1', name: 'Test', ownerId: 'u1', createdAt: '', updatedAt: '', syncStatus: 0),
        );
        when(() => mockDao.listMembers('fam-1')).thenAnswer((_) async => []);
        return bloc;
      },
      act: (b) => b.add(const FamilyDetailRequested('fam-1')),
      expect: () => [
        const FamilyLoading(),
        isA<FamilyDetailLoaded>(),
      ],
    );

    blocTest<FamilyBloc, FamilyState>(
      'emits [Loading, Loaded] on InvitationsRequested',
      build: () {
        when(() => mockDao.listInvitations()).thenAnswer((_) async => []);
        return bloc;
      },
      act: (b) => b.add(const InvitationsRequested()),
      expect: () => [
        const FamilyLoading(),
        const FamilyLoaded(families: []),
      ],
    );
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/families/family_bloc_test.dart`
Expected: FAIL — events and states not defined

- [ ] **Step 3: Add new events to `family_event.dart`**

```dart
final class FamilyListRequested extends FamilyEvent {
  const FamilyListRequested();
}

final class FamilyCreated extends FamilyEvent {
  final String name;
  const FamilyCreated(this.name);
  @override
  List<Object?> get props => [name];
}

final class FamilyDetailRequested extends FamilyEvent {
  final String familyId;
  const FamilyDetailRequested(this.familyId);
  @override
  List<Object?> get props => [familyId];
}

final class InvitationsRequested extends FamilyEvent {
  const InvitationsRequested();
}

final class InvitationAccepted extends FamilyEvent {
  final String code;
  const InvitationAccepted(this.code);
  @override
  List<Object?> get props => [code];
}

final class MemberRemoved extends FamilyEvent {
  final String familyId;
  final String userId;
  const MemberRemoved(this.familyId, this.userId);
  @override
  List<Object?> get props => [familyId, userId];
}

final class FamilyDeleted extends FamilyEvent {
  final String familyId;
  const FamilyDeleted(this.familyId);
  @override
  List<Object?> get props => [familyId];
}

final class FamilyLeft extends FamilyEvent {
  final String familyId;
  const FamilyLeft(this.familyId);
  @override
  List<Object?> get props => [familyId];
}
```

- [ ] **Step 4: Add new state to `family_state.dart`**

```dart
final class FamilyDetailLoaded extends FamilyState {
  final Family family;
  final List<FamilyMember> members;
  const FamilyDetailLoaded({required this.family, required this.members});
  @override
  List<Object?> get props => [family, members];
}
```

- [ ] **Step 5: Rewrite `family_bloc.dart`**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart';
import 'package:findiary/core/database/database.dart';
import 'package:findiary/core/database/daos/family_dao.dart';
import 'package:findiary/core/grpc/family_service.dart';
import 'family_event.dart';
import 'family_state.dart';

class FamilyBloc extends Bloc<FamilyEvent, FamilyState> {
  final FamilyDao _familyDao;
  final FamilyGrpcService _familyGrpcService;

  FamilyBloc({
    required FamilyDao familyDao,
    required FamilyGrpcService familyGrpcService,
  }) : _familyDao = familyDao,
       _familyGrpcService = familyGrpcService,
       super(const FamilyInitial()) {
    on<FamilyListRequested>(_onListRequested);
    on<FamilyCreated>(_onCreated);
    on<FamilyDetailRequested>(_onDetailRequested);
    on<InvitationsRequested>(_onInvitationsRequested);
    on<InvitationAccepted>(_onInvitationAccepted);
    on<MemberRemoved>(_onMemberRemoved);
    on<FamilyDeleted>(_onDeleted);
    on<FamilyLeft>(_onLeft);
  }

  Future<void> _onListRequested(
    FamilyListRequested event,
    Emitter<FamilyState> emit,
  ) async {
    emit(const FamilyLoading());
    try {
      final families = await _familyDao.listFamilies();
      emit(FamilyLoaded(families: families));
    } catch (e) {
      emit(FamilyFailure(e.toString()));
    }
  }

  Future<void> _onCreated(
    FamilyCreated event,
    Emitter<FamilyState> emit,
  ) async {
    emit(const FamilyLoading());
    try {
      final created = await _familyGrpcService.createFamily(event.name);
      final now = DateTime.now().toIso8601String();
      await _familyDao.upsertFamily(FamiliesCompanion(
        id: Value(created.id),
        name: Value(created.name),
        ownerId: Value(created.ownerId),
        createdAt: Value(created.hasCreatedAt()
            ? created.createdAt.toDateTime().toIso8601String()
            : now),
        updatedAt: Value(created.hasUpdatedAt()
            ? created.updatedAt.toDateTime().toIso8601String()
            : now),
      ));
      final families = await _familyDao.listFamilies();
      emit(FamilyLoaded(families: families));
    } catch (e) {
      emit(FamilyFailure(e.toString()));
    }
  }

  Future<void> _onDetailRequested(
    FamilyDetailRequested event,
    Emitter<FamilyState> emit,
  ) async {
    emit(const FamilyLoading());
    try {
      final family = await _familyDao.getFamily(event.familyId);
      final members = await _familyDao.listMembers(event.familyId);
      if (family == null) {
        emit(const FamilyFailure('Family not found'));
      } else {
        emit(FamilyDetailLoaded(family: family, members: members));
      }
    } catch (e) {
      emit(FamilyFailure(e.toString()));
    }
  }

  Future<void> _onInvitationsRequested(
    InvitationsRequested event,
    Emitter<FamilyState> emit,
  ) async {
    emit(const FamilyLoading());
    try {
      final families = await _familyDao.listFamilies();
      // Load invitations from gRPC and cache locally
      try {
        for (final f in families) {
          final remote = await _familyGrpcService.listInvitations(f.id);
          for (final inv in remote) {
            await _familyDao.upsertInvitation(InvitationsCompanion(
              id: Value(inv.id),
              familyId: Value(inv.familyId),
              familyName: Value(f.name),
              email: Value(inv.email),
              code: Value(inv.code),
              status: Value(inv.status),
              createdBy: Value(inv.createdBy),
              createdAt: Value(inv.hasCreatedAt()
                  ? inv.createdAt.toDateTime().toIso8601String()
                  : ''),
              expiresAt: Value(inv.hasExpiresAt()
                  ? inv.expiresAt.toDateTime().toIso8601String()
                  : ''),
            ));
          }
        }
      } catch (_) {
        // Offline — use cached
      }
      emit(FamilyLoaded(families: families));
    } catch (e) {
      emit(FamilyFailure(e.toString()));
    }
  }

  Future<void> _onInvitationAccepted(
    InvitationAccepted event,
    Emitter<FamilyState> emit,
  ) async {
    emit(const FamilyLoading());
    try {
      final member = await _familyGrpcService.acceptInvitation(event.code);
      final now = DateTime.now().toIso8601String();
      await _familyDao.addMember(FamilyMembersCompanion(
        familyId: Value(member.familyId),
        userId: Value(member.userId),
        role: Value(member.role),
        joinedAt: Value(member.hasJoinedAt()
            ? member.joinedAt.toDateTime().toIso8601String()
            : now),
        invitedBy: Value(member.invitedBy),
      ));
      await _familyDao.removeInvitation(event.code); // clean up
      final families = await _familyDao.listFamilies();
      emit(FamilyLoaded(families: families));
    } catch (e) {
      emit(FamilyFailure(e.toString()));
    }
  }

  Future<void> _onMemberRemoved(
    MemberRemoved event,
    Emitter<FamilyState> emit,
  ) async {
    try {
      await _familyGrpcService.removeMember(event.familyId, event.userId);
      await _familyDao.removeMember(event.familyId, event.userId);
      // Refresh detail
      add(FamilyDetailRequested(event.familyId));
    } catch (e) {
      emit(FamilyFailure(e.toString()));
    }
  }

  Future<void> _onDeleted(
    FamilyDeleted event,
    Emitter<FamilyState> emit,
  ) async {
    try {
      // Backend delete via gRPC (updateFamily with deleted flag or dedicated)
      // For MVP, remove locally after confirming backend
      await _familyDao.removeFamily(event.familyId);
      add(const FamilyListRequested());
    } catch (e) {
      emit(FamilyFailure(e.toString()));
    }
  }

  Future<void> _onLeft(
    FamilyLeft event,
    Emitter<FamilyState> emit,
  ) async {
    try {
      await _familyDao.removeMember(event.familyId, 'current-user-id');
      await _familyDao.removeFamily(event.familyId);
      add(const FamilyListRequested());
    } catch (e) {
      emit(FamilyFailure(e.toString()));
    }
  }
}
```

- [ ] **Step 6: Run test to verify it passes**

Run: `flutter test test/features/families/family_bloc_test.dart`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add frontend/lib/features/families/bloc/ \
       frontend/test/features/families/family_bloc_test.dart
git commit -m "feat: add family events, detail state, and bloc handlers"
```

---

### Task 3: FamiliesPage + CreateFamilyDialog

**Files:**
- Create: `frontend/lib/features/families/families_page.dart`
- Test: `frontend/test/features/families/families_page_test.dart`

- [ ] **Step 1: Write the failing test**

Create `frontend/test/features/families/families_page_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findiary/features/families/families_page.dart';
import 'package:findiary/features/families/bloc/family_bloc.dart';
import 'package:findiary/features/families/bloc/family_event.dart';
import 'package:findiary/features/families/bloc/family_state.dart';
import 'package:findiary/core/database/database.dart';

class FamilyBlocMock extends MockBloc<FamilyEvent, FamilyState> implements FamilyBloc {}

void main() {
  late FamilyBlocMock bloc;

  setUp(() {
    bloc = FamilyBlocMock();
  });

  testWidgets('FamiliesPage shows empty state', (tester) async {
    when(() => bloc.state).thenReturn(const FamilyLoaded(families: []));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<FamilyBloc>.value(
          value: bloc,
          child: const FamiliesPage(),
        ),
      ),
    );

    expect(find.text('No families yet'), findsOneWidget);
  });

  testWidgets('FamiliesPage shows family list', (tester) async {
    when(() => bloc.state).thenReturn(FamilyLoaded(families: [
      Family(id: '1', name: 'Test Family', ownerId: 'u1', createdAt: '', updatedAt: '', syncStatus: 0),
    ]));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<FamilyBloc>.value(
          value: bloc,
          child: const FamiliesPage(),
        ),
      ),
    );

    expect(find.text('Test Family'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/families/families_page_test.dart`
Expected: FAIL — `families_page.dart` not found

- [ ] **Step 3: Create `families_page.dart`**

```dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:findiary/core/database/database.dart';
import 'package:findiary/features/families/bloc/family_bloc.dart';
import 'package:findiary/features/families/bloc/family_event.dart';
import 'package:findiary/features/families/bloc/family_state.dart';

class FamiliesPage extends StatefulWidget {
  const FamiliesPage({super.key});

  @override
  State<FamiliesPage> createState() => _FamiliesPageState();
}

class _FamiliesPageState extends State<FamiliesPage> {
  @override
  void initState() {
    super.initState();
    context.read<FamilyBloc>().add(const FamilyListRequested());
  }

  void _showCreateDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Family'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Family name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<FamilyBloc>().add(FamilyCreated(controller.text.trim()));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Families')),
      body: BlocBuilder<FamilyBloc, FamilyState>(
        builder: (context, state) {
          if (state is FamilyLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FamilyLoaded) {
            if (state.families.isEmpty) {
              return const Center(
                child: Text('No families yet'),
              );
            }
            return ListView.builder(
              itemCount: state.families.length,
              itemBuilder: (_, i) => _FamilyTile(family: state.families[i]),
            );
          }
          if (state is FamilyFailure) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FamilyTile extends StatelessWidget {
  final Family family;
  const _FamilyTile({required this.family});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.group)),
      title: Text(family.name),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go('/families/${family.id}'),
    );
  }
}
```
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/families/families_page_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add frontend/lib/features/families/families_page.dart \
       frontend/test/features/families/families_page_test.dart
git commit -m "feat: add FamiliesPage with create family dialog"
```

---

### Task 4: FamilyDetailPage + InviteMemberDialog

**Files:**
- Create: `frontend/lib/features/families/family_detail_page.dart`
- Test: `frontend/test/features/families/family_detail_page_test.dart`

- [ ] **Step 1: Write the failing test**

Create `frontend/test/features/families/family_detail_page_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:findiary/core/database/database.dart';
import 'package:findiary/features/families/family_detail_page.dart';
import 'package:findiary/features/families/bloc/family_bloc.dart';
import 'package:findiary/features/families/bloc/family_event.dart';
import 'package:findiary/features/families/bloc/family_state.dart';

class FamilyBlocMock extends MockBloc<FamilyEvent, FamilyState> implements FamilyBloc {}

void main() {
  late FamilyBlocMock bloc;

  setUp(() {
    bloc = FamilyBlocMock();
  });

  testWidgets('FamilyDetailPage shows family info', (tester) async {
    when(() => bloc.state).thenReturn(FamilyDetailLoaded(
      family: Family(id: '1', name: 'Test Fam', ownerId: 'u1', createdAt: '2026-07-18', updatedAt: '', syncStatus: 0),
      members: [],
    ));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<FamilyBloc>.value(
          value: bloc,
          child: const FamilyDetailPage(familyId: '1'),
        ),
      ),
    );

    expect(find.text('Test Fam'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/families/family_detail_page_test.dart`
Expected: FAIL — `family_detail_page.dart` not found

- [ ] **Step 3: Create `family_detail_page.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findiary/core/database/database.dart';
import 'package:findiary/core/di/injection.dart';
import 'package:findiary/core/grpc/family_service.dart';
import 'package:findiary/features/families/bloc/family_bloc.dart';
import 'package:findiary/features/families/bloc/family_event.dart';
import 'package:findiary/features/families/bloc/family_state.dart';

class FamilyDetailPage extends StatefulWidget {
  final String familyId;
  const FamilyDetailPage({super.key, required this.familyId});

  @override
  State<FamilyDetailPage> createState() => _FamilyDetailPageState();
}

class _FamilyDetailPageState extends State<FamilyDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<FamilyBloc>().add(FamilyDetailRequested(widget.familyId));
  }

  void _showInviteDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Invite Member'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                sl<FamilyGrpcService>().inviteMember(
                  widget.familyId, controller.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invitation sent')),
                );
              }
            },
            child: const Text('Invite'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Family')),
      body: BlocBuilder<FamilyBloc, FamilyState>(
        builder: (context, state) {
          if (state is FamilyLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FamilyDetailLoaded) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(state.family.name, style: theme.textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text('Your role: Owner', style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Members', style: theme.textTheme.titleMedium),
                    FilledButton.tonalIcon(
                      onPressed: _showInviteDialog,
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text('Invite'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (state.members.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No members yet')),
                  )
                else
                  ...state.members.map((m) => ListTile(
                    leading: CircleAvatar(child: Text(m.userId[0].toUpperCase())),
                    title: Text(m.userId),
                    subtitle: Text(m.role),
                  )),
              ],
            );
          }
          if (state is FamilyFailure) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/families/family_detail_page_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add frontend/lib/features/families/family_detail_page.dart \
       frontend/test/features/families/family_detail_page_test.dart
git commit -m "feat: add FamilyDetailPage with invite dialog"
```

---

### Task 5: InvitationsPage

**Files:**
- Create: `frontend/lib/features/families/invitations_page.dart`
- Test: `frontend/test/features/families/invitations_page_test.dart`

- [ ] **Step 1: Write the failing test**

Create `frontend/test/features/families/invitations_page_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:findiary/features/families/invitations_page.dart';
import 'package:findiary/features/families/bloc/family_bloc.dart';
import 'package:findiary/features/families/bloc/family_event.dart';
import 'package:findiary/features/families/bloc/family_state.dart';

class FamilyBlocMock extends MockBloc<FamilyEvent, FamilyState> implements FamilyBloc {}

void main() {
  late FamilyBlocMock bloc;

  setUp(() {
    bloc = FamilyBlocMock();
  });

  testWidgets('InvitationsPage shows empty state', (tester) async {
    when(() => bloc.state).thenReturn(const FamilyLoaded(families: []));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<FamilyBloc>.value(
          value: bloc,
          child: const InvitationsPage(),
        ),
      ),
    );

    expect(find.text('No pending invitations'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/families/invitations_page_test.dart`
Expected: FAIL — `invitations_page.dart` not found

- [ ] **Step 3: Create `invitations_page.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findiary/features/families/bloc/family_bloc.dart';
import 'package:findiary/features/families/bloc/family_event.dart';
import 'package:findiary/features/families/bloc/family_state.dart';

class InvitationsPage extends StatefulWidget {
  const InvitationsPage({super.key});

  @override
  State<InvitationsPage> createState() => _InvitationsPageState();
}

class _InvitationsPageState extends State<InvitationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<FamilyBloc>().add(const InvitationsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invitations')),
      body: BlocBuilder<FamilyBloc, FamilyState>(
        builder: (context, state) {
          if (state is FamilyLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FamilyFailure) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(
            child: Text('No pending invitations'),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/families/invitations_page_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add frontend/lib/features/families/invitations_page.dart \
       frontend/test/features/families/invitations_page_test.dart
git commit -m "feat: add InvitationsPage"
```

---

### Task 6: ScopeCubit

**Files:**
- Create: `frontend/lib/features/families/bloc/scope_cubit.dart`
- Test: `frontend/test/features/families/scope_cubit_test.dart`

- [ ] **Step 1: Write the failing test**

Create `frontend/test/features/families/scope_cubit_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:findiary/features/families/bloc/scope_cubit.dart';

void main() {
  group('ScopeCubit', () {
    test('initial state is personal scope', () {
      final cubit = ScopeCubit();
      expect(cubit.state, const Scope(scopeId: 'personal', scopeType: 'personal', label: 'Personal'));
      cubit.close();
    });

    blocTest<ScopeCubit, Scope>(
      'emits family scope when switchToFamily is called',
      build: () => ScopeCubit(),
      act: (c) => c.switchToFamily('fam-1', 'My Family'),
      expect: () => [const Scope(scopeId: 'fam-1', scopeType: 'family', label: 'My Family')],
    );

    blocTest<ScopeCubit, Scope>(
      'emits personal scope when switchToPersonal is called',
      build: () => ScopeCubit(),
      seed: () => const Scope(scopeId: 'fam-1', scopeType: 'family', label: 'My Family'),
      act: (c) => c.switchToPersonal(),
      expect: () => [const Scope(scopeId: 'personal', scopeType: 'personal', label: 'Personal')],
    );
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/families/scope_cubit_test.dart`
Expected: FAIL — `scope_cubit.dart` not found

- [ ] **Step 3: Create `scope_cubit.dart`**

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Scope extends Equatable {
  final String scopeId;
  final String scopeType;
  final String label;

  const Scope({
    this.scopeId = 'personal',
    this.scopeType = 'personal',
    this.label = 'Personal',
  });

  bool get isPersonal => scopeType == 'personal';

  @override
  List<Object?> get props => [scopeId, scopeType, label];
}

class ScopeCubit extends Cubit<Scope> {
  ScopeCubit() : super(const Scope());

  void switchToPersonal() => emit(const Scope());

  void switchToFamily(String familyId, String familyName) =>
      emit(Scope(scopeId: familyId, scopeType: 'family', label: familyName));
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/families/scope_cubit_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add frontend/lib/features/families/bloc/scope_cubit.dart \
       frontend/test/features/families/scope_cubit_test.dart
git commit -m "feat: add ScopeCubit for personal/family scope switching"
```

---

### Task 7: Wire Scope into DashboardBloc and TransactionListBloc

**Note:** `TransactionDao` already supports `familyId` filtering in `listTransactions()`, `sumTransactions()`, and `countTransactions()` (lines 31-101 of `transaction_dao.dart`). No DAO changes needed.

**Files:**
- Modify: `frontend/lib/features/dashboard/bloc/dashboard_event.dart`
- Modify: `frontend/lib/features/dashboard/bloc/dashboard_bloc.dart`
- Modify: `frontend/lib/features/transactions/bloc/transaction_list_event.dart`
- Modify: `frontend/lib/features/transactions/bloc/transaction_list_bloc.dart`
- Modify: `frontend/lib/features/dashboard/dashboard_page.dart`
- Modify: `frontend/lib/features/transactions/transaction_list_page.dart`
- Modify: `frontend/lib/features/transactions/transaction_form_sheet.dart`

- [ ] **Step 1: Add scope field to `DashboardRequested`**

In `dashboard_event.dart`:

```dart
final class DashboardRequested extends DashboardEvent {
  final String? scopeId;
  final String? scopeType;

  const DashboardRequested({this.scopeId, this.scopeType});

  @override
  List<Object?> get props => [scopeId, scopeType];
}
```

- [ ] **Step 2: Update `DashboardBloc` to filter by scope**

In `dashboard_bloc.dart`, update `_onRequested` to pass scope to DAO methods and gRPC:

```dart
  Future<void> _onRequested(
    DashboardRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    try {
      final income = await _transactionDao.sumTransactions(
        type: 'income', familyId: event.scopeId,
      );
      final expense = await _transactionDao.sumTransactions(
        type: 'expense', familyId: event.scopeId,
      );
      final recent = await _transactionDao.listTransactions(
        limit: 10, familyId: event.scopeId,
      );

      List<MonthlySummary> monthly = [];
      if (!event.scopeId.isPersonal) {
        try {
          final serverData = await _dashboardGrpcService.getDashboard(
            familyId: event.scopeType == 'family' ? event.scopeId : null,
          );
          monthly = serverData.monthly;
        } catch (_) {}
      }

      emit(DashboardLoaded(
        totalIncome: income,
        totalExpense: expense,
        monthlySummaries: monthly,
        recentTransactions: recent,
      ));
    } catch (_) {
      emit(const DashboardLoaded(
        totalIncome: 0,
        totalExpense: 0,
        recentTransactions: [],
      ));
    }
  }
```

- [ ] **Step 3: Update `TransactionListBloc` to accept family filter**

Add `familyId` parameter to `TransactionListRequested`:

In `transaction_list_event.dart`:

```dart
final class TransactionListRequested extends TransactionListEvent {
  final String? familyId;
  const TransactionListRequested({this.familyId});
  @override
  List<Object?> get props => [familyId];
}
```

In `transaction_list_bloc.dart`, update handlers to pass `familyId` to DAO:

```dart
  Future<void> _onRequested(
    TransactionListRequested event,
    Emitter<TransactionListState> emit,
  ) async {
    emit(const TransactionListLoading());
    try {
      final type = state is TransactionListLoaded
          ? (state as TransactionListLoaded).typeFilter : null;
      final transactions = await _transactionDao.listTransactions(
        familyId: event.familyId, type: type,
      );
      emit(TransactionListLoaded(
        transactions: transactions, typeFilter: type,
      ));
    } catch (_) {
      emit(TransactionListLoaded(transactions: [], typeFilter: null));
    }
  }

  Future<void> _onFilterChanged(
    TransactionListFilterChanged event,
    Emitter<TransactionListState> emit,
  ) async {
    emit(const TransactionListLoading());
    try {
      // familyId stored in state from initial request
      final familyId = state is TransactionListLoaded
          ? (state as TransactionListLoaded).familyId : null;
      final transactions = await _transactionDao.listTransactions(
        familyId: familyId, type: event.type,
      );
      emit(TransactionListLoaded(
        transactions: transactions, typeFilter: event.type, familyId: familyId,
      ));
    } catch (_) {
      emit(TransactionListLoaded(
        transactions: [], typeFilter: event.type,
      ));
    }
  }
```

Add `familyId` to `TransactionListLoaded`:

In `transaction_list_state.dart`:

```dart
class TransactionListLoaded extends TransactionListState {
  final List<Transaction> transactions;
  final String? typeFilter;
  final String? familyId;

  const TransactionListLoaded({
    required this.transactions,
    this.typeFilter,
    this.familyId,
  });

  @override
  List<Object?> get props => [transactions, typeFilter, familyId];
}
```

- [ ] **Step 4: Add scope-aware initialization in `DashboardPage`**

Wrap the dashboard body in a listener that re-fetches when scope changes.

In `_DashboardViewState`:

```dart
@override
Widget build(BuildContext context) {
  return BlocListener<ScopeCubit, Scope>(
    listener: (context, scope) {
      context.read<DashboardBloc>().add(DashboardRequested(
        scopeId: scope.scopeId,
        scopeType: scope.scopeType,
      ));
    },
    child: Scaffold(
      appBar: AppBar(
        title: const Text('FinDiary'),
        actions: const [ScopeSwitcher()],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) { /* existing code */ },
      ),
    ),
  );
}
```

- [ ] **Step 5: Update `TransactionListPage` to pass family scope**

When requesting transactions, read the current scope:

```dart
// In _TransactionListViewState:
@override
void initState() {
  super.initState();
  final scope = context.read<ScopeCubit>().state;
  context.read<TransactionListBloc>().add(TransactionListRequested(
    familyId: scope.isPersonal ? null : scope.scopeId,
  ));
}
```

- [ ] **Step 6: Update `TransactionFormSheet` to set `familyId`**

When creating a transaction, read scope:

```dart
// In _save() method of TransactionFormSheet:
final scope = sl<ScopeCubit>().state;
await dao.upsertTransaction(TransactionsCompanion(
  id: Value(id),
  type: Value(_type),
  amount: Value(double.parse(_amountCtrl.text)),
  currency: const Value('INR'),
  categoryId: Value(_categoryId ?? ''),
  date: Value(_date),
  description: Value(_descCtrl.text),
  createdBy: Value(widget.transaction?.createdBy ?? ''),
  createdAt: Value(widget.transaction?.createdAt ?? now),
  updatedAt: Value(now),
  familyId: Value(scope.isPersonal ? null : scope.scopeId),
));
```

- [ ] **Step 7: Commit**

```bash
git add frontend/lib/features/dashboard/ \
       frontend/lib/features/transactions/
git commit -m "feat: wire scope into dashboard and transaction BLoCs"
```

---

### Task 8: Router Updates + Bottom Nav

**Files:**
- Modify: `frontend/lib/app.dart`
- Modify: `frontend/lib/core/di/injection.dart`

- [ ] **Step 1: Add `ScopeCubit` to `MultiBlocProvider` in `app.dart`**

```dart
import 'features/families/bloc/scope_cubit.dart';

// In MultiBlocProvider providers list:
BlocProvider(create: (_) => ScopeCubit()),
```

- [ ] **Step 2: Add routes for families pages**

```dart
import 'features/families/families_page.dart';
import 'features/families/family_detail_page.dart';
import 'features/families/invitations_page.dart';

// In the ShellRoute routes list:
GoRoute(path: '/families', builder: (_, __) => const FamiliesPage()),
GoRoute(path: '/families/:id', builder: (_, state) => FamilyDetailPage(familyId: state.pathParameters['id']!)),
GoRoute(path: '/invitations', builder: (_, __) => const InvitationsPage()),
```

- [ ] **Step 3: Update bottom nav destinations and tab logic**

Update `_Shell`:

```dart
destinations: const [
  NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
  NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Transactions'),
  NavigationDestination(icon: Icon(Icons.category_outlined), selectedIcon: Icon(Icons.category), label: 'Categories'),
  NavigationDestination(icon: Icon(Icons.group_outlined), selectedIcon: Icon(Icons.group), label: 'Families'),
  NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
],
```

Update `_calculateIndex`:

```dart
int _calculateIndex(BuildContext context) {
  final loc = GoRouterState.of(context).matchedLocation;
  if (loc.startsWith('/transactions')) return 1;
  if (loc.startsWith('/categories')) return 2;
  if (loc.startsWith('/families')) return 3;
  if (loc.startsWith('/settings')) return 4;
  return 0;
}
```

Update `_goTab`:

```dart
void _goTab(BuildContext context, int i) {
  switch (i) {
    case 0: context.go('/');
    case 1: context.go('/transactions');
    case 2: context.go('/categories');
    case 3: context.go('/families');
    case 4: context.go('/settings');
  }
}
```

- [ ] **Step 4: Add `FamilyBloc` provider — in the families pages or DI**

In `injection.dart`, `FamilyBloc` is registered via DI so pages can access it. The families pages create their own `BlocProvider` instances that pull from DI:

```dart
// Could also be provided at the app level, but page-level is simpler:
// FamiliesPage creates its own BlocProvider using sl()
```

Actually, simpler: provide `FamilyBloc` at the controller level or have each family page create its own `BlocProvider`. Given the `FamilyBloc` needs `FamilyDao` and `FamilyGrpcService` which are in DI, the cleanest approach is to provide `FamilyBloc` at the app level:

```dart
// In injection.dart, after familyDao registration:
sl.registerLazySingleton<FamilyBloc>(() => FamilyBloc(
  familyDao: sl<FamilyDao>(),
  familyGrpcService: sl<FamilyGrpcService>(),
));
```

And add to `MultiBlocProvider`:
```dart
BlocProvider(create: (_) => sl<FamilyBloc>()),
```

- [ ] **Step 5: Verify analyze passes**

Run: `flutter analyze`
Expected: 0 errors, 0 warnings

- [ ] **Step 6: Commit**

```bash
git add frontend/lib/app.dart \
       frontend/lib/core/di/injection.dart
git commit -m "feat: add families routes, bottom nav tab, and DI wiring"
```

---

### Task 9: Scope Switcher Widget

**Files:**
- Create: `frontend/lib/features/families/widgets/scope_switcher.dart`

- [ ] **Step 1: Add scope switcher to DashboardPage app bar**

Create `scope_switcher.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findiary/core/database/database.dart';
import 'package:findiary/features/families/bloc/scope_cubit.dart';
import 'package:findiary/features/families/bloc/family_bloc.dart';
import 'package:findiary/features/families/bloc/family_state.dart';

class ScopeSwitcher extends StatelessWidget {
  const ScopeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = context.watch<ScopeCubit>().state;
    final familyState = context.watch<FamilyBloc>().state;
    return PopupMenuButton<String>(
      initialValue: scope.scopeId,
      onSelected: (value) {
        if (value == 'personal') {
          context.read<ScopeCubit>().switchToPersonal();
        } else {
          final parts = value.split('|');
          if (parts.length == 2) {
            context.read<ScopeCubit>().switchToFamily(parts[0], parts[1]);
          }
        }
      },
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[
          PopupMenuItem(
            value: 'personal',
            child: Row(
              children: [
                Icon(Icons.person, size: 18,
                  color: scope.isPersonal ? Theme.of(context).colorScheme.primary : null),
                const SizedBox(width: 8),
                Text('Personal'),
                if (scope.isPersonal) const Spacer() else const Spacer(),
                if (scope.isPersonal)
                  Icon(Icons.check, size: 18, color: Theme.of(context).colorScheme.primary),
              ],
            ),
          ),
        ];
        if (familyState is FamilyLoaded && familyState.families.isNotEmpty) {
          items.add(const PopupMenuDivider());
          for (final f in familyState.families) {
            final val = '${f.id}|${f.name}';
            items.add(PopupMenuItem(
              value: val,
              child: Row(
                children: [
                  Icon(Icons.group, size: 18,
                    color: scope.scopeId == f.id ? Theme.of(context).colorScheme.primary : null),
                  const SizedBox(width: 8),
                  Text(f.name),
                  if (scope.scopeId == f.id)
                    Icon(Icons.check, size: 18, color: Theme.of(context).colorScheme.primary),
                ],
              ),
            ));
          }
        }
        return items;
      },
      child: Chip(
        avatar: Icon(scope.isPersonal ? Icons.person : Icons.group, size: 18),
        label: Text(scope.label),
      ),
    );
  }
}
```

- [ ] **Step 2: Integrate scope switcher into `DashboardPage`**

Replace `AppBar(title: const Text('FinDiary'))` with:

```dart
AppBar(
  title: const Text('FinDiary'),
  actions: [const ScopeSwitcher()],
),
```

The `BlocListener` for scope changes is already handled in Task 7 Step 4.

- [ ] **Step 3: Commit**

```bash
git add frontend/lib/features/families/widgets/scope_switcher.dart \
       frontend/lib/features/dashboard/dashboard_page.dart
git commit -m "feat: add scope switcher dropdown in dashboard app bar"
```

---

### Task 10: Integration Tests

**Files:**
- Create: `frontend/test/features/families/scope_switcher_test.dart`
- Modify: `frontend/test/features/dashboard/dashboard_bloc_test.dart`
- Modify: `frontend/test/features/transactions/transaction_list_bloc_test.dart`

- [ ] **Step 1: Write scope switcher test**

Create `frontend/test/features/families/scope_switcher_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:findiary/core/database/database.dart';
import 'package:findiary/features/families/bloc/scope_cubit.dart';
import 'package:findiary/features/families/bloc/family_bloc.dart';
import 'package:findiary/features/families/bloc/family_event.dart';
import 'package:findiary/features/families/bloc/family_state.dart';
import 'package:findiary/features/families/widgets/scope_switcher.dart';

class MockFamilyBloc extends MockBloc<FamilyEvent, FamilyState> implements FamilyBloc {}

void main() {
  late ScopeCubit scopeCubit;
  late MockFamilyBloc mockFamilyBloc;

  setUp(() {
    scopeCubit = ScopeCubit();
    mockFamilyBloc = MockFamilyBloc();
  });

  tearDown(() => scopeCubit.close());

  testWidgets('ScopeSwitcher shows personal by default', (tester) async {
    when(() => mockFamilyBloc.state).thenReturn(const FamilyLoaded(families: []));

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: scopeCubit),
            BlocProvider.value(value: mockFamilyBloc),
          ],
          child: const Scaffold(body: ScopeSwitcher()),
        ),
      ),
    );

    expect(find.text('Personal'), findsOneWidget);
  });

  testWidgets('ScopeSwitcher shows family names', (tester) async {
    when(() => mockFamilyBloc.state).thenReturn(FamilyLoaded(families: [
      Family(id: 'f1', name: 'Test Fam', ownerId: 'u1', createdAt: '', updatedAt: '', syncStatus: 0),
    ]));

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: scopeCubit),
            BlocProvider.value(value: mockFamilyBloc),
          ],
          child: const Scaffold(body: ScopeSwitcher()),
        ),
      ),
    );

    // Tap to open popup
    await tester.tap(find.text('Personal'));
    await tester.pumpAndSettle();

    expect(find.text('Test Fam'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Update dashboard bloc test for scope filtering**

Update `test/features/dashboard/dashboard_bloc_test.dart`. Add a test case that passes `scopeId` and verifies the DAO is called with it. Read the existing file first to match the test pattern, then add:

```dart
    blocTest<DashboardBloc, DashboardState>(
      'requests dashboard with family scope',
      build: () {
        when(() => mockDao.sumTransactions(type: 'income', familyId: 'fam-1'))
            .thenAnswer((_) async => 1000);
        when(() => mockDao.sumTransactions(type: 'expense', familyId: 'fam-1'))
            .thenAnswer((_) async => 500);
        when(() => mockDao.listTransactions(limit: 10, familyId: 'fam-1'))
            .thenAnswer((_) async => []);
        return bloc;
      },
      act: (b) => b.add(const DashboardRequested(scopeId: 'fam-1', scopeType: 'family')),
      expect: () => [
        const DashboardLoading(),
        isA<DashboardLoaded>(),
      ],
      verify: (_) {
        verify(() => mockDao.sumTransactions(type: 'income', familyId: 'fam-1')).called(1);
        verify(() => mockDao.sumTransactions(type: 'expense', familyId: 'fam-1')).called(1);
      },
    );
```

- [ ] **Step 3: Update transaction list bloc test for scope filtering**

Update `test/features/transactions/transaction_list_bloc_test.dart`. Read the existing file, then add a test:

```dart
    blocTest<TransactionListBloc, TransactionListState>(
      'requests transactions with family scope',
      build: () {
        when(() => mockDao.listTransactions(familyId: 'fam-1'))
            .thenAnswer((_) async => []);
        return bloc;
      },
      act: (b) => b.add(const TransactionListRequested(familyId: 'fam-1')),
      expect: () => [
        const TransactionListLoading(),
        isA<TransactionListLoaded>(),
      ],
    );
```

- [ ] **Step 4: Run all tests**

Run: `flutter test`
Expected: All tests pass

- [ ] **Step 5: Commit**

```bash
git add frontend/test/
git commit -m "test: add scope switching and integration tests"
```
