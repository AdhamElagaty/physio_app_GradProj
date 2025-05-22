import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/font.dart';
import 'package:gradproject/core/utils/styles/icons.dart';
import 'package:gradproject/core/utils/styles/widget_themes/buttons.dart';
import 'package:gradproject/features/auth/presentation/screens/otp.dart';
import 'package:gradproject/features/auth/presentation/screens/signup.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool isPassHidden = true;
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

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
                      child:
                          SvgPicture.asset('assets/images/Rounded_Pattern.svg'))
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
                        decoration: InputDecoration(
                            hintStyle: AppTextStyles.hint, hintText: 'Email'),
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
                          setState(() {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Otp(
                                      isForReset: true,
                                    )));
                          });
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
                        setState(() {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Signup()));
                        });
                      },
                      child: Text(
                        'Sign up',
                        style: AppTextStyles.secondaryTextButton
                            .copyWith(color: AppColors.teal, fontSize: 15.sp),
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
  }
}
