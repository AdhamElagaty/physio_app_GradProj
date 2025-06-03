// otp_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:gradproject/core/api/api_manger.dart';

part 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  final ApiManager apiManager;

  OtpCubit(this.apiManager) : super(OtpInitial());

  Future<void> verifyOtp(String email, String otp) async {
    emit(OtpLoading());

    try {
      final response = await apiManager.postData(
        endPoint: '/api/Auth/ConfirmEmail',
        body: {
          "code": otp,
          "userEmail": email,
        },
      );

      if (response.statusCode == 200) {
        emit(OtpSuccess());
      } else {
        emit(OtpFailure('Invalid OTP! Please try again.'));
      }
    } catch (e) {
      emit(OtpFailure('Error verifying OTP: $e'));
    }
  }
}
