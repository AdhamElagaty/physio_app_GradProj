abstract class ResetPasswordRepository {
  Future<void> sendResetCode(String email);
  Future<void> verifyOtp(String email, String otp);
  Future<void> resetPassword(String email, String newPassword);
}
