import 'package:dart_mappable/dart_mappable.dart';
import 'package:todo_app/features/authentication/data/models/user/user.dart';

part 'auth_response.mapper.dart';

@MappableClass()
class AuthResponse with AuthResponseMappable {
  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.image,
  });

  final String accessToken;
  final String refreshToken;
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String image;

  factory AuthResponse.fromJson(String json) =>
      AuthResponseMapper.fromJson(json);

  factory AuthResponse.fromMap(Map<String, dynamic> map) =>
      AuthResponseMapper.fromMap(map);

  User get user => User(
    id: id,
    username: username,
    email: email,
    firstName: firstName,
    lastName: lastName,
    gender: gender,
    image: image,
  );
}
