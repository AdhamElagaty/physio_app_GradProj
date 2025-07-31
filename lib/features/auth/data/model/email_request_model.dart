class EmailRequestModel {
  final String email;
  EmailRequestModel({required this.email});
  Map<String, dynamic> toJson() => {'EmailOrUserName': email};
}
