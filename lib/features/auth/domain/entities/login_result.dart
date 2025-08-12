import 'auth_user.dart';

sealed class LoginResult {}

class LoginSuccess extends LoginResult {
  final AuthUser user;
  LoginSuccess(this.user);
}

class LoginRequires2FA extends LoginResult {
  final String email;
  LoginRequires2FA(this.email);
}

class LoginRequiresEmailConfirmation extends LoginResult {
  final String emailOrUserName;
  LoginRequiresEmailConfirmation(this.emailOrUserName);
}
