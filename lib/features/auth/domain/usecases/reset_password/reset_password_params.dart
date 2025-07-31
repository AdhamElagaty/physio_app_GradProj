import 'package:equatable/equatable.dart';

class ResetPasswordParams extends Equatable {
  final String email;
  final String token;
  final String newPassword;

  const ResetPasswordParams({
    required this.email,
    required this.token,
    required this.newPassword,
  });

  @override
  List<Object> get props => [email, token, newPassword];
}
