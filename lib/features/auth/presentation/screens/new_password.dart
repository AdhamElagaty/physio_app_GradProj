import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradproject/core/api/api_manger.dart';
import 'package:gradproject/core/utils/config/routes.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/font.dart';
import 'package:gradproject/core/utils/styles/icons.dart';
import 'package:gradproject/core/utils/styles/widget_themes/buttons.dart';
import 'package:gradproject/features/auth/data/data_source/reset_password_ds_imp.dart';
import 'package:gradproject/features/auth/data/repo_imp/reset_password_repo_impl.dart';
import 'package:gradproject/features/auth/domain/use_case/reset_passord_use_case.dart';
import 'package:gradproject/features/auth/presentation/manager/reset_password/reset_password_cubit.dart';
import 'package:gradproject/features/auth/presentation/manager/reset_password/reset_password_state.dart';
import 'package:gradproject/features/auth/presentation/screens/login.dart';
import 'package:gradproject/features/auth/presentation/screens/otp.dart';
import 'package:gradproject/features/auth/presentation/screens/signup.dart';

class NewPassword extends StatelessWidget {
  NewPassword({super.key, required this.email, required this.tokn});

  String email, tokn;
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
      listener: (context, state) {
        if (state is ResetPasswordLoading) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sending reset email...')),
          );
        } else if (state is ResetPasswordSuccess) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Reset email sent! Check your inbox.')),
          );
          Navigator.pushReplacementNamed(context, Routes.login);
        } else if (state is ResetPasswordError) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
                            textAlign: TextAlign.start,
                          ),
                          Text(
                            'Enter your new password',
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
                            obscureText: false,
                            controller: passwordController,
                            decoration: InputDecoration(
                                hintStyle: AppTextStyles.hint,
                                hintText: 'New password',
                                suffixIcon: Padding(
                                  padding: EdgeInsets.only(right: 5.0.w),
                                  child: IconButton(
                                    icon: AppIcon(
                                      AppIcons.show_bulk,
                                      // : AppIcons.hide_bulk,
                                      size: 30,
                                      color: AppColors.black50,
                                    ),
                                    onPressed: () {
                                      // setState(() {
                                      //   isPassHidden = !isPassHidden;
                                      // });
                                    },
                                  ),
                                ),
                                suffixIconConstraints: BoxConstraints(
                                    minHeight: 45.h, minWidth: 45.w)),
                          ),
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: false,
                            decoration: InputDecoration(
                                hintStyle: AppTextStyles.hint,
                                hintText: 'Confirm password',
                                suffixIcon: Padding(
                                  padding: EdgeInsets.only(right: 5.0.w),
                                  child: IconButton(
                                    icon: AppIcon(
                                      AppIcons.show_bulk,
                                      // AppIcons.hide_bulk,
                                      size: 30,
                                      color: AppColors.black50,
                                    ),
                                    onPressed: () {
                                      // setState(() {
                                      //   isConfirmHidden = !isConfirmHidden;
                                      // });
                                    },
                                  ),
                                ),
                                suffixIconConstraints: BoxConstraints(
                                    minHeight: 45.h, minWidth: 45.w)),
                          )
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
                              context.read<ResetPasswordCubit>().resetPassword(
                                    email: email,
                                    token: tokn,
                                    password: passwordController.text,
                                    confirmPassword:
                                        confirmPasswordController.text,
                                  );
                              // setState(() {
                              //   Navigator.of(context).push(MaterialPageRoute(
                              //       builder: (context) => Login()));
                              // });
                            },
                            child: Text('Confirm')),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10.h,
              ),
            ],
          ),
        );
      },
    );
  }
}
