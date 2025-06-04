import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import "package:flutter_svg/svg.dart";
import 'package:dio/dio.dart';
import 'package:gradproject/core/api/end_points.dart';
import 'package:gradproject/core/utils/config/routes.dart';
import 'package:gradproject/core/utils/constatnts.dart';
import 'package:gradproject/core/utils/config/routes.dart';
import 'package:gradproject/core/utils/styles/font.dart';
import 'package:gradproject/features/auth/presentation/widgets/otp_text_field.dart';

class Otp extends StatefulWidget {
  const Otp({
    super.key,
    required this.isForReset,
    required this.email,
  });

  final bool isForReset;
  final String email;

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  List<TextEditingController> controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  FocusNode focus = FocusNode();

  void _onChangeAction({required String value, required int index}) {
    if (value.isNotEmpty) {
      for (int i = index, j = 0;
          i < controllers.length && j < value.length;
          i++, j++) {
        controllers[i].text = value[j];
        if (i < controllers.length - 1) {
          FocusScope.of(context).nextFocus();
          controllers[i + 1].selection = TextSelection(
            baseOffset: 0,
            extentOffset: controllers[i + 1].text.length,
          );
        }
      }
      if (value.length == controllers.length ||
          index == controllers.length - 1) {
        FocusScope.of(context).unfocus();
        _verify();
      }
    }
  }

  Future<bool> verifyOtp(String otp) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verifying OTP...')),
    );

    Dio dio = Dio();
    const String apiUrl = AppConstatnts.baseUrl + Endpoints.confirmEmail;
    print("Sending OTP verification request:");
    print("URL: $apiUrl");
    print("Data: code=$otp, userEmail=${widget.email}");

    try {
      Response response = await dio.post(
        apiUrl,
        data: {
          "code": otp,
          "userEmail": widget.email,
        },
      );

      ScaffoldMessenger.of(context).clearSnackBars();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP verified successfully!')),
        );
        Navigator.pushNamedAndRemoveUntil(
            context, Routes.test, (route) => false);
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP! Please try again.')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying OTP: $e')),
      );
      print("OTP verification error: $e");
      return false;
    }
  }

  void _verify() async {
    if (controllers.every((i) => i.text.isNotEmpty)) {
      String otp = controllers.map((i) => i.text).join();
      await verifyOtp(otp);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full OTP.')),
      );
    }
  }

  Future<void> _resendCode() async {
    const String apiUrl =
        'https://physio.runasp.net/api/Account/ResendEmailConfirmationCode';

    try {
      final dio = Dio();

      final response = await dio.post(apiUrl, data: {
        'email': widget.email,
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP resent successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to resend code. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 300,
            child: Container(
              width: screenWidth,
              height: 248.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: 0.h,
                    right: -87.w,
                    child:
                        SvgPicture.asset('assets/images/Rounded_Pattern.svg'),
                  ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Check your\nmail', style: AppTextStyles.title),
                    Text('Enter the OTP code', style: AppTextStyles.subTitle),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        6,
                        (index) => OtpTextField(
                          controllers: controllers,
                          index: index,
                          isLast: index == 5,
                          onChanged: _onChangeAction,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _resendCode,
                          child: Text('Resend code'),
                        ),
                        FilledButton(
                          onPressed: _verify,
                          child: Text('Verify'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 25.h),
        ],
      ),
    );
  }
}
