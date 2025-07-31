class ResetPasswordRequestModel {
  final String userEmail;
  final String password;
  final String confirmPassword;
  final String token;

  ResetPasswordRequestModel({
    required this.userEmail,
    required this.password,
    required this.confirmPassword,
    required this.token,
  });

  Map<String, dynamic> toJson() => {
    'userEmail': userEmail,
    'password': password,
    'confirmPassword': confirmPassword,
    'token': token,
  };
}
