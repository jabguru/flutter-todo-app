import 'package:dart_mappable/dart_mappable.dart';

part 'user.mapper.dart';

@MappableClass()
class User with UserMappable {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String image;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.image,
  });

  factory User.fromJson(String json) => UserMapper.fromJson(json);

  factory User.fromMap(Map<String, dynamic> map) => UserMapper.fromMap(map);

  String get fullName => '$firstName $lastName';
}
