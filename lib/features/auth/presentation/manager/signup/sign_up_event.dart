import 'package:gradproject/features/auth/domain/entity/sign_up_entity.dart';

abstract class AuthSignupEvent {}

class SignupEvent extends AuthSignupEvent {
  SignUpEntity signUpEntity;

  SignupEvent({required this.signUpEntity});
}
