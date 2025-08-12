import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/presentation/layouts/pattern_auth_layout.dart';
import '../../../../core/presentation/widget/custom_text_field/custom_text_field_widget.dart';
import '../../../../core/presentation/widget/custom_text_field/password_text_field_widget.dart';
import '../../../../core/presentation/widget/title_bar_widget.dart';
import '../../../../core/utils/config/routes.dart';
import '../../../../core/utils/styles/app_colors.dart';
import '../../../../core/utils/styles/font.dart';
import '../../../../core/utils/styles/widget_themes/buttons.dart';
import '../../../../core/presentation/cubit/app_cubit/app_manager_cubit.dart';
import '../cubit/login_cubit/login_cubit.dart';
import '../models/otp_screen_args.dart';
import '../models/otp_verification_type.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.status == LoginStatus.success) {
          context.read<AppManagerCubit>().userLoggedIn();
        }
        if (state.status == LoginStatus.requiresEmailConfirmation ||
            state.status == LoginStatus.requires2FA) {
          final type = state.status == LoginStatus.requires2FA
              ? OtpVerificationType.twoFactorAuthentication
              : OtpVerificationType.emailConfirmation;
          Navigator.pushNamed(
            context,
            Routes.otp,
            arguments: OtpScreenArgs(
              emailOrUserName: state.emailForNextStep!,
              verificationType: type,
            ),
          );
        }
        if (state.status == LoginStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(state.errorMessage ?? 'An unknown error occurred.')),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == LoginStatus.loading;
        return PopScope(
          canPop: !isLoading,
          child: Scaffold(
            body: PatternAuthLayout(
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TitleBarWidget(
                    title: 'Hello',
                    subtitle: 'Log in to continue',
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
                        CustomTextFieldWidget(
                          controller: emailController,
                          hintText: 'Username or Email',
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Email must not be empty'
                              : null,
                        ),
                        SizedBox(height: 16.h),
                        PasswordTextFieldWidget(
                          controller: passwordController,
                          hintText: 'Password',
                          isPasswordVisible: state.isPasswordVisible,
                          onVisibilityToggle: () => context
                              .read<LoginCubit>()
                              .togglePasswordVisibility(),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Password must not be empty'
                              : null,
                        ),
                        SizedBox(height: 18.h),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                          onPressed: () => Navigator.pushNamed(
                              context, Routes.forgotPassword),
                          child: const Text('forgot\npassword')),
                      FilledButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                final cubit = context.read<LoginCubit>();
                                cubit.setAutovalidateMode();
                                if (formKey.currentState!.validate()) {
                                  cubit.login(emailController.text,
                                      passwordController.text);
                                }
                              },
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text('Log in'),
                      ),
                    ],
                  ),
                ],
              ),
              footer: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No account?', style: AppTextStyles.bottomText),
                  TextButton(
                    style: AppButtonThemes.altTextButton.style,
                    onPressed: () =>
                        Navigator.pushNamed(context, Routes.signup),
                    child: Text('Sign up',
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
