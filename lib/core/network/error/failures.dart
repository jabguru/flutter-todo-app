import 'package:equatable/equatable.dart';

class Failure extends Equatable {
  final String message;
  final String? title;
  const Failure({this.message = '', this.title});

  @override
  List<Object?> get props => [message, title];
}

class BiometricFailure extends Failure {
  const BiometricFailure({required String super.title, required super.message});
}
