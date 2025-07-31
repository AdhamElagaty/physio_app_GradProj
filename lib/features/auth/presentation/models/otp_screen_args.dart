import 'otp_verification_type.dart';

class OtpScreenArgs {
  final String emailOrUserName;
  final OtpVerificationType verificationType;

  const OtpScreenArgs({
    required this.emailOrUserName,
    required this.verificationType,
  });
}
