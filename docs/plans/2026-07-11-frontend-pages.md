# Frontend Pages Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Flutter UI for FinDiary — dashboard, transaction list + form, categories, settings — with bottom navigation and theming.

**Architecture:** Bloc-per-feature reads/writes directly to Drift DAOs. Mutations trigger sync via Phase 3b hooks. ThemeCubit persists selected theme. go_router with StatefulShellRoute for bottom nav.

**Tech Stack:** Flutter, flutter_bloc, go_router, drift, shared_preferences, mocktail, bloc_test

---

### Task 1: Dependencies + Theming System

**Files:**
- Modify: `frontend/pubspec.yaml`
- Create: `frontend/lib/core/theme/app_theme.dart`
- Create: `frontend/lib/core/theme/themes/clean_modern.dart`
- Create: `frontend/lib/core/theme/themes/dark_finance.dart`
- Create: `frontend/lib/core/theme/themes/warm_minimal.dart`

- [ ] **Step 1: Add shared_preferences to pubspec.yaml**

Add `shared_preferences: ^2.3.0` under `dependencies` in `frontend/pubspec.yaml`.

- [ ] **Step 2: Run flutter pub get**

Run: `flutter pub get` in `frontend/`
Expected: Success with no errors.

- [ ] **Step 3: Create clean_modern theme**

Create `frontend/lib/core/theme/themes/clean_modern.dart`:

```dart
import 'package:flutter/material.dart';

ThemeData cleanModernTheme() {
  const primary = Color(0xFF6C63FF);
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: primary,
    brightness: Brightness.light,
    cardTheme: const CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );
}
```

- [ ] **Step 4: Create dark_finance theme**

Create `frontend/lib/core/theme/themes/dark_finance.dart`:

```dart
import 'package:flutter/material.dart';

ThemeData darkFinanceTheme() {
  const primary = Color(0xFF7CFFB2);
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: primary,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1a1a2e),
    cardTheme: const CardThemeData(
      color: Color(0xFF16213e),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF16213e),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );
}
```

- [ ] **Step 5: Create warm_minimal theme**

Create `frontend/lib/core/theme/themes/warm_minimal.dart`:

```dart
import 'package:flutter/material.dart';

ThemeData warmMinimalTheme() {
  const primary = Color(0xFFFF6B6B);
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: primary,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFFffaf0),
    cardTheme: const CardThemeData(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );
}
```

- [ ] **Step 6: Create ThemeCubit in app_theme.dart**

Create `frontend/lib/core/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'themes/clean_modern.dart';
import 'themes/dark_finance.dart';
import 'themes/warm_minimal.dart';

enum AppTheme { cleanModern, darkFinance, warmMinimal }

class ThemeCubit extends Cubit<ThemeData> {
  static const _key = 'app_theme';
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(_loadTheme(_prefs.getString(_key)));

  static ThemeData _loadTheme(String? name) {
    switch (name) {
      case 'dark_finance':
        return darkFinanceTheme();
      case 'warm_minimal':
        return warmMinimalTheme();
      default:
        return cleanModernTheme();
    }
  }

  void setTheme(AppTheme theme) {
    final name = theme.name.replaceAllMapped(
      RegExp(r'[A-Z]'), (m) => '_${m.group(0)!.toLowerCase()}');
    _prefs.setString(_key, name);
    emit(_loadTheme(name));
  }
}
```

- [ ] **Step 7: Commit**

```bash
git add frontend/pubspec.yaml frontend/lib/core/theme/
git commit -m "feat: add theming system with 3 themes"
```

---

### Task 2: App Shell + go_router

**Files:**
- Modify: `frontend/lib/app.dart`
- Modify: `frontend/lib/core/di/injection.dart`
- Delete: `frontend/lib/features/home/dashboard_page.dart` (will be replaced)

- [ ] **Step 1: Install go_router**

Already present in pubspec.yaml (`go_router: ^14.8.0`). No changes needed.

- [ ] **Step 2: Create the scaffold pages directory structure**

No files to create yet — pages will be created in Tasks 3-7. This task sets up the router and bottom nav shell.

- [ ] **Step 3: Rewrite app.dart with go_router and bottom nav**

Replace `frontend/lib/app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/di/injection.dart';
import 'core/auth/auth_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/login_page.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/transactions/transaction_list_page.dart';
import 'features/categories/categories_page.dart';
import 'features/settings/settings_page.dart';

class FinDiaryApp extends StatelessWidget {
  const FinDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(authService: sl<AuthService>())),
        BlocProvider(create: (_) => sl<ThemeCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeData>(
        builder: (context, theme) => MaterialApp.router(
          title: 'FinDiary',
          debugShowCheckedModeBanner: false,
          theme: theme,
          routerConfig: _router,
        ),
      ),
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final auth = context.read<AuthBloc>().state;
    final loggedIn = auth.status == AuthStatus.authenticated;
    final onLogin = state.matchedLocation == '/login';
    if (!loggedIn && !onLogin) return '/login';
    if (loggedIn && onLogin) return '/';
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginPage(),
    ),
    ShellRoute(
      builder: (_, __, child) => _Shell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const DashboardPage()),
        GoRoute(path: '/transactions', builder: (_, __) => const TransactionListPage()),
        GoRoute(path: '/categories', builder: (_, __) => const CategoriesPage()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
      ],
    ),
  ],
);

class _Shell extends StatelessWidget {
  final Widget child;
  const _Shell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateIndex(context),
        onDestinationSelected: (i) => _goTab(context, i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Transactions'),
          NavigationDestination(icon: Icon(Icons.category_outlined), selectedIcon: Icon(Icons.category), label: 'Categories'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  int _calculateIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/transactions')) return 1;
    if (loc.startsWith('/categories')) return 2;
    if (loc.startsWith('/settings')) return 3;
    return 0;
  }

  void _goTab(BuildContext context, int i) {
    switch (i) {
      case 0: context.go('/');
      case 1: context.go('/transactions');
      case 2: context.go('/categories');
      case 3: context.go('/settings');
    }
  }
}
```

- [ ] **Step 4: Add dependencies to injection.dart**

Add `SharedPreferences` and `ThemeCubit` to `frontend/lib/core/di/injection.dart`:

```dart
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

// Add inside initDependencies():
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit(prefs));
```

- [ ] **Step 5: Run flutter analyze**

Run: `dart run build_runner build` then `flutter analyze`
Expected: No errors (will have some "unused import" warnings for pages not yet created — that's fine)

- [ ] **Step 6: Commit**

```bash
git add frontend/lib/app.dart frontend/lib/core/di/injection.dart
git commit -m "feat: add go_router with bottom navigation shell"
```

---

### Task 3: Dashboard Feature

**Files:**
- Create: `frontend/lib/features/dashboard/dashboard_page.dart`
- Create: `frontend/lib/features/dashboard/bloc/dashboard_bloc.dart`
- Create: `frontend/lib/features/dashboard/bloc/dashboard_event.dart`
- Create: `frontend/lib/features/dashboard/bloc/dashboard_state.dart`
- Test: `frontend/test/features/dashboard/dashboard_bloc_test.dart`

- [ ] **Step 1: Write the failing test**

Create `frontend/test/features/dashboard/dashboard_bloc_test.dart`:

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:findiary/core/database/daos/transaction_dao.dart';
import 'package:findiary/features/dashboard/bloc/dashboard_bloc.dart';

class MockTransactionDao extends Mock implements TransactionDao {}

void main() {
  late MockTransactionDao mockDao;

  setUp(() {
    mockDao = MockTransactionDao();
  });

  group('DashboardBloc', () {
    blocTest<DashboardBloc, DashboardState>(
      'emits [loading, loaded] when data is fetched',
      setUp: () {
        when(() => mockDao.countTransactions(type: 'income'))
            .thenAnswer((_) async => 2);
        when(() => mockDao.countTransactions(type: 'expense'))
            .thenAnswer((_) async => 1);
        when(() => mockDao.listTransactions(limit: 10, offset: 0))
            .thenAnswer((_) async => []);
      },
      build: () => DashboardBloc(transactionDao: mockDao),
      act: (bloc) => bloc.add(const DashboardRequested()),
      expect: () => [
        isA<DashboardLoading>(),
        isA<DashboardLoaded>(),
      ],
      verify: (bloc) {
        verify(() => mockDao.countTransactions(type: 'income')).called(1);
        verify(() => mockDao.countTransactions(type: 'expense')).called(1);
        verify(() => mockDao.listTransactions(limit: 10, offset: 0)).called(1);
      },
    );
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/dashboard/dashboard_bloc_test.dart`
Expected: Compile errors — DashboardBloc, DashboardState, etc. not defined.

- [ ] **Step 3: Create dashboard state**

Create `frontend/lib/features/dashboard/bloc/dashboard_state.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:findiary/core/database/database.dart';

sealed class DashboardState extends Equatable {
  const DashboardState();
  @override List<Object?> get props => [];
}

final class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

final class DashboardLoaded extends DashboardState {
  final double totalIncome;
  final double totalExpense;
  final List<Transaction> recentTransactions;
  const DashboardLoaded({
    required this.totalIncome,
    required this.totalExpense,
    required this.recentTransactions,
  });
  double get balance => totalIncome - totalExpense;
  @override List<Object?> get props => [totalIncome, totalExpense, recentTransactions];
}
```

- [ ] **Step 4: Create dashboard event**

Create `frontend/lib/features/dashboard/bloc/dashboard_event.dart`:

```dart
import 'package:equatable/equatable.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override List<Object?> get props => [];
}

final class DashboardRequested extends DashboardEvent {
  const DashboardRequested();
}
```

- [ ] **Step 5: Create dashboard bloc**

Create `frontend/lib/features/dashboard/bloc/dashboard_bloc.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findiary/core/database/daos/transaction_dao.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final TransactionDao _transactionDao;

  DashboardBloc({required TransactionDao transactionDao})
      : _transactionDao = transactionDao,
        super(const DashboardInitial()) {
    on<DashboardRequested>(_onRequested);
  }

  Future<void> _onRequested(
    DashboardRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    try {
      final income = await _transactionDao.countTransactions(type: 'income');
      final expense = await _transactionDao.countTransactions(type: 'expense');
      final recent = await _transactionDao.listTransactions(limit: 10);
      emit(DashboardLoaded(
        totalIncome: income.toDouble(),
        totalExpense: expense.toDouble(),
        recentTransactions: recent,
      ));
    } catch (_) {
      emit(const DashboardLoaded(
        totalIncome: 0, totalExpense: 0, recentTransactions: []));
    }
  }
}
```

- [ ] **Step 6: Create dashboard page**

Create `frontend/lib/features/dashboard/dashboard_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'bloc/dashboard_bloc.dart';
import 'bloc/dashboard_event.dart';
import 'bloc/dashboard_state.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardBloc(transactionDao: sl<TransactionDao>()),
      child: _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const DashboardRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('FinDiary')),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DashboardLoaded) {
            final fmt = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(const DashboardRequested());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Balance',
                              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                          const SizedBox(height: 4),
                          Text(fmt.format(state.balance),
                              style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _SummaryChip(label: 'Income', amount: state.totalIncome, color: Colors.green, fmt: fmt),
                              const SizedBox(width: 12),
                              _SummaryChip(label: 'Expense', amount: state.totalExpense, color: Colors.red, fmt: fmt),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Recent Transactions', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (state.recentTransactions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('No transactions yet')),
                    )
                  else
                    ...state.recentTransactions.map((t) => _TransactionRow(transaction: t, fmt: fmt)),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final NumberFormat fmt;
  const _SummaryChip({required this.label, required this.amount, required this.color, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: color, fontSize: 12)),
            const SizedBox(height: 4),
            Text(fmt.format(amount), style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final Transaction transaction;
  final NumberFormat fmt;
  const _TransactionRow({required this.transaction, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isIncome ? Colors.green.withAlpha(25) : Colors.red.withAlpha(25),
        child: Icon(isIncome ? Icons.trending_up : Icons.trending_down, color: isIncome ? Colors.green : Colors.red, size: 20),
      ),
      title: Text(transaction.description ?? transaction.categoryId),
      subtitle: Text(transaction.date),
      trailing: Text(
        '${isIncome ? '+' : '-'}${fmt.format(transaction.amount)}',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isIncome ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
```

- [ ] **Step 7: Run test to verify it passes**

Run: `flutter test test/features/dashboard/dashboard_bloc_test.dart`
Expected: PASS

- [ ] **Step 8: Commit**

```bash
git add frontend/lib/features/dashboard/ frontend/test/features/dashboard/
git commit -m "feat: add dashboard page with balance and recent transactions"
```

---

### Task 4: Transaction List Feature

**Files:**
- Create: `frontend/lib/features/transactions/transaction_list_page.dart`
- Create: `frontend/lib/features/transactions/bloc/transaction_list_bloc.dart`
- Create: `frontend/lib/features/transactions/bloc/transaction_list_event.dart`
- Create: `frontend/lib/features/transactions/bloc/transaction_list_state.dart`
- Create: `frontend/lib/features/transactions/widgets/transaction_tile.dart`
- Test: `frontend/test/features/transactions/transaction_list_bloc_test.dart`

- [ ] **Step 1: Write the failing test**

Create `frontend/test/features/transactions/transaction_list_bloc_test.dart`:

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:findiary/core/database/daos/transaction_dao.dart';
import 'package:findiary/core/sync/sync_engine.dart';

class MockTransactionDao extends Mock implements TransactionDao {}
class MockSyncEngine extends Mock implements SyncEngine {}

void main() {
  late MockTransactionDao mockDao;
  late MockSyncEngine mockEngine;

  setUp(() {
    mockDao = MockTransactionDao();
    mockEngine = MockSyncEngine();
  });

  group('TransactionListBloc', () {
    blocTest<TransactionListBloc, TransactionListState>(
      'emits [loading, loaded] with transactions',
      setUp: () {
        when(() => mockDao.listTransactions(
          type: any(named: 'type'), limit: any(named: 'limit'), offset: any(named: 'offset'),
        )).thenAnswer((_) async => []);
      },
      build: () => TransactionListBloc(transactionDao: mockDao, syncEngine: mockEngine),
      act: (bloc) => bloc.add(TransactionListRequested()),
      expect: () => [
        isA<TransactionListLoading>(),
        isA<TransactionListLoaded>(),
      ],
    );
  });
}
```

- [ ] **Step 2: Create state, event, bloc, page, tile files**

Create `frontend/lib/features/transactions/bloc/transaction_list_state.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:findiary/core/database/database.dart';

sealed class TransactionListState extends Equatable {
  const TransactionListState();
  @override List<Object?> get props => [];
}

final class TransactionListInitial extends TransactionListState {
  const TransactionListInitial();
}

final class TransactionListLoading extends TransactionListState {
  const TransactionListLoading();
}

final class TransactionListLoaded extends TransactionListState {
  final List<Transaction> transactions;
  final String? typeFilter;
  const TransactionListLoaded({required this.transactions, this.typeFilter});
  @override List<Object?> get props => [transactions, typeFilter];
}
```

Create `frontend/lib/features/transactions/bloc/transaction_list_event.dart`:

```dart
import 'package:equatable/equatable.dart';

sealed class TransactionListEvent extends Equatable {
  const TransactionListEvent();
  @override List<Object?> get props => [];
}

final class TransactionListRequested extends TransactionListEvent {
  const TransactionListRequested();
}

final class TransactionListFilterChanged extends TransactionListEvent {
  final String? type;
  const TransactionListFilterChanged(this.type);
  @override List<Object?> get props => [type];
}
```

Create `frontend/lib/features/transactions/bloc/transaction_list_bloc.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findiary/core/database/daos/transaction_dao.dart';
import 'package:findiary/core/sync/sync_engine.dart';
import 'transaction_list_event.dart';
import 'transaction_list_state.dart';

class TransactionListBloc extends Bloc<TransactionListEvent, TransactionListState> {
  final TransactionDao _transactionDao;
  final SyncEngine _syncEngine;

  TransactionListBloc({
    required TransactionDao transactionDao,
    required SyncEngine syncEngine,
  }) : _transactionDao = transactionDao,
       _syncEngine = syncEngine,
       super(const TransactionListInitial()) {
    on<TransactionListRequested>(_onRequested);
    on<TransactionListFilterChanged>(_onFilterChanged);
  }

  Future<void> _onRequested(
    TransactionListRequested event,
    Emitter<TransactionListState> emit,
  ) async {
    emit(const TransactionListLoading());
    try {
      final type = state is TransactionListLoaded ? (state as TransactionListLoaded).typeFilter : null;
      final transactions = await _transactionDao.listTransactions(type: type);
      emit(TransactionListLoaded(transactions: transactions, typeFilter: type));
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
      final transactions = await _transactionDao.listTransactions(type: event.type);
      emit(TransactionListLoaded(transactions: transactions, typeFilter: event.type));
    } catch (_) {
      emit(TransactionListLoaded(transactions: [], typeFilter: event.type));
    }
  }
}
```

Create `frontend/lib/features/transactions/widgets/transaction_tile.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:findiary/core/database/database.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  const TransactionTile({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final fmt = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isIncome ? Colors.green.withAlpha(25) : Colors.red.withAlpha(25),
        child: Icon(isIncome ? Icons.trending_up : Icons.trending_down, color: isIncome ? Colors.green : Colors.red, size: 20),
      ),
      title: Text(transaction.description ?? transaction.categoryId, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(transaction.date, style: Theme.of(context).textTheme.bodySmall),
      trailing: Text(
        '${isIncome ? '+' : '-'}${fmt.format(transaction.amount)}',
        style: TextStyle(fontWeight: FontWeight.w600, color: isIncome ? Colors.green : Colors.red),
      ),
      onTap: onTap,
    );
  }
}
```

Create `frontend/lib/features/transactions/transaction_list_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findiary/core/di/injection.dart';
import 'package:findiary/core/database/daos/transaction_dao.dart';
import 'package:findiary/core/sync/sync_engine.dart';
import 'bloc/transaction_list_bloc.dart';
import 'bloc/transaction_list_event.dart';
import 'bloc/transaction_list_state.dart';
import 'widgets/transaction_tile.dart';
import 'transaction_form_sheet.dart';

class TransactionListPage extends StatelessWidget {
  const TransactionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TransactionListBloc(
        transactionDao: sl<TransactionDao>(),
        syncEngine: sl<SyncEngine>(),
      ),
      child: const _TransactionListView(),
    );
  }
}

class _TransactionListView extends StatefulWidget {
  const _TransactionListView();

  @override
  State<_TransactionListView> createState() => _TransactionListViewState();
}

class _TransactionListViewState extends State<_TransactionListView> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionListBloc>().add(const TransactionListRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: BlocBuilder<TransactionListBloc, TransactionListState>(
        builder: (context, state) {
          if (state is TransactionListLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TransactionListLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<TransactionListBloc>().add(const TransactionListRequested());
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: SegmentedButton<String?>(
                        segments: const [
                          ButtonSegment(value: null, label: Text('All')),
                          ButtonSegment(value: 'income', label: Text('Income')),
                          ButtonSegment(value: 'expense', label: Text('Expense')),
                        ],
                        selected: {state.typeFilter},
                        onSelectionChanged: (v) {
                          context.read<TransactionListBloc>().add(TransactionListFilterChanged(v.first));
                        },
                      ),
                    ),
                  ),
                  if (state.transactions.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: Text('No transactions yet')),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => TransactionTile(
                          transaction: state.transactions[i],
                          onTap: () => TransactionFormSheet.show(context, transaction: state.transactions[i]),
                        ),
                        childCount: state.transactions.length,
                      ),
                    ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => TransactionFormSheet.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

- [ ] **Step 3: Run tests**

Run: `flutter test test/features/transactions/transaction_list_bloc_test.dart`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add frontend/lib/features/transactions/ frontend/test/features/transactions/
git commit -m "feat: add transaction list page with filter"
```

---

### Task 5: Transaction Form

**Files:**
- Create: `frontend/lib/features/transactions/transaction_form_sheet.dart`
- Test: `frontend/test/features/transactions/transaction_form_test.dart`

- [ ] **Step 1: Write the failing test**

Create `frontend/test/features/transactions/transaction_form_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:findiary/core/database/daos/transaction_dao.dart';
import 'package:findiary/core/database/daos/category_dao.dart';
import 'package:findiary/core/database/database.dart';

class MockTransactionDao extends Mock implements TransactionDao {}
class MockCategoryDao extends Mock implements CategoryDao {}

void main() {
  testWidgets('TransactionFormSheet renders fields', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => TransactionFormSheet.show(ctx),
            child: const Text('Open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Income'), findsWidgets);
    expect(find.text('Expense'), findsWidgets);
  });
}
```

- [ ] **Step 2: Create transaction_form_sheet.dart**

Create `frontend/lib/features/transactions/transaction_form_sheet.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:findiary/core/database/database.dart';
import 'package:findiary/core/database/daos/transaction_dao.dart';
import 'package:findiary/core/database/daos/category_dao.dart';
import 'package:findiary/core/di/injection.dart';

class TransactionFormSheet extends StatefulWidget {
  final Transaction? transaction;
  const TransactionFormSheet({super.key, this.transaction});

  static void show(BuildContext context, {Transaction? transaction}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => TransactionFormSheet(transaction: transaction),
    );
  }

  @override
  State<TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends State<TransactionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late TextEditingController _amountCtrl;
  late TextEditingController _descCtrl;
  late String _date;
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    _type = widget.transaction?.type ?? 'income';
    _amountCtrl = TextEditingController(
      text: widget.transaction != null ? widget.transaction!.amount.toString() : '');
    _descCtrl = TextEditingController(text: widget.transaction?.description ?? '');
    _date = widget.transaction?.date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    _categoryId = widget.transaction?.categoryId;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final dao = sl<TransactionDao>();
    final now = DateTime.now().toIso8601String();
    final id = widget.transaction?.id ?? const Uuid().v4();
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
    ));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withAlpha(60),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(widget.transaction == null ? 'Add Transaction' : 'Edit Transaction',
                style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'income', label: Text('Income')),
                ButtonSegment(value: 'expense', label: Text('Expense')),
              ],
              selected: {_type},
              onSelectionChanged: (v) => setState(() => _type = v.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹ '),
              keyboardType: TextInputType.number,
              validator: (v) => v != null && double.tryParse(v) != null && double.parse(v) > 0 ? null : 'Enter a valid amount',
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Date'),
              controller: TextEditingController(text: _date),
              readOnly: true,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.parse(_date),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => _date = DateFormat('yyyy-MM-dd').format(picked));
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description (optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _save, child: Text(widget.transaction == null ? 'Add' : 'Save')),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Run test to verify it passes**

Run: `flutter test test/features/transactions/transaction_form_test.dart`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add frontend/lib/features/transactions/transaction_form_sheet.dart frontend/test/features/transactions/transaction_form_test.dart
git commit -m "feat: add transaction form bottom sheet"
```

---

### Task 6: Categories Feature

**Files:**
- Create: `frontend/lib/features/categories/categories_page.dart`
- Create: `frontend/lib/features/categories/bloc/category_bloc.dart`
- Create: `frontend/lib/features/categories/bloc/category_event.dart`
- Create: `frontend/lib/features/categories/bloc/category_state.dart`
- Test: `frontend/test/features/categories/category_bloc_test.dart`

- [ ] **Step 1: Write the failing test**

Create `frontend/test/features/categories/category_bloc_test.dart`:

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:findiary/core/database/daos/category_dao.dart';

class MockCategoryDao extends Mock implements CategoryDao {}

void main() {
  late MockCategoryDao mockDao;

  setUp(() {
    mockDao = MockCategoryDao();
  });

  group('CategoryBloc', () {
    blocTest<CategoryBloc, CategoryState>(
      'emits [loading, loaded] with categories grouped by type',
      setUp: () {
        when(() => mockDao.listCategories()).thenAnswer((_) async => []);
      },
      build: () => CategoryBloc(categoryDao: mockDao),
      act: (bloc) => bloc.add(const CategoryRequested()),
      expect: () => [
        isA<CategoryLoading>(),
        isA<CategoryLoaded>(),
      ],
    );
  });
}
```

- [ ] **Step 2: Create state, event, bloc, page**

Create `frontend/lib/features/categories/bloc/category_state.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:findiary/core/database/database.dart';

sealed class CategoryState extends Equatable {
  const CategoryState();
  @override List<Object?> get props => [];
}

final class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

final class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

final class CategoryLoaded extends CategoryState {
  final List<Category> incomeCategories;
  final List<Category> expenseCategories;
  const CategoryLoaded({required this.incomeCategories, required this.expenseCategories});
  @override List<Object?> get props => [incomeCategories, expenseCategories];
}
```

Create `frontend/lib/features/categories/bloc/category_event.dart`:

```dart
import 'package:equatable/equatable.dart';

sealed class CategoryEvent extends Equatable {
  const CategoryEvent();
  @override List<Object?> get props => [];
}

final class CategoryRequested extends CategoryEvent {
  const CategoryRequested();
}
```

Create `frontend/lib/features/categories/bloc/category_bloc.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findiary/core/database/daos/category_dao.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryDao _categoryDao;

  CategoryBloc({required CategoryDao categoryDao})
      : _categoryDao = categoryDao,
        super(const CategoryInitial()) {
    on<CategoryRequested>(_onRequested);
  }

  Future<void> _onRequested(
    CategoryRequested event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    try {
      final all = await _categoryDao.listCategories();
      emit(CategoryLoaded(
        incomeCategories: all.where((c) => c.type == 'income').toList(),
        expenseCategories: all.where((c) => c.type == 'expense').toList(),
      ));
    } catch (_) {
      emit(const CategoryLoaded(incomeCategories: [], expenseCategories: []));
    }
  }
}
```

Create `frontend/lib/features/categories/categories_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findiary/core/database/daos/category_dao.dart';
import 'package:findiary/core/di/injection.dart';
import 'bloc/category_bloc.dart';
import 'bloc/category_event.dart';
import 'bloc/category_state.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoryBloc(categoryDao: sl<CategoryDao>()),
      child: const _CategoriesView(),
    );
  }
}

class _CategoriesView extends StatefulWidget {
  const _CategoriesView();

  @override
  State<_CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<_CategoriesView> {
  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(const CategoryRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) return const Center(child: CircularProgressIndicator());
          if (state is CategoryLoaded) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _CategorySection(title: 'Income', categories: state.incomeCategories),
                const SizedBox(height: 24),
                _CategorySection(title: 'Expense', categories: state.expenseCategories),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String title;
  final List<Category> categories;
  const _CategorySection({required this.title, required this.categories});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((c) => Chip(
            avatar: CircleAvatar(
              backgroundColor: c.color != null ? Color(int.parse(c.color!.replaceFirst('#', '0xFF'))) : null,
              child: Icon(_iconFor(c.icon), size: 18),
            ),
            label: Text(c.name),
          )).toList(),
        ),
      ],
    );
  }

  IconData _iconFor(String? icon) {
    switch (icon) {
      case 'food': return Icons.restaurant;
      case 'transport': return Icons.directions_car;
      case 'shopping': return Icons.shopping_bag;
      case 'health': return Icons.local_hospital;
      case 'entertainment': return Icons.movie;
      case 'education': return Icons.school;
      case 'salary': return Icons.work;
      case 'freelance': return Icons.laptop;
      case 'business': return Icons.store;
      case 'investment': return Icons.trending_up;
      case 'gift': return Icons.card_giftcard;
      case 'utilities': return Icons.bolt;
      case 'rent': return Icons.home;
      case 'insurance': return Icons.shield;
      case 'subscription': return Icons.subscriptions;
      default: return Icons.category;
    }
  }
}
```

- [ ] **Step 3: Run tests**

Run: `flutter test test/features/categories/category_bloc_test.dart`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add frontend/lib/features/categories/ frontend/test/features/categories/
git commit -m "feat: add categories page"
```

---

### Task 7: Settings Feature

**Files:**
- Create: `frontend/lib/features/settings/settings_page.dart`
- Create: `frontend/lib/features/settings/bloc/settings_bloc.dart`
- Create: `frontend/lib/features/settings/bloc/settings_event.dart`
- Create: `frontend/lib/features/settings/bloc/settings_state.dart`
- Test: `frontend/test/features/settings/settings_bloc_test.dart`

- [ ] **Step 1: Write the failing test**

Create `frontend/test/features/settings/settings_bloc_test.dart`:

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:findiary/core/theme/app_theme.dart';
import 'package:findiary/core/auth/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService mockAuth;
  late SharedPreferences prefs;

  setUp(() {
    mockAuth = MockAuthService();
    SharedPreferences.setMockInitialValues({});
    prefs = SharedPreferences();
  });

  group('SettingsBloc', () {
    blocTest<SettingsBloc, SettingsState>(
      'emits loaded with current theme',
      build: () => SettingsBloc(authService: mockAuth, themeCubit: ThemeCubit(prefs), prefs: prefs),
      act: (bloc) => bloc.add(const SettingsRequested()),
      expect: () => [isA<SettingsLoaded>()],
    );
  });
}
```

- [ ] **Step 2: Create state, event, bloc, page**

Create `frontend/lib/features/settings/bloc/settings_state.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:findiary/core/theme/app_theme.dart';

sealed class SettingsState extends Equatable {
  const SettingsState();
  @override List<Object?> get props => [];
}

final class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

final class SettingsLoaded extends SettingsState {
  final AppTheme currentTheme;
  const SettingsLoaded({required this.currentTheme});
  @override List<Object?> get props => [currentTheme];
}
```

Create `frontend/lib/features/settings/bloc/settings_event.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:findiary/core/theme/app_theme.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override List<Object?> get props => [];
}

final class SettingsRequested extends SettingsEvent {
  const SettingsRequested();
}

final class ThemeChanged extends SettingsEvent {
  final AppTheme theme;
  const ThemeChanged(this.theme);
  @override List<Object?> get props => [theme];
}
```

Create `frontend/lib/features/settings/bloc/settings_bloc.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:findiary/core/auth/auth_service.dart';
import 'package:findiary/core/theme/app_theme.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final AuthService _authService;
  final ThemeCubit _themeCubit;
  final SharedPreferences _prefs;

  SettingsBloc({
    required AuthService authService,
    required ThemeCubit themeCubit,
    required SharedPreferences prefs,
  }) : _authService = authService,
       _themeCubit = themeCubit,
       _prefs = prefs,
       super(const SettingsInitial()) {
    on<SettingsRequested>(_onRequested);
    on<ThemeChanged>(_onThemeChanged);
  }

  void _onRequested(SettingsRequested event, Emitter<SettingsState> emit) {
    final stored = _prefs.getString('app_theme');
    final theme = AppTheme.values.firstWhere(
      (t) => _themeName(t) == stored,
      orElse: () => AppTheme.cleanModern,
    );
    emit(SettingsLoaded(currentTheme: theme));
  }

  void _onThemeChanged(ThemeChanged event, Emitter<SettingsState> emit) {
    _themeCubit.setTheme(event.theme);
    emit(SettingsLoaded(currentTheme: event.theme));
  }

  String _themeName(AppTheme t) {
    switch (t) {
      case AppTheme.cleanModern: return 'clean_modern';
      case AppTheme.darkFinance: return 'dark_finance';
      case AppTheme.warmMinimal: return 'warm_minimal';
    }
  }
}
```

Create `frontend/lib/features/settings/settings_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findiary/core/auth/auth_service.dart';
import 'package:findiary/core/theme/app_theme.dart';
import 'package:findiary/core/di/injection.dart';
import 'package:findiary/features/auth/bloc/auth_bloc.dart';
import 'package:findiary/features/auth/bloc/auth_event.dart';
import 'bloc/settings_bloc.dart';
import 'bloc/settings_event.dart';
import 'bloc/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsBloc(
        authService: sl<AuthService>(),
        themeCubit: sl<ThemeCubit>(),
        prefs: sl<SharedPreferences>(),
      ),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(const SettingsRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Theme', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: AppTheme.values.map((t) {
                  final selected = state is SettingsLoaded && state.currentTheme == t;
                  return ChoiceChip(
                    label: Text(_themeLabel(t)),
                    selected: selected,
                    onSelected: (_) => context.read<SettingsBloc>().add(ThemeChanged(t)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              FilledButton.tonalIcon(
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutRequested());
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _themeLabel(AppTheme t) {
    switch (t) {
      case AppTheme.cleanModern: return 'Clean Modern';
      case AppTheme.darkFinance: return 'Dark Finance';
      case AppTheme.warmMinimal: return 'Warm Minimal';
    }
  }
}
```

- [ ] **Step 3: Run tests**

Run: `flutter test test/features/settings/settings_bloc_test.dart`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add frontend/lib/features/settings/ frontend/test/features/settings/
git commit -m "feat: add settings page with theme selection and logout"
```

---

### Task 8: Run All Tests and Fix

- [ ] **Step 1: Run flutter analyze**

Run: `flutter analyze`
Expected: 0 errors, 0 warnings

- [ ] **Step 2: Run all tests**

Run: `flutter test`
Expected: All tests pass

- [ ] **Step 3: Fix any issues found**

If any lint errors or test failures, fix them.

- [ ] **Step 4: Commit final fixes**

```bash
git add -A
git commit -m "fix: address analyze and test issues"
```
