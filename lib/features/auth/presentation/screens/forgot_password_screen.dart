import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/presentation/layouts/pattern_auth_layout.dart';
import '../../../../core/presentation/widget/custom_text_field/email_text_field_widget.dart';
import '../../../../core/presentation/widget/title_bar_widget.dart';
import '../../../../core/utils/config/routes.dart';
import '../../../../core/utils/styles/app_colors.dart';
import '../../../../core/utils/styles/font.dart';
import '../../../../core/utils/styles/widget_themes/buttons.dart';
import '../cubit/request_password_reset_cubit/request_password_reset_cubit.dart';
import '../models/otp_screen_args.dart';
import '../models/otp_verification_type.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RequestPasswordResetCubit, RequestPasswordResetState>(
      listener: (context, state) {
        if (state.status == RequestResetStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Reset code sent! Check your inbox.')));
          Navigator.pushNamed(
            context,
            Routes.otp,
            arguments: OtpScreenArgs(
              emailOrUserName: emailController.text,
              verificationType: OtpVerificationType.passwordReset,
            ),
          );
        } else if (state.status == RequestResetStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.errorMessage ??
                  'An error occurred. Please try again.')));
        }
      },
      builder: (context, state) {
        final isLoading = state.status == RequestResetStatus.loading;
        return PopScope(
          canPop: !isLoading,
          child: Scaffold(
            body: PatternAuthLayout(
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TitleBarWidget(
                    title: 'Forgot\npassword?',
                    subtitle: 'Enter your email address to reset',
                    spaceBetweenTitles: 8,
                    heroTag: 'auth_title_bar',
                    isHeroEnabled: true,
                    removeTopSpace: true,
                    removeBottomSpace: true,
                  ),
                  SizedBox(height: 30.h),
                  Form(
                    key: formKey,
                    autovalidateMode: state.autovalidateMode,
                    child: EmailTextFieldWidget(
                      controller: emailController,
                      validator: (value) =>
                          value == null || !value.contains('@')
                              ? 'Please enter a valid email'
                              : null,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              final cubit =
                                  context.read<RequestPasswordResetCubit>();
                              cubit.setAutovalidateMode();
                              if (formKey.currentState!.validate()) {
                                cubit.requestReset(emailController.text);
                              }
                            },
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5))
                          : const Text('Next'),
                    ),
                  ),
                ],
              ),
              footer: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Remember password?', style: AppTextStyles.bottomText),
                  TextButton(
                    style: AppButtonThemes.altTextButton.style,
                    onPressed: () => Navigator.pop(context),
                    child: Text('Log in',
                        style: AppTextStyles.secondaryTextButton
                            .copyWith(color: AppColors.teal, fontSize: 15.sp)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
