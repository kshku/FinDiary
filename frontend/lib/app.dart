import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/di/injection.dart';
import 'core/auth/auth_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
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
