import 'package:todo_app/core/network/endpoints.dart';
import 'package:todo_app/core/network/network_provider.dart';
import 'package:todo_app/features/authentication/data/models/auth_response/auth_response.dart';
import 'package:todo_app/features/authentication/data/models/user/user.dart';

abstract class AuthenticationRemoteDataSource {
  Future<AuthResponse> login({
    required String username,
    required String password,
    int expiresInMins,
  });

  Future<User> getCurrentUser();
}

class AuthenticationRemoteDataSourceImpl
    implements AuthenticationRemoteDataSource {
  final NetworkProvider _networkProvider;

  AuthenticationRemoteDataSourceImpl(this._networkProvider);

  @override
  Future<AuthResponse> login({
    required String username,
    required String password,
    int expiresInMins = 60,
  }) async {
    final response = await _networkProvider.call(
      path: Endpoints.login,
      method: RequestMethod.post,
      body: {
        'username': username.trim(),
        'password': password,
        'expiresInMins': expiresInMins,
      },
    );
    return AuthResponse.fromMap(response?.data as Map<String, dynamic>);
  }

  @override
  Future<User> getCurrentUser() async {
    final response = await _networkProvider.call(
      path: Endpoints.currentUser,
      method: RequestMethod.get,
    );
    return User.fromMap(response?.data as Map<String, dynamic>);
  }
}
