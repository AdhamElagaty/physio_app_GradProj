import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/font.dart';
import 'package:gradproject/core/utils/styles/icons.dart';
import 'package:gradproject/core/utils/styles/widget_themes/buttons.dart';
import 'package:gradproject/features/auth/presentation/screens/login.dart';
import 'package:gradproject/features/auth/presentation/screens/otp.dart';
import 'package:gradproject/features/auth/presentation/screens/signup.dart';

class NewPassword extends StatefulWidget {
  const NewPassword({super.key});

  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  bool isPassHidden = true;
  bool isConfirmHidden = true;
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
                        obscureText: isPassHidden,
                        decoration: InputDecoration(
                            hintStyle: AppTextStyles.hint,
                            hintText: 'New password',
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
                                onPressed: () {
                                  setState(() {
                                    isPassHidden = !isPassHidden;
                                  });
                                },
                              ),
                            ),
                            suffixIconConstraints: BoxConstraints(
                                minHeight: 45.h, minWidth: 45.w)),
                      ),
                      TextFormField(
                        obscureText: isPassHidden,
                        decoration: InputDecoration(
                            hintStyle: AppTextStyles.hint,
                            hintText: 'Confirm password',
                            suffixIcon: Padding(
                              padding: EdgeInsets.only(right: 5.0.w),
                              child: IconButton(
                                icon: AppIcon(
                                  isConfirmHidden
                                      ? AppIcons.show_bulk
                                      : AppIcons.hide_bulk,
                                  size: 30,
                                  color: AppColors.black50,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isConfirmHidden = !isConfirmHidden;
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
                                builder: (context) => Login()));
                          });
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
  }
}
