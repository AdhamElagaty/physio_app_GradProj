import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import "package:flutter_svg/svg.dart";
import 'package:gradproject/core/api/api_manger.dart';
import 'package:gradproject/core/utils/config/routes.dart';
import 'package:gradproject/core/utils/error_message.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/font.dart';
import 'package:gradproject/core/utils/styles/icons.dart';
import 'package:gradproject/core/utils/styles/widget_themes/buttons.dart';
import 'package:gradproject/features/auth/data/data_source/auth_remote_ds_imp.dart';
import 'package:gradproject/features/auth/data/repo_imp/auth_repo_imp.dart';
import 'package:gradproject/features/auth/domain/use_case/login_use_case.dart';
import 'package:gradproject/features/auth/presentation/manager/login/login_bloc.dart';
import 'package:gradproject/features/auth/presentation/manager/login/login_event.dart';
import 'package:gradproject/features/auth/presentation/manager/login/login_state.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        LoginUseCase(
          AuthRepoImp(
            AuthRemoteDsImp(ApiManager()),
          ),
        ),
      ),
      child: BlocConsumer<AuthBloc, AuthLoginState>(
        listener: (context, state) {
          if (state.requestState == RequestState.success) {
            // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            //   content: Text('Login success!'),
            // ));
            Navigator.pushNamedAndRemoveUntil(
                context, Routes.home, (route) => false);
          }
          if (state.requestState == RequestState.error) {
            final message = map401ErrorToUserMessage(state.errorMessage.isEmpty
                ? state.errorMessage
                : 'An unknown error occurred.');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
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
                                  child: SvgPicture.asset(
                                    'assets/images/Rounded_Pattern.svg',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize:
                                  MainAxisSize.min, // Crucial for centering
                              children: [
                                Text('Hello', style: AppTextStyles.title),
                                Text('Log in to continue',
                                    style: AppTextStyles.subTitle),
                                SizedBox(height: 30.h),
                                Form(
                                  key: formKey,
                                  child: Column(
                                    children: [
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
                                      SizedBox(height: 16.h),
                                      TextFormField(
                                        obscureText: !state.isPasswordVisible,
                                        controller: passwordController,
                                        decoration: InputDecoration(
                                          hintStyle: AppTextStyles.hint,
                                          hintText: 'Password',
                                          suffixIcon: Padding(
                                            padding:
                                                EdgeInsets.only(right: 5.0.w),
                                            child: IconButton(
                                              icon: AppIcon(
                                                state.isPasswordVisible
                                                    ? AppIcons.hide_bulk
                                                    : AppIcons.show_bulk,
                                                size: 30,
                                                color: AppColors.black50,
                                              ),
                                              onPressed: () {
                                                context.read<AuthBloc>().add(
                                                    PasswordVisibilityEvent());
                                              },
                                            ),
                                          ),
                                          suffixIconConstraints: BoxConstraints(
                                            minHeight: 45.h,
                                            minWidth: 45.w,
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Password must not be empty';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 18.h),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: () => Navigator.pushNamed(
                                          context, Routes.forgotPassword),
                                      child: const Text('forgot\npassword'),
                                    ),
                                    FilledButton(
                                      onPressed: state.requestState ==
                                              RequestState.loading
                                          ? null
                                          : () {
                                              if (formKey.currentState!
                                                  .validate()) {
                                                context.read<AuthBloc>().add(
                                                      LoginEvent(
                                                        emailController.text,
                                                        passwordController.text,
                                                      ),
                                                    );
                                              }
                                            },
                                      child: state.requestState ==
                                              RequestState.loading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2.5))
                                          : const Text('Log in'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('No account?',
                                    style: AppTextStyles.bottomText),
                                TextButton(
                                  style: AppButtonThemes.altTextButton.style,
                                  onPressed: () => Navigator.pushNamed(
                                      context, Routes.signup),
                                  child: Text(
                                    'Sign up',
                                    style: AppTextStyles.secondaryTextButton
                                        .copyWith(
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
