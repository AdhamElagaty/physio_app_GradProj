import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/cubit/app_cubit/app_manager_cubit.dart';
import '../../../../core/presentation/layouts/pattern_auth_layout.dart';
import '../../../../core/presentation/widget/title_bar_widget.dart';
import '../../../../core/utils/config/routes.dart';
import '../cubit/otp_verification_cubit/otp_verification_cubit.dart';
import '../models/otp_screen_args.dart';
import '../models/otp_verification_type.dart';
import '../widgets/otp_field.dart';

class OtpScreen extends StatefulWidget {
  final OtpScreenArgs args;

  const OtpScreen({
    super.key,
    required this.args,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late final TextEditingController _otpController;
  late final FocusNode _otpFocusNode;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _otpFocusNode = FocusNode();
    context.read<OtpVerificationCubit>().initializeTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _verifyOtp(String otp) {
    if (context.read<OtpVerificationCubit>().state.status.isLoading) return;
    _otpFocusNode.unfocus();
    context.read<OtpVerificationCubit>().verifyOtp(
          otp: otp,
          email: widget.args.emailOrUserName,
          verificationType: widget.args.verificationType,
        );
  }

  void _onOtpCompleted(String otp) {
    _verifyOtp(otp);
  }

  void _onVerifyPressed() {
    final otp = _otpController.text;
    if (otp.length < 6) {
      _showSnackBar('Please enter the full 6-digit code.');
      return;
    }
    _verifyOtp(otp);
  }

  void _onResendPressed() {
    _otpController.clear();
    _otpFocusNode.requestFocus();
    context.read<OtpVerificationCubit>().resendOtp(
          email: widget.args.emailOrUserName,
          verificationType: widget.args.verificationType,
        );
  }

  void _handleStateChanges(OtpVerificationState state) {
    if (state.status == OtpStatus.verificationSuccess) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return; // Guard before using context.
        _showSnackBar('Verification successful!');
        switch (widget.args.verificationType) {
          case OtpVerificationType.passwordReset:
            Navigator.pushReplacementNamed(context, Routes.newPassword,
                arguments: {
                  'email': widget.args.emailOrUserName,
                  'token': state.resetToken,
                });
            break;
          case OtpVerificationType.emailConfirmation:
          case OtpVerificationType.twoFactorAuthentication:
            context.read<AppManagerCubit>().userLoggedIn();
            break;
        }
      });
    } else if (state.status == OtpStatus.verificationFailure) {
      _showSnackBar(state.errorMessage ?? 'Invalid code.');
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return; 
        context.read<OtpVerificationCubit>().resetVerificationStatus();
        _otpController.clear();
        _otpFocusNode.requestFocus();
      });
    } else if (state.status == OtpStatus.resendSuccess) {
      _showSnackBar('A new code has been sent.');
    } else if (state.status == OtpStatus.resendFailure) {
      _showSnackBar('Failed to resend: ${state.errorMessage}');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return; 
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OtpVerificationCubit, OtpVerificationState>(
      listener: (_, state) => _handleStateChanges(state),
      builder: (context, state) {
        return PopScope(
          canPop: !state.status.isLoading,
          child: Scaffold(
            body: PatternAuthLayout(
              body: _buildFormContent(context, state),
            ),
          ),
        );
      },
    );
  }

  String _getTitle() {
    switch (widget.args.verificationType) {
      case OtpVerificationType.emailConfirmation:
        return 'Check your\nmail';
      case OtpVerificationType.passwordReset:
        return 'Reset your\npassword';
      case OtpVerificationType.twoFactorAuthentication:
        return 'Verify your\nidentity';
    }
  }

  String _getSubtitle() {
    switch (widget.args.verificationType) {
      case OtpVerificationType.emailConfirmation:
        return 'We\'ve sent a verification code to the email address associated with your account';
      case OtpVerificationType.passwordReset:
      case OtpVerificationType.twoFactorAuthentication:
        return 'Enter the code sent to\n${widget.args.emailOrUserName}';
    }
  }

  Widget _buildFormContent(BuildContext context, OtpVerificationState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TitleBarWidget(
          title: _getTitle(),
          subtitle: _getSubtitle(),
          spaceBetweenTitles: 8,
          heroTag: 'auth_title_bar',
          isHeroEnabled: true,
          removeTopSpace: true,
          removeBottomSpace: true,
        ),

        const SizedBox(height: 30.0),
        OtpField(
          controller: _otpController,
          focusNode: _otpFocusNode,
          onCompleted: _onOtpCompleted,
          isSuccess: state.status == OtpStatus.verificationSuccess,
          isError: state.status == OtpStatus.verificationFailure,
          isLoading: state.status.isLoading,
        ),
        const SizedBox(height: 30.0),
        _buildActionButtons(context, state),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, OtpVerificationState state) {
    final isLoading = state.status.isLoading;
    final isResendOnCooldown = (state.resendCooldownSeconds ?? 0) > 0;
    final canResend = widget.args.verificationType !=
        OtpVerificationType.twoFactorAuthentication;

    return Row(
      mainAxisAlignment:
          canResend ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
      children: [
        if (canResend)
          TextButton(
            // FIX: Calling method without context.
            onPressed:
                isLoading || isResendOnCooldown ? null : _onResendPressed,
            child: isResendOnCooldown
                ? Text('Resend in ${state.resendCooldownSeconds}s')
                : const Text('Resend code'),
          ),
        FilledButton(
          onPressed: isLoading ? null : _onVerifyPressed,
          child: state.status == OtpStatus.loading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                )
              : const Text('Verify'),
        ),
      ],
    );
  }
}
