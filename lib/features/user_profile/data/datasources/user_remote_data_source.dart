import '../model/user_details_model.dart';

abstract class UserRemoteDataSource {
  Future<UserDetailsModel> getCurrentUserDetails();
}