import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import "package:flutter_svg/svg.dart";
import 'package:gradproject/core/api/api_manger.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/font.dart';
import 'package:gradproject/core/utils/styles/icons.dart';
import 'package:gradproject/core/utils/styles/widget_themes/buttons.dart';
import 'package:gradproject/features/auth/data/data_source/auth_repo_imp.dart';
import 'package:gradproject/features/auth/data/repo_imp/auth_repo_imp.dart';
import 'package:gradproject/features/auth/domain/use_case/login_use_case.dart';
import 'package:gradproject/features/auth/presentation/manager/login/login_bloc.dart';
import 'package:gradproject/features/auth/presentation/manager/login/login_event.dart';
import 'package:gradproject/features/auth/presentation/manager/login/login_state.dart';

class Login extends StatelessWidget {
  Login({super.key});
  bool isPassHidden = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return BlocProvider(
      create: (context) => AuthBloc(
        LoginUseCase(
          AuthRepoImp(
            AuthRemoteDsImp(
              ApiManager(),
            ),
          ),
        ),
      ),
      child: BlocConsumer<AuthBloc, AuthLoginState>(
        listener: (context, state) {
          if (state.requestState == RequestState.success) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Login sucessssssssssssss!!!!!!'),
            ));
            // Navigator.pushNamed(context, ChatBot.routeName);
          } else if (state.requestState == RequestState.error) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Login failed${state.errorMessage}'),
            ));
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
                              'Hello',
                              style: AppTextStyles.title,
                            ),
                            Text(
                              'Log in to continue',
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
                                hintText: 'Username or Email',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email must not be empty';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              obscureText: isPassHidden,
                              controller: passwordController,
                              decoration: InputDecoration(
                                hintStyle: AppTextStyles.hint,
                                hintText: 'Password',
                                suffixIcon: Padding(
                                  padding: EdgeInsets.only(right: 5.0.w),
                                  child: IconButton(
                                    icon: AppIcon(
                                      isPassHidden
                                          ? AppIcons.show_bulk
                                          : AppIcons.hide_bulk,
                                      size: 30,
                                      color: AppColors.black50,
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                                suffixIconConstraints: BoxConstraints(
                                    minHeight: 45.h, minWidth: 45.w),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password must not be empty';
                                }
                                return null;
                              },
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
                          TextButton(
                              onPressed: () {},
                              child: Text('forgot\npassword')),
                          FilledButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  BlocProvider.of<AuthBloc>(context).add(
                                    LoginEvent(emailController.text,
                                        passwordController.text),
                                  );
                                }
                              },
                              child: Text('Log in')),
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
                            onPressed: () {},
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
