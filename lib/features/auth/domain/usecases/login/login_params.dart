import 'package:equatable/equatable.dart';

class LoginParams extends Equatable {
  final String emailOrUsername;
  final String password;

  const LoginParams({required this.emailOrUsername, required this.password});
  @override
  List<Object> get props => [emailOrUsername, password];
}
