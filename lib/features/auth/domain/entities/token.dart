import 'package:equatable/equatable.dart';

class Token extends Equatable {
  final String value;
  final DateTime expiresOn;

  const Token({required this.value, required this.expiresOn});

  @override
  List<Object> get props => [value, expiresOn];
}
