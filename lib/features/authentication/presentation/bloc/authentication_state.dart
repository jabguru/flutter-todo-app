part of 'authentication_bloc.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object?> get props => [];
}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}

class AuthenticationAuthenticated extends AuthenticationState {
  final User user;

  const AuthenticationAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthenticationUnauthenticated extends AuthenticationState {}

class AuthenticationError extends AuthenticationState {
  final String message;
  final String? title;

  const AuthenticationError({required this.message, this.title});

  @override
  List<Object?> get props => [message, title];
}

class LoginLoading extends AuthenticationState {}

class LoginSuccess extends AuthenticationState {
  final AuthResponse authResponse;

  const LoginSuccess({required this.authResponse});

  @override
  List<Object?> get props => [authResponse];
}

class LoginError extends AuthenticationState {
  final String message;
  final String? title;

  const LoginError({required this.message, this.title});

  @override
  List<Object?> get props => [message, title];
}

class LogoutSuccess extends AuthenticationState {}
