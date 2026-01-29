import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/features/authentication/data/models/auth_response/auth_response.dart';
import 'package:todo_app/features/authentication/data/models/user/user.dart';
import 'package:todo_app/features/authentication/domain/repositories/auth_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepository _repository;

  AuthenticationBloc({required AuthenticationRepository repository})
    : _repository = repository,
      super(AuthenticationInitial()) {
    on<LoginEvent>(_handleLogin);
    on<CheckAuthenticationStatusEvent>(_handleCheckAuthenticationStatus);
    on<LogoutEvent>(_handleLogout);
    on<GetCurrentUserEvent>(_handleGetCurrentUser);
  }

  Future<void> _handleLogin(
    LoginEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(LoginLoading());
    final res = await _repository.login(
      username: event.username,
      password: event.password,
    );
    res.fold(
      (failure) =>
          emit(LoginError(message: failure.message, title: failure.title)),
      (authResponse) => emit(LoginSuccess(authResponse: authResponse)),
    );
  }

  Future<void> _handleCheckAuthenticationStatus(
    CheckAuthenticationStatusEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationLoading());
    final isAuthenticatedResult = await _repository.isAuthenticated();

    await isAuthenticatedResult.fold(
      (failure) async {
        emit(AuthenticationUnauthenticated());
      },
      (isAuthenticated) async {
        if (isAuthenticated) {
          final userResult = await _repository.getCachedUser();
          userResult.fold((failure) => emit(AuthenticationUnauthenticated()), (
            user,
          ) {
            if (user != null) {
              emit(AuthenticationAuthenticated(user: user));
            } else {
              emit(AuthenticationUnauthenticated());
            }
          });
        } else {
          emit(AuthenticationUnauthenticated());
        }
      },
    );
  }

  Future<void> _handleLogout(
    LogoutEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationLoading());
    final res = await _repository.logout();
    res.fold(
      (failure) => emit(
        AuthenticationError(message: failure.message, title: failure.title),
      ),
      (_) => emit(LogoutSuccess()),
    );
  }

  Future<void> _handleGetCurrentUser(
    GetCurrentUserEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationLoading());
    final res = await _repository.getCurrentUser();
    res.fold(
      (failure) => emit(
        AuthenticationError(message: failure.message, title: failure.title),
      ),
      (user) => emit(AuthenticationAuthenticated(user: user)),
    );
  }
}
