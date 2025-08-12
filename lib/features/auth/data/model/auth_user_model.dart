import '../../domain/entities/auth_user.dart';
import 'refresh_token_model.dart';
import 'token_model.dart';

class AuthUserModel extends AuthUser {
  final bool require2FA;
  final bool requireEmailConfirmation;

  const AuthUserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.userName,
    super.imageUrl,
    required super.token,
    required super.refreshToken,
    required this.require2FA,
    required this.requireEmailConfirmation,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    final isFullLogin = json.containsKey('id') && json['id'] != null;

    final is2FARequired = json['require2FA'] ?? false;
    final isEmailConfirmationRequired = json['requireEmailConfirmation'] ?? false;

    return AuthUserModel(
      id: isFullLogin ? json['id'] : '',
      firstName: isFullLogin ? json['firstName'] : '',
      lastName: isFullLogin ? json['lastName'] : '',
      email: json['email'],
      userName: isFullLogin ? json['userName'] : '',
      imageUrl: isFullLogin ? json['imageUrl'] : null,
      token: isFullLogin
          ? TokenModel.fromJson(json['token'])
          : TokenModel(value: '', expiresOn: DateTime(0)),    
      refreshToken: isFullLogin
          ? RefreshTokenModel.fromJson(json['refreshToken'])
          : RefreshTokenModel(value: '', expiresOn: DateTime(0)),
      require2FA: is2FARequired,
      requireEmailConfirmation: isEmailConfirmationRequired,
    );
  }
}
