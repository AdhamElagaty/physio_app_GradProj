import 'package:dio/dio.dart';
import 'package:gradproject/core/api/api_manger.dart';
import 'package:gradproject/core/api/end_points.dart';
import 'package:gradproject/core/api/status_code.dart';
import 'package:gradproject/core/cahce/share_prefs.dart';
import 'package:gradproject/core/exceptions/failures.dart';
import 'package:gradproject/features/auth/data/data_source/auth_remote_ds.dart';
import 'package:gradproject/features/auth/data/model/user_model.dart';
import 'package:gradproject/features/auth/domain/entity/sign_up_entity.dart';

class AuthRemoteDsImp implements AuthRemoteDataSource {
  ApiManager apiManager;
  AuthRemoteDsImp(this.apiManager);
  @override
  Future<bool> signIn(String email, String password) async {
    try {
      final response = await apiManager.postData(
          endPoint: Endpoints.signIn,
          body: {'emailOrUserName': email, 'password': password});

      if (response.statusCode == StatusCodes.success) {
        final token = Token.fromJson(response.data['data']['token']);
        final refreshToken =
            Token.fromJson(response.data['data']['refreshToken']);
        await CacheHelper.saveToken('token', token);
        await CacheHelper.saveToken('refreshToken', refreshToken);

        print('Sign-in successful');
        print('Token: ${token.value}');
        print('Refresh Token: ${refreshToken.value}');
        return true;
      }

      print('Sign-in failed with status: ${response.statusCode}');
      return false;
    } on DioException catch (e) {
      print('Sign-in error: ${e.response?.statusCode} - ${e.response?.data}');
      throw FailuerRemoteException(
          e.response?.data['message'] ?? e.message ?? "Unknown sign-in error");
    } catch (e) {
      throw FailuerRemoteException(e.toString());
    }
  }

  @override
  Future<UserModel> signUp(SignUpEntity signUpEntity) async {
    try {
      final response = await apiManager.postData(
          endPoint: Endpoints.signUp, body: signUpEntity.toJson());

      print('Response Data: ${response.data}');

      if (response.statusCode == StatusCodes.created &&
          response.data != null &&
          response.data is Map<String, dynamic>) {
        return UserModel.fromJson(response.data);
      } else {
        throw FailuerRemoteException("Invalid response from server");
      }
    } catch (e) {
      throw FailuerRemoteException(e.toString());
    }
  }
}
