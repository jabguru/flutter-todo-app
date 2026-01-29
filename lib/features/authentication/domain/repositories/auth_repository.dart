import 'package:fpdart/fpdart.dart';
import 'package:todo_app/core/network/error/failures.dart';
import 'package:todo_app/features/authentication/data/models/auth_response/auth_response.dart';
import 'package:todo_app/features/authentication/data/models/user/user.dart';

abstract class AuthenticationRepository {
  Future<Either<Failure, AuthResponse>> login({
    required String username,
    required String password,
  });

  Future<Either<Failure, User>> getCurrentUser();

  Future<Either<Failure, bool>> isAuthenticated();

  Future<Either<Failure, User?>> getCachedUser();

  Future<Either<Failure, void>> logout();
}
