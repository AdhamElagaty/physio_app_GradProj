import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import "package:flutter_svg/svg.dart";
import 'package:gradproject/core/api/api_manger.dart';
import 'package:gradproject/core/utils/error_message.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/font.dart';
import 'package:gradproject/core/utils/styles/icons.dart';
import 'package:gradproject/core/utils/styles/widget_themes/buttons.dart';
import 'package:gradproject/features/auth/data/data_source/auth_remote_ds_imp.dart';
import 'package:gradproject/features/auth/data/repo_imp/auth_repo_imp.dart';
import 'package:gradproject/features/auth/domain/entity/sign_up_entity.dart';
import 'package:gradproject/features/auth/domain/use_case/sign_up_use_case.dart';
import 'package:gradproject/features/auth/presentation/manager/signup/sign_up_bloc.dart';
import 'package:gradproject/features/auth/presentation/manager/signup/sign_up_event.dart';
import 'package:gradproject/features/auth/presentation/manager/signup/sign_up_state.dart';
import 'package:gradproject/features/auth/presentation/screens/otp.dart';


class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  void dispose() {
    firstNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignupBloc(
        SignUpUseCase(
          AuthRepoImp(
            AuthRemoteDsImp(
              ApiManager(),
            ),
          ),
        ),
      ),
      child: BlocConsumer<SignupBloc, AuthSigupState>(
        listener: (context, state) {
          if (state.requestState == RequestState.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Signup Successfully')),
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Otp(
                  isForReset: false,
                  email: emailController.text,
                ),
              ),
            );
          } else if (state.requestState == RequestState.error) {
            final message = getFriendly401Message(state.errorMessage ?? 'An unknown error occurred');
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
                                        'assets/images/Rounded_Pattern.svg'))
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min, // Crucial for centering
                              children: [
                                Text('Welcome', style: AppTextStyles.title),
                                Text('Sign up to continue', style: AppTextStyles.subTitle),
                                SizedBox(height: 30.h),
                                Form(
                                  key: formKey,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: TextFormField(
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'First name must not be empty';
                                                }
                                                return null;
                                              },
                                              controller: firstNameController,
                                              decoration: InputDecoration(
                                                  hintStyle: AppTextStyles.hint,
                                                  hintText: 'First name'),
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Flexible(
                                            child: TextFormField(
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Last name must not be empty';
                                                }
                                                return null;
                                              },
                                              controller: lastNameController,
                                              decoration: InputDecoration(
                                                  hintStyle: AppTextStyles.hint,
                                                  hintText: 'Last name'),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20.h),
                                      TextFormField(
                                        controller: emailController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Email must not be empty';
                                          }
                                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                              .hasMatch(value)) {
                                            return 'Please enter a valid email';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                            hintStyle: AppTextStyles.hint,
                                            hintText: 'Email'),
                                      ),
                                      SizedBox(height: 20.h),
                                      TextFormField(
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Password must not be empty';
                                          }
                                          return null;
                                        },
                                        controller: passwordController,
                                        obscureText: _isPasswordObscured,
                                        decoration: InputDecoration(
                                            hintStyle: AppTextStyles.hint,
                                            hintText: 'Password',
                                            suffixIcon: Padding(
                                              padding: EdgeInsets.only(right: 5.0.w),
                                              child: IconButton(
                                                icon: AppIcon(
                                                  _isPasswordObscured
                                                      ? AppIcons.show_bulk
                                                      : AppIcons.hide_bulk,
                                                  size: 30,
                                                  color: AppColors.black50,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _isPasswordObscured = !_isPasswordObscured;
                                                  });
                                                },
                                              ),
                                            ),
                                            suffixIconConstraints: BoxConstraints(
                                                minHeight: 45.h, minWidth: 45.w)),
                                      ),
                                      SizedBox(height: 20.h),
                                      TextFormField(
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please confirm your password';
                                          }
                                          if (value != passwordController.text) {
                                            return 'Passwords do not match';
                                          }
                                          return null;
                                        },
                                        controller: confirmPasswordController,
                                        obscureText: _isConfirmPasswordObscured,
                                        decoration: InputDecoration(
                                            hintStyle: AppTextStyles.hint,
                                            hintText: 'Confirm password',
                                            suffixIcon: Padding(
                                              padding: EdgeInsets.only(right: 5.0.w),
                                              child: IconButton(
                                                icon: AppIcon(
                                                  _isConfirmPasswordObscured
                                                      ? AppIcons.show_bulk
                                                      : AppIcons.hide_bulk,
                                                  size: 30,
                                                  color: AppColors.black50,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                                                  });
                                                },
                                              ),
                                            ),
                                            suffixIconConstraints: BoxConstraints(
                                                minHeight: 45.h, minWidth: 45.w)),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(height: 30.h),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: FilledButton(
                                      onPressed: state.requestState == RequestState.loading ? null : () {
                                        if (formKey.currentState!.validate()) {
                                          SignUpEntity entity = SignUpEntity(
                                              firstName: firstNameController.text,
                                              email: emailController.text,
                                              password: passwordController.text,
                                              confirmPassword:
                                                  confirmPasswordController.text,
                                              lastName: lastNameController.text);
                                          BlocProvider.of<SignupBloc>(context)
                                              .add(SignupEvent(signUpEntity: entity));
                                        }
                                      },
                                      child: state.requestState == RequestState.loading
                                       ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                       : const Text('Next')),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account?',
                                  style: AppTextStyles.bottomText,
                                ),
                                TextButton(
                                    style: AppButtonThemes.altTextButton.style,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Log in',
                                      style: AppTextStyles.secondaryTextButton.copyWith(
                                          color: AppColors.teal, fontSize: 15.sp),
                                    ))
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