import 'package:equatable/equatable.dart';

class RefreshToken extends Equatable {
  final String value;
  final DateTime expiresOn;

  const RefreshToken({required this.value, required this.expiresOn});

  @override
  List<Object> get props => [value, expiresOn];
}
