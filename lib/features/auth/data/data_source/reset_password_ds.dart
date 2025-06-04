abstract class ResetPaasswordRemoteDataSource {
  Future<void> requestResetPassword(String email);
  Future<String> confirmOtp({required String email, required String otp});
  Future<void> resetPassword(
      String email, String token, String password, String confirmPassword);
}
