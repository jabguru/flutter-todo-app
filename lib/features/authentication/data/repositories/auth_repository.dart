import 'package:fpdart/fpdart.dart';
import 'package:todo_app/core/data/repositories/base_repository.dart';
import 'package:todo_app/core/network/error/failures.dart';
import 'package:todo_app/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:todo_app/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:todo_app/features/authentication/data/models/auth_response/auth_response.dart';
import 'package:todo_app/features/authentication/data/models/login_credentials/login_credentials.dart';
import 'package:todo_app/features/authentication/data/models/user/user.dart';
import 'package:todo_app/features/authentication/domain/repositories/auth_repository.dart';

class AuthenticationRepositoryImpl extends BaseRepository
    implements AuthenticationRepository {
  AuthenticationRepositoryImpl({
    required AuthenticationRemoteDataSource remoteDataSource,
    required AuthenticationLocalDataSource localDataSource,
    required Function(String) onTokenUpdate,
    required Function() onTokenClear,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _onTokenUpdate = onTokenUpdate,
       _onTokenClear = onTokenClear;

  final AuthenticationRemoteDataSource _remoteDataSource;
  final AuthenticationLocalDataSource _localDataSource;
  final Function(String) _onTokenUpdate;
  final Function() _onTokenClear;

  @override
  Future<Either<Failure, AuthResponse>> login({
    required String username,
    required String password,
  }) async {
    return await handleRequest(() async {
      final response = await _remoteDataSource.login(
        username: username,
        password: password,
      );

      // Save tokens and user data
      await _localDataSource.saveAuthToken(response.accessToken);
      await _localDataSource.saveRefreshToken(response.refreshToken);
      await _localDataSource.saveUser(response.user);
      await _localDataSource.saveLoginCredentials(
        LoginCredentials(username: username, password: password),
      );

      // Update network provider token
      _onTokenUpdate(response.accessToken);

      return response;
    });
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    return await handleRequest(() async {
      final user = await _remoteDataSource.getCurrentUser();
      await _localDataSource.saveUser(user);
      return user;
    });
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    return await handleRequest(() async {
      final token = await _localDataSource.getAuthToken();
      return token != null && token.isNotEmpty;
    });
  }

  @override
  Future<Either<Failure, User?>> getCachedUser() async {
    return await handleRequest(() async {
      return await _localDataSource.getUser();
    });
  }

  @override
  Future<Either<Failure, void>> logout() async {
    return await handleRequest(() async {
      await _localDataSource.clearAuthData();
      _onTokenClear();
    });
  }
}
