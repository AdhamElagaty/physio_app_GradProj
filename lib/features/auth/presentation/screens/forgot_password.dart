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
import 'package:gradproject/features/auth/presentation/manager/reset_password/reset_password_state.dart';
import 'package:gradproject/features/auth/presentation/screens/otp.dart';

class ForgotPassword extends StatelessWidget {
  ForgotPassword({super.key});

  final TextEditingController emailController = TextEditingController();
  bool isPassHidden = true;
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

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
          if (state is RequestResetPasswordLoading) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sending reset email...')),
            );
          } else if (state is RequestResetPasswordSuccess) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide loading
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Reset email sent! Check your inbox.')),
            );
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    Otp(isForReset: true, email: emailController.text),
              ),
            );
          } else if (state is RequestResetPasswordError) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide loading
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20.h,
              children: [
                Flexible(
                  flex: 300,
                  child: Container(
                    width: screenWidth,
                    height: 248.h,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.hardEdge,
                      children: [
                        Positioned(
                            bottom: 0.h,
                            right: -87.w,
                            child: SvgPicture.asset(
                                'assets/images/Rounded_Pattern.svg'))
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20.h,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reset password',
                              style: AppTextStyles.title,
                            ),
                            Text(
                              'Enter your email to continue',
                              style: AppTextStyles.subTitle,
                            )
                          ]),
                    ),
                    SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.w),
                        child: Column(
                          spacing: 20.h,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 0.h,
                            ),
                            TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                  hintStyle: AppTextStyles.hint,
                                  hintText: 'Email'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.0.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(),
                          FilledButton(
                              onPressed: () {
                                context
                                    .read<RequestResetPasswordCubit>()
                                    .requestResetPassword(emailController.text);
                              },
                              child: Text('Next')),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No account?',
                          style: AppTextStyles.bottomText,
                        ),
                        TextButton(
                            style: AppButtonThemes.altTextButton.style,
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, Routes.signup);
                            },
                            child: Text(
                              'Sign up',
                              style: AppTextStyles.secondaryTextButton.copyWith(
                                  color: AppColors.teal, fontSize: 15.sp),
                            ))
                      ],
                    ),
                    SizedBox(
                      height: 10.h,
                    )
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
