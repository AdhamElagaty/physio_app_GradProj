import 'package:gradproject/features/auth/domain/repo/reset_password_repo.dart';

class SendResetCodeUseCase {
  final ResetPasswordRepository repo;
  SendResetCodeUseCase(this.repo);

  Future<void> call(String email) => repo.sendResetCode(email);
}
