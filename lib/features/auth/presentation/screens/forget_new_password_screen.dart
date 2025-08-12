import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/presentation/layouts/pattern_auth_layout.dart';
import '../../../../core/presentation/widget/custom_text_field/password_text_field_widget.dart';
import '../../../../core/utils/config/routes.dart';
import '../../../../core/utils/styles/font.dart';
import '../cubit/reset_password_cubit/reset_password_cubit.dart';

class ForgetNewPasswordScreen extends StatelessWidget {
  final String email;
  final String token;

  ForgetNewPasswordScreen({
    super.key,
    required this.email,
    required this.token,
  });

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
      listener: (context, state) {
        if (state.status == ResetPasswordStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password has been reset successfully!')));
          Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
        } else if (state.status == ResetPasswordStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage ?? 'An error occurred. Please try again.')));
        }
      },
      builder: (context, state) {
        final isLoading = state.status == ResetPasswordStatus.loading;
        return PopScope(
          canPop: !isLoading,
          child: Scaffold(
            body: PatternAuthLayout(
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Reset password', style: AppTextStyles.title),
                  Text('Enter your new password', style: AppTextStyles.subTitle),
                  SizedBox(height: 30.h),
                  Form(
                    key: formKey,
                    autovalidateMode: state.autovalidateMode,
                    child: Column(
                      children: [
                        PasswordTextFieldWidget(
                          controller: passwordController,
                          hintText: 'New password',
                          isPasswordVisible: state.isPasswordVisible,
                          onVisibilityToggle: () => context.read<ResetPasswordCubit>().togglePasswordVisibility(),
                          validator: (v) => v!.length < 8 ? 'Password must be at least 8 characters' : null,
                        ),
                        SizedBox(height: 20.h),
                        PasswordTextFieldWidget(
                          controller: confirmPasswordController,
                          hintText: 'Confirm password',
                          isPasswordVisible: state.isConfirmPasswordVisible,
                          onVisibilityToggle: () => context.read<ResetPasswordCubit>().toggleConfirmPasswordVisibility(),
                          validator: (v) => v != passwordController.text ? 'Passwords do not match' : null,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              final cubit = context.read<ResetPasswordCubit>();
                              cubit.setAutovalidateMode();
                              if (formKey.currentState!.validate()) {
                                cubit.resetPassword(
                                    email: email,
                                    token: token,
                                    newPassword: passwordController.text);
                              }
                            },
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : const Text('Confirm'),
                    ),
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
