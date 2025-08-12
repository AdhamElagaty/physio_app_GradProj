import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/presentation/layouts/pattern_auth_layout.dart';
import '../../../../core/presentation/widget/custom_text_field/custom_text_field_widget.dart';
import '../../../../core/presentation/widget/custom_text_field/email_text_field_widget.dart';
import '../../../../core/presentation/widget/custom_text_field/password_text_field_widget.dart';
import '../../../../core/presentation/widget/title_bar_widget.dart';
import '../../../../core/utils/config/routes.dart';
import '../../../../core/utils/styles/app_colors.dart';
import '../../../../core/utils/styles/font.dart';
import '../../../../core/utils/styles/widget_themes/buttons.dart';
import '../cubit/signup_cubit/signup_cubit.dart';
import '../models/otp_screen_args.dart';
import '../models/otp_verification_type.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignupCubit, SignupState>(
      listener: (context, state) {
        if (state.status == SignupStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Signup successful! Please check your email for a verification code.')));
          Navigator.pushNamed(
            context,
            Routes.otp,
            arguments: OtpScreenArgs(
              emailOrUserName: emailController.text,
              verificationType: OtpVerificationType.emailConfirmation,
            ),
          );
        } else if (state.status == SignupStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text(state.errorMessage ?? 'An unknown error occurred')));
        }
      },
      builder: (context, state) {
        final isLoading = state.status == SignupStatus.loading;
        return PopScope(
          canPop: !isLoading,
          child: Scaffold(
            body: PatternAuthLayout(
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TitleBarWidget(
                    title: 'Welcome',
                    subtitle: 'Sign up to continue',
                    heroTag: "auth_title_bar",
                    isHeroEnabled: true,
                    removeTopSpace: true,
                    removeBottomSpace: true,
                  ),
                  SizedBox(height: 30.h),
                  Form(
                    key: formKey,
                    autovalidateMode: state.autovalidateMode,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: CustomTextFieldWidget(
                                controller: firstNameController,
                                hintText: 'First name',
                                validator: (v) =>
                                    v!.isEmpty ? 'Required' : null,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Flexible(
                              child: CustomTextFieldWidget(
                                controller: lastNameController,
                                hintText: 'Last name',
                                validator: (v) =>
                                    v!.isEmpty ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        EmailTextFieldWidget(
                          controller: emailController,
                          validator: (v) => v!.isEmpty || !v.contains('@')
                              ? 'Invalid Email'
                              : null,
                        ),
                        SizedBox(height: 20.h),
                        PasswordTextFieldWidget(
                          controller: passwordController,
                          hintText: 'Password',
                          isPasswordVisible: state.isPasswordVisible,
                          onVisibilityToggle: () => context
                              .read<SignupCubit>()
                              .togglePasswordVisibility(),
                          validator: (v) => v!.length < 8
                              ? 'Password must be at least 8 characters'
                              : null,
                        ),
                        SizedBox(height: 20.h),
                        PasswordTextFieldWidget(
                          controller: confirmPasswordController,
                          hintText: 'Confirm password',
                          isPasswordVisible: state.isConfirmPasswordVisible,
                          onVisibilityToggle: () => context
                              .read<SignupCubit>()
                              .toggleConfirmPasswordVisibility(),
                          validator: (v) => v != passwordController.text
                              ? 'Passwords do not match'
                              : null,
                        )
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
                              final cubit = context.read<SignupCubit>();
                              cubit.setAutovalidateMode();
                              if (formKey.currentState!.validate()) {
                                cubit.register(
                                  firstName: firstNameController.text,
                                  lastName: lastNameController.text,
                                  email: emailController.text,
                                  password: passwordController.text,
                                );
                              }
                            },
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text('Next'),
                    ),
                  ),
                ],
              ),
              footer: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account?',
                      style: AppTextStyles.bottomText),
                  TextButton(
                    style: AppButtonThemes.altTextButton.style,
                    onPressed: () => Navigator.pop(context),
                    child: Text('Log in',
                        style: AppTextStyles.secondaryTextButton
                            .copyWith(color: AppColors.teal, fontSize: 15.sp)),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
