import 'package:gradproject/features/auth/data/model/user_model.dart';
import 'package:gradproject/features/auth/domain/entity/sign_up_entity.dart';

abstract class AuthRemoteDataSource {
  Future<bool> signIn(String emailOrUserName, String password);
  Future<UserModel> signUp(SignUpEntity signUpEntity);
}
