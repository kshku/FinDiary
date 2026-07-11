import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:findiary/core/auth/auth_service.dart';
import 'package:findiary/features/auth/bloc/auth_bloc.dart';
import 'package:findiary/features/auth/bloc/auth_event.dart';
import 'package:findiary/features/auth/bloc/auth_state.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  group('AuthBloc', () {
    blocTest<AuthBloc, AuthState>(
      'emits authenticated when already logged in',
      setUp: () {
        when(() => mockAuthService.isLoggedIn())
            .thenAnswer((_) async => true);
      },
      build: () => AuthBloc(authService: mockAuthService),
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [
        const AuthState(status: AuthStatus.authenticated),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits unauthenticated when not logged in',
      setUp: () {
        when(() => mockAuthService.isLoggedIn())
            .thenAnswer((_) async => false);
      },
      build: () => AuthBloc(authService: mockAuthService),
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [
        const AuthState(status: AuthStatus.unauthenticated),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits authenticated on successful login',
      setUp: () {
        when(() => mockAuthService.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async {});
      },
      build: () => AuthBloc(authService: mockAuthService),
      act: (bloc) => bloc.add(LoginSubmitted(email: 'test@test.com', password: 'pass')),
      expect: () => [
        const AuthState(status: AuthStatus.authenticated),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits error on failed login',
      setUp: () {
        when(() => mockAuthService.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(Exception('Invalid credentials'));
      },
      build: () => AuthBloc(authService: mockAuthService),
      act: (bloc) => bloc.add(LoginSubmitted(email: 'test@test.com', password: 'wrong')),
      expect: () => [
        const AuthState(error: 'Exception: Invalid credentials'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits unauthenticated on logout',
      setUp: () {
        when(() => mockAuthService.logout()).thenAnswer((_) async {});
      },
      build: () => AuthBloc(authService: mockAuthService),
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        const AuthState(status: AuthStatus.unauthenticated),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'registers user successfully',
      setUp: () {
        when(() => mockAuthService.register(
          email: any(named: 'email'),
          password: any(named: 'password'),
          displayName: any(named: 'displayName'),
        )).thenAnswer((_) async {});
      },
      build: () => AuthBloc(authService: mockAuthService),
      act: (bloc) => bloc.add(RegisterSubmitted(
        email: 'test@test.com',
        password: 'pass',
        displayName: 'Test',
      )),
      expect: () => [
        const AuthState(status: AuthStatus.authenticated),
      ],
    );
  });
}
