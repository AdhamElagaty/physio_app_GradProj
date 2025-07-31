
import 'package:equatable/equatable.dart';

class EmailParams extends Equatable {
  final String email;

  const EmailParams({required this.email});
  @override
  List<Object> get props => [email];
}
