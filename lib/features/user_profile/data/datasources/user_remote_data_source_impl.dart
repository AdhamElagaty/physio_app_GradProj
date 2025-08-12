import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/endpoints.dart';
import '../model/user_details_model.dart';
import 'user_remote_data_source.dart';

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiConsumer _apiConsumer;
  UserRemoteDataSourceImpl(this._apiConsumer);

  @override
  Future<UserDetailsModel> getCurrentUserDetails() async {
    final response = await _apiConsumer.get(Endpoints.userProfileGet);
    return UserDetailsModel.fromJson(response['data']);
  }
}