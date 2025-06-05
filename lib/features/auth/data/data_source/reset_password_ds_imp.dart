import 'package:gradproject/core/api/api_manger.dart';
import 'package:gradproject/core/api/end_points.dart';
import 'package:gradproject/core/api/status_code.dart';
import 'package:gradproject/core/exceptions/failures.dart';
import 'package:gradproject/features/auth/data/data_source/reset_password_ds.dart';

class AuthRemoteDataSourceImpl implements ResetPaasswordRemoteDataSource {
  ApiManager apiManager;

  AuthRemoteDataSourceImpl(this.apiManager);

  @override
  Future<void> requestResetPassword(String email) async {
    try {
      final response = await apiManager.postData(
          endPoint: Endpoints.requestResetPassword, body: {"Email": email});

      if (response.statusCode == StatusCodes.success) {
        print(response.data);
      }
    } catch (e) {
      throw FailuerRemoteException(
          'Failed to request reset password ${e.toString()}');
    }
  }

  @override
  Future<String> confirmOtp(
      {required String email, required String otp}) async {
    try {
      final response = await apiManager.postData(
        endPoint: Endpoints.confirmResetPassword,
        body: {
          "otp": otp,
          "userEmail": email,
        },
      );
      return response.data['token'] ?? '';
    } on Exception catch (e) {
      throw FailuerRemoteException(
        'Failed to confirm otp ${e.toString()}',
      );
    } catch (e) {
      throw FailuerRemoteException(e.toString());
    }
  }

  @override
  Future<void> resetPassword(String email, String token, String password,
      String confirmPassword) async {
    try {
      final response = await apiManager.postData(
        endPoint: Endpoints.resetPassword,
        body: {
          'userEmail': email,
          'password': password,
          'confirmPassword': confirmPassword,
          'token': token,
        },
      );

      if (response.statusCode == StatusCodes.success) {
        print(response.data);
      }
    } on Exception catch (e) {
      throw FailuerRemoteException(
        'Failed to reset password ${e.toString()}',
      );
    } catch (e) {
      throw FailuerRemoteException(e.toString());
    }
  }
}
