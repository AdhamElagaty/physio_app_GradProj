class SignUpEntity {
  String firstName;
  String lastName;
  String email;
  String password;
  String confirmPassword;

  SignUpEntity({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'confirmPassword': password,
    };
  }
}
