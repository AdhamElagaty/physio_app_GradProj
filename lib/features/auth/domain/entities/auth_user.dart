import 'package:equatable/equatable.dart';

import 'refresh_token.dart';
import 'token.dart';

class AuthUser extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String userName;
  final String? imageUrl;
  final Token token;
  final RefreshToken refreshToken;

  const AuthUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.userName,
    this.imageUrl,
    required this.token,
    required this.refreshToken,
  });

  @override
  List<Object> get props => [id, email, userName, token, refreshToken];
}
