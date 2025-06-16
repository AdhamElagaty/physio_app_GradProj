import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradproject/core/api/api_manger.dart';
import 'package:gradproject/core/utils/config/routes.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/font.dart';
import 'package:gradproject/core/utils/styles/widget_themes/buttons.dart';
import 'package:gradproject/features/auth/data/data_source/reset_password_ds_imp.dart';
import 'package:gradproject/features/auth/data/repo_imp/reset_password_repo_impl.dart';
import 'package:gradproject/features/auth/domain/use_case/reset_passord_use_case.dart';
import 'package:gradproject/features/auth/presentation/manager/request_reset_password/request_reset_password_cubit.dart';
import 'package:gradproject/features/auth/presentation/manager/request_reset_password/request_reset_password_state.dart';
import 'package:gradproject/features/auth/presentation/screens/otp.dart';

class ForgotPassword extends StatelessWidget {
  ForgotPassword({super.key});

  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RequestResetPasswordCubit(
        RequestResetPasswordUseCase(
          AuthRepositoryImpl(
            AuthRemoteDataSourceImpl(
              ApiManager(),
            ),
          ),
        ),
      ),
      child: BlocConsumer<RequestResetPasswordCubit, RequestResetPasswordState>(
        listener: (context, state) {
          if (state is RequestResetPasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reset email sent! Check your inbox.')),
            );
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Otp(isForReset: true, email: emailController.text),
              ),
            );
          } else if (state is RequestResetPasswordError) {
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
                          // CHILD 1: TOP IMAGE
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
                              mainAxisSize: MainAxisSize.min, // Important for centering
                              children: [
                                Text('Reset password', style: AppTextStyles.title),
                                Text('Enter your email to continue', style: AppTextStyles.subTitle),
                                SizedBox(height: 30.h),
                                Form(
                                  key: formKey,
                                  child: TextFormField(
                                    controller: emailController,
                                    decoration: InputDecoration(
                                      hintStyle: AppTextStyles.hint,
                                      hintText: 'Email',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Email must not be empty';
                                      }
                                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(height: 30.h),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: FilledButton(
                                    onPressed: state is RequestResetPasswordLoading ? null : () {
                                      if (formKey.currentState!.validate()) {
                                        context.read<RequestResetPasswordCubit>().requestResetPassword(emailController.text);
                                      }
                                    },
                                    child: state is RequestResetPasswordLoading
                                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                      : const Text('Next'),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // CHILD 3: BOTTOM LINK
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('No account?', style: AppTextStyles.bottomText),
                                TextButton(
                                  style: AppButtonThemes.altTextButton.style,
                                  onPressed: () => Navigator.pushReplacementNamed(context, Routes.signup),
                                  child: Text(
                                    'Sign up',
                                    style: AppTextStyles.secondaryTextButton.copyWith(
                                      color: AppColors.teal,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}