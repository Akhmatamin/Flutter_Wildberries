import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/api_client.dart';
import '../core/token_storage.dart';
import '../repositories/auth_repository.dart';

sealed class AuthEvent {}

class AuthStarted extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;
  AuthLoginRequested(this.username, this.password);
}

class AuthRegisterRequested extends AuthEvent {
  final String username;
  final String password;
  final String email;
  final String firstName;
  final String lastName;
  final int? age;
  final String? phone;
  AuthRegisterRequested({
    required this.username,
    required this.password,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.age,
    this.phone,
  });
}

class AuthLogoutRequested extends AuthEvent {}

class AuthSessionExpired extends AuthEvent {}

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final bool isLoading;
  final String? error;
  final String username;
  final String email;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.isLoading = false,
    this.error,
    this.username = '',
    this.email = '',
  });
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  final TokenStorage storage;

  AuthBloc(this.repository, this.storage) : super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthSessionExpired>(_onExpired);
  }

  AuthState _authenticated() => AuthState(
    status: AuthStatus.authenticated,
    username: storage.username ?? '',
    email: storage.email ?? '',
  );

  void _onStarted(AuthStarted event, Emitter<AuthState> emit) {
    emit(
      storage.hasToken
          ? _authenticated()
          : const AuthState(status: AuthStatus.unauthenticated),
    );
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState(status: AuthStatus.unauthenticated, isLoading: true));
    try {
      await repository.login(event.username, event.password);
      emit(_authenticated());
    } on ApiException catch (e) {
      emit(AuthState(status: AuthStatus.unauthenticated, error: e.message));
    }
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState(status: AuthStatus.unauthenticated, isLoading: true));
    try {
      await repository.register(
        username: event.username,
        password: event.password,
        email: event.email,
        firstName: event.firstName,
        lastName: event.lastName,
        age: event.age,
        phone: event.phone,
      );

      await repository.login(event.username, event.password);
      emit(_authenticated());
    } on ApiException catch (e) {
      emit(AuthState(status: AuthStatus.unauthenticated, error: e.message));
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await repository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> _onExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    if (state.status != AuthStatus.authenticated) return;
    await storage.clear();
    emit(
      const AuthState(
        status: AuthStatus.unauthenticated,
        error: 'Сессия истекла, войдите снова',
      ),
    );
  }
}
