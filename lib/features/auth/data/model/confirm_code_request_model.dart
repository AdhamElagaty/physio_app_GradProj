class ConfirmCodeRequestModel {
  final String userEmail;
  final String code;
  ConfirmCodeRequestModel({required this.userEmail, required this.code});
  Map<String, dynamic> toJson() => {'userEmail': userEmail, 'code': code};
}
