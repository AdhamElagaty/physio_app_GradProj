import 'package:flutter/material.dart';
import "package:flutter_svg/svg.dart";
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/font.dart';
import 'package:gradproject/core/utils/styles/icons.dart';
import 'package:gradproject/core/utils/styles/widget_themes/buttons.dart';
import 'package:gradproject/features/auth/presentation/screens/login.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool isPassHidden = true;
  bool isConfirmHidden = true;
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          Flexible(
            flex: 300,
            child: Container(
              width: screenWidth,
              height: 248,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned(
                      bottom: 0,
                      right: -87,
                      child:
                          SvgPicture.asset('assets/images/Rounded_Pattern.svg'))
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 42),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome',
                            style: AppTextStyles.title,
                          ),
                          Text(
                            'Sign up to continue',
                            style: AppTextStyles.subTitle,
                          )
                        ]),
                  ),
                  SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 42),
                      child: Column(
                        spacing: 20,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 0,
                          ),
                          Row(
                            spacing: 10,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: TextField(
                                  decoration: InputDecoration(
                                      hintStyle: AppTextStyles.hint,
                                      hintText: 'First name'),
                                ),
                              ),
                              Flexible(
                                child: TextField(
                                  decoration: InputDecoration(
                                      hintStyle: AppTextStyles.hint,
                                      hintText: 'Last name'),
                                ),
                              ),
                            ],
                          ),
                          TextField(
                            decoration: InputDecoration(
                                hintStyle: AppTextStyles.hint,
                                hintText: 'Username'),
                          ),
                          TextField(
                            obscureText: isPassHidden,
                            decoration: InputDecoration(
                                hintStyle: AppTextStyles.hint,
                                hintText: 'Password',
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(right: 5.0),
                                  child: IconButton(
                                    icon: AppIcon(
                                      isPassHidden
                                          ? AppIcons.show_bulk
                                          : AppIcons.hide_bulk,
                                      size: 30,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isPassHidden = !isPassHidden;
                                      });
                                    },
                                  ),
                                ),
                                suffixIconConstraints: BoxConstraints(
                                    minHeight: 45, minWidth: 45)),
                          ),
                          TextField(
                            obscureText: isPassHidden,
                            decoration: InputDecoration(
                                hintStyle: AppTextStyles.hint,
                                hintText: 'Confirm password',
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(right: 5.0),
                                  child: IconButton(
                                    icon: AppIcon(
                                      isConfirmHidden
                                          ? AppIcons.show_bulk
                                          : AppIcons.hide_bulk,
                                      size: 30,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isConfirmHidden = !isConfirmHidden;
                                      });
                                    },
                                  ),
                                ),
                                suffixIconConstraints: BoxConstraints(
                                    minHeight: 45, minWidth: 45)),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 42.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(),
                        FilledButton(onPressed: () {}, child: Text('Signup')),
                      ],
                    ),
                  ),
                ],
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
                        setState(() {
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => Login()));
                        });
                      },
                      child: Text(
                        'Login',
                        style: AppTextStyles.secondaryTextButton
                            .copyWith(color: AppColors.teal),
                      ))
                ],
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ],
      ),
    );
  }
}
