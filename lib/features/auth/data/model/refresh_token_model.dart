import '../../domain/entities/refresh_token.dart';

class RefreshTokenModel extends RefreshToken {
  const RefreshTokenModel({required super.value, required super.expiresOn});
  factory RefreshTokenModel.fromJson(Map<String, dynamic> json) => RefreshTokenModel(value: json['value'], expiresOn: DateTime.parse(json['expiresOn']));
}
