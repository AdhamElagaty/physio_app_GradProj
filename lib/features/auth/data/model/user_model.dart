class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String userName;
  final Token token;
  final Token refreshToken;
  final String createdOn;

  UserModel({
    required this.password,
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.userName,
    required this.token,
    required this.refreshToken,
    required this.createdOn,
  });

  UserModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? '',
        firstName = json['firstName'] ?? '',
        lastName = json['lastName'] ?? '',
        email = json['email'] ?? '',
        userName = json['userName'] ?? '',
        password = json['password'] ?? '',
        token = Token.fromJson(json['token'] ?? {}),
        refreshToken = Token.fromJson(json['refreshToken'] ?? {}),
        createdOn = json['createdOn'] ?? '';
}

class Token {
  final String value;
  final String expiresOn;

  Token({
    required this.value,
    required this.expiresOn,
  });

  Token.fromJson(Map<String, dynamic> json)
      : value = json['value'] ?? '',
        expiresOn = json['expiresOn'] ?? '';
}
