import 'package:flutter/material.dart';
import "package:flutter_svg/svg.dart";
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/font.dart';
import 'package:gradproject/core/utils/styles/icons.dart';
import 'package:gradproject/core/utils/styles/widget_themes/buttons.dart';
import 'package:gradproject/features/auth/presentation/screens/signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isPassHidden = true;
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
            spacing: 20,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 42),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello',
                        style: AppTextStyles.title,
                      ),
                      Text(
                        'Login to continue',
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
                      TextField(
                        decoration: InputDecoration(
                            hintStyle: AppTextStyles.hint,
                            hintText: 'Username or Email'),
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
                            suffixIconConstraints:
                                BoxConstraints(minHeight: 45, minWidth: 45)),
                      ),
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
                    FilledButton(onPressed: () {}, child: Text('Login')),
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
