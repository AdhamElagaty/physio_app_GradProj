import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import "package:flutter_svg/svg.dart";
import 'package:gradproject/core/api/api_manger.dart';
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

class Signup extends StatelessWidget {
  Signup({super.key});
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    bool isPassHidden = false;

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
            print("Email before navigation: ${emailController.text}");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Otp(
                  isForReset: false,
                  email: emailController.text,
                ),
              ),
            );
          }
          if (state.requestState == RequestState.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? '')),
            );
          }
          if (state.requestState == RequestState.loading) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Loading...')),
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
                              'Welcome',
                              style: AppTextStyles.title,
                              textAlign: TextAlign.start,
                            ),
                            Text(
                              'Sign up to continue',
                              style: AppTextStyles.subTitle,
                            )
                          ]),
                    ),
                    Form(
                      key: formKey,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40.w),
                          child: Column(
                            spacing: 20.h,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 0.h,
                              ),
                              Row(
                                spacing: 10.w,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'First name must be not empty';
                                        }
                                      },
                                      controller: firstNameController,
                                      decoration: InputDecoration(
                                          hintStyle: AppTextStyles.hint,
                                          hintText: 'First name'),
                                    ),
                                  ),
                                  Flexible(
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Last name must be not empty';
                                        }
                                      },
                                      controller: lastNameController,
                                      decoration: InputDecoration(
                                          hintStyle: AppTextStyles.hint,
                                          hintText: 'Last name'),
                                    ),
                                  ),
                                ],
                              ),
                              TextFormField(
                                controller: emailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email must be not empty';
                                  }
                                  if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    hintStyle: AppTextStyles.hint,
                                    hintText: 'Email'),
                              ),
                              TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password must be not empty';
                                  }
                                },
                                controller: passwordController,
                                obscureText: isPassHidden,
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
                                        minHeight: 45.h, minWidth: 45.w)),
                              ),
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
                                obscureText: isPassHidden,
                                decoration: InputDecoration(
                                    hintStyle: AppTextStyles.hint,
                                    hintText: 'Confirm password',
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
                                        minHeight: 45.h, minWidth: 45.w)),
                              )
                            ],
                          ),
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
