import '../../domain/entities/token.dart';

class TokenModel extends Token {
  const TokenModel({required super.value, required super.expiresOn});
  factory TokenModel.fromJson(Map<String, dynamic> json) => TokenModel(value: json['value'], expiresOn: DateTime.parse(json['expiresOn']));
}
