import 'package:todo_app/core/storage/local_storage_exception.dart';
import 'package:todo_app/core/storage/secure_local_storage.dart';
import 'package:todo_app/core/storage/shared_pref_storage.dart';
import 'package:todo_app/features/authentication/data/models/login_credentials/login_credentials.dart';
import 'package:todo_app/features/authentication/data/models/user/user.dart';

abstract class AuthenticationLocalDataSource {
  Future<void> saveAuthToken(String token);
  Future<String?> getAuthToken();
  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> saveUser(User user);
  Future<User?> getUser();
  Future<void> saveLoginCredentials(LoginCredentials credentials);
  Future<LoginCredentials?> getLoginCredentials();
  Future<void> clearAuthData();
}

class AuthenticationLocalDataSourceImpl
    implements AuthenticationLocalDataSource {
  AuthenticationLocalDataSourceImpl({
    required SecureLocalStorage secureStorage,
    required SharedPrefStorage sharedPreferences,
  }) : _secureStorage = secureStorage,
       _sharedPreferences = sharedPreferences;

  final SecureLocalStorage _secureStorage;
  final SharedPrefStorage _sharedPreferences;

  static const String _authTokenKey = 'AUTH_TOKEN_KEY';
  static const String _refreshTokenKey = 'REFRESH_TOKEN_KEY';
  static const String _userKey = 'USER_KEY';
  static const String _loginCredentialsKey = 'LOGIN_CREDENTIALS_KEY';

  @override
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.put(key: _authTokenKey, value: token);
  }

  @override
  Future<String?> getAuthToken() async {
    try {
      return await _secureStorage.get(_authTokenKey);
    } on LocalStorageException {
      return null;
    }
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.put(key: _refreshTokenKey, value: token);
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.get(_refreshTokenKey);
    } on LocalStorageException {
      return null;
    }
  }

  @override
  Future<void> saveUser(User user) async {
    final userJson = user.toJson();
    await _sharedPreferences.put(key: _userKey, value: userJson);
  }

  @override
  Future<User?> getUser() async {
    try {
      final userJson = await _sharedPreferences.get(_userKey);
      return User.fromJson(userJson);
    } on LocalStorageException {
      return null;
    }
  }

  @override
  Future<void> saveLoginCredentials(LoginCredentials credentials) async {
    final credentialsJson = credentials.toJson();
    await _secureStorage.put(key: _loginCredentialsKey, value: credentialsJson);
  }

  @override
  Future<LoginCredentials?> getLoginCredentials() async {
    try {
      final credentialsJson = await _secureStorage.get(_loginCredentialsKey);
      return LoginCredentials.fromJson(credentialsJson);
    } on LocalStorageException {
      return null;
    }
  }

  @override
  Future<void> clearAuthData() async {
    await _secureStorage.delete({
      _authTokenKey,
      _refreshTokenKey,
      _loginCredentialsKey,
    });
    await _sharedPreferences.delete({_userKey});
  }
}
