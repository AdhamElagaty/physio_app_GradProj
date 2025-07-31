import 'package:equatable/equatable.dart';

class ConfirmCodeParams extends Equatable {
  final String email;
  final String code;

  const ConfirmCodeParams({required this.email, required this.code});
  @override
  List<Object> get props => [email, code];
}
