import 'package:dart_mappable/dart_mappable.dart';

part 'login_credentials.mapper.dart';

@MappableClass()
class LoginCredentials with LoginCredentialsMappable {
  final String username;
  final String password;

  const LoginCredentials({required this.username, required this.password});

  factory LoginCredentials.fromJson(String json) =>
      LoginCredentialsMapper.fromJson(json);

  factory LoginCredentials.fromMap(Map<String, dynamic> map) =>
      LoginCredentialsMapper.fromMap(map);
}
