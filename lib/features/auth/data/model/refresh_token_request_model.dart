class RefreshTokenRequestModel {
  final String token;
  final String refreshToken;
  RefreshTokenRequestModel({required this.token, required this.refreshToken});
  Map<String, dynamic> toJson() => {'token': token, 'refreshToken': refreshToken};
}
