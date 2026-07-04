import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/auth/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required this._authService})
      : super(const AuthState()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthErrorShown>(_onErrorShown);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final loggedIn = await _authService.isLoggedIn();
      emit(state.copyWith(
        status: loggedIn
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
      ));
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authService.login(
        email: event.email,
        password: event.password,
      );
      emit(state.copyWith(status: AuthStatus.authenticated));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authService.register(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );
      emit(state.copyWith(status: AuthStatus.authenticated));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.logout();
    emit(state.copyWith(status: AuthStatus.unauthenticated));
  }

  void _onErrorShown(AuthErrorShown event, Emitter<AuthState> emit) {
    emit(state.copyWith(error: null));
  }
}
