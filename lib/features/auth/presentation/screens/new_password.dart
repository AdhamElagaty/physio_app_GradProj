import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradproject/core/utils/config/routes.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/font.dart';
import 'package:gradproject/core/utils/styles/icons.dart';
import 'package:gradproject/features/auth/presentation/manager/reset_password/reset_password_cubit.dart';
import 'package:gradproject/features/auth/presentation/manager/reset_password/reset_password_state.dart';

class NewPassword extends StatefulWidget {
  final String email;
  final String tokn;

  const NewPassword({super.key, required this.email, required this.tokn});

  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
      listener: (context, state) {
        if (state is ResetPasswordSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password has been reset successfully!')),
          );
          Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
        } else if (state is ResetPasswordError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 248.h,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.hardEdge,
                            children: [
                              Positioned(
                                bottom: 0.h,
                                right: -87.w,
                                child: SvgPicture.asset('assets/images/Rounded_Pattern.svg'),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Reset password', style: AppTextStyles.title),
                              Text('Enter your new password', style: AppTextStyles.subTitle),
                              SizedBox(height: 30.h),
                              Form(
                                key: formKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: passwordController,
                                      obscureText: _isPasswordObscured,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'New password cannot be empty';
                                        }
                                        if (value.length < 8) {
                                          return 'Password must be at least 8 characters';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintStyle: AppTextStyles.hint,
                                        hintText: 'New password',
                                        suffixIcon: IconButton(
                                          icon: AppIcon(
                                            _isPasswordObscured ? AppIcons.show_bulk : AppIcons.hide_bulk,
                                            size: 30,
                                            color: AppColors.black50,
                                          ),
                                          onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20.h),
                                    TextFormField(
                                      controller: confirmPasswordController,
                                      obscureText: _isConfirmPasswordObscured,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please confirm your password';
                                        }
                                        if (value != passwordController.text) {
                                          return 'Passwords do not match';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintStyle: AppTextStyles.hint,
                                        hintText: 'Confirm password',
                                        suffixIcon: IconButton(
                                          icon: AppIcon(
                                            _isConfirmPasswordObscured ? AppIcons.show_bulk : AppIcons.hide_bulk,
                                            size: 30,
                                            color: AppColors.black50,
                                          ),
                                          onPressed: () => setState(() => _isConfirmPasswordObscured = !_isConfirmPasswordObscured),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 30.h),
                              Align(
                                alignment: Alignment.centerRight,
                                child: FilledButton(
                                  onPressed: state is ResetPasswordLoading ? null : () {
                                    if (formKey.currentState!.validate()) {
                                      context.read<ResetPasswordCubit>().resetPassword(
                                            email: widget.email,
                                            token: widget.tokn,
                                            password: passwordController.text,
                                            confirmPassword: confirmPasswordController.text,
                                          );
                                    }
                                  },
                                  child: state is ResetPasswordLoading
                                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                    : const Text('Confirm'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}