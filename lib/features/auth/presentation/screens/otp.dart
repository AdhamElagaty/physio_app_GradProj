import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import "package:flutter_svg/svg.dart";
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/font.dart';
import 'package:gradproject/core/utils/styles/icons.dart';
import 'package:gradproject/core/utils/styles/widget_themes/buttons.dart';
import 'package:gradproject/features/auth/presentation/screens/signup.dart';
import 'package:gradproject/features/auth/presentation/widgets/otp_text_field.dart';

class Otp extends StatefulWidget {
  const Otp({super.key, required this.isForReset});
  final bool isForReset;
  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  List<TextEditingController> controllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController()
  ];
  FocusNode focus = FocusNode();
  void _onChangeAction({required String value, required int index}) {
    if (value.isNotEmpty) {
      // controllers[index].text = controllers[index].text[0];
      // FocusScope.of(context).nextFocus();
      for (int i = index, j = 0;
          i < controllers.length && j < value.length;
          i++, j++) {
        controllers[i].text = value[j];
        if (i < controllers.length - 1) {
          FocusScope.of(context).nextFocus();
          controllers[i + 1].selection = TextSelection(
              baseOffset: 0, extentOffset: controllers[i + 1].text.length);
        }
      }
      if (value.length == controllers.length ||
          index == controllers.length - 1) {
        FocusScope.of(context).unfocus();
        _verify();
      }
    }
  }

  void _verify() {
    if (controllers.every((i) => i.text.isNotEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(controllers.map((i) => i.text).join())));
    }
  }

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
                        'Check your\nmail',
                        style: AppTextStyles.title,
                      ),
                      Text(
                        'Enter the OTP code',
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
                      Row(
                        spacing: 10.w,
                        children: [
                          OtpTextField(
                              controllers: controllers,
                              index: 0,
                              onChanged: _onChangeAction),
                          OtpTextField(
                              controllers: controllers,
                              index: 1,
                              onChanged: _onChangeAction),
                          OtpTextField(
                              controllers: controllers,
                              index: 2,
                              onChanged: _onChangeAction),
                          OtpTextField(
                              controllers: controllers,
                              index: 3,
                              onChanged: _onChangeAction),
                          OtpTextField(
                              controllers: controllers,
                              index: 4,
                              onChanged: _onChangeAction),
                          OtpTextField(
                              controllers: controllers,
                              index: 5,
                              isLast: true,
                              onChanged: _onChangeAction),
                        ],
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
                    TextButton(onPressed: () {}, child: Text('Resend code')),
                    FilledButton(
                        onPressed: () {
                          _verify();
                        },
                        child: Text('Verify')),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 25.h,
          ),
        ],
      ),
    );
  }
}
