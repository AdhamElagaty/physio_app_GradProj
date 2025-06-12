import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import "package:flutter_svg/flutter_svg.dart";
import 'package:dio/dio.dart';
import 'package:gradproject/core/api/api_manger.dart';
import 'package:gradproject/core/api/end_points.dart';
import 'package:gradproject/core/utils/config/routes.dart';
import 'package:gradproject/core/utils/constatnts.dart';
import 'package:gradproject/core/utils/styles/font.dart';
import 'package:gradproject/features/auth/data/data_source/reset_password_ds_imp.dart';
import 'package:gradproject/features/auth/data/repo_imp/reset_password_repo_impl.dart';
import 'package:gradproject/features/auth/domain/use_case/reset_passord_use_case.dart';
import 'package:gradproject/features/auth/presentation/manager/reset_password/reset_password_cubit.dart';
import 'package:gradproject/features/auth/presentation/screens/new_password.dart';
import 'package:gradproject/features/auth/presentation/widgets/otp_text_field.dart';

class Otp extends StatefulWidget {
  const Otp({
    super.key,
    required this.email,
    required this.isForReset,
  });

  final String email;
  final bool isForReset;

  @override
  State<Otp> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<Otp> {
  List<TextEditingController> controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  Future<void> _verifyOtp() async {
    if (controllers.any((c) => c.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full OTP.')),
      );
      return;
    }

    final String otp = controllers.map((e) => e.text).join();
    final dio = Dio();

    final String url = widget.isForReset
        ? AppConstatnts.baseUrl + Endpoints.confirmResetPassword
        : AppConstatnts.baseUrl + Endpoints.confirmEmail;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verifying OTP...')),
      );

      final response = await dio.post(url, data: {
        'code': otp,
        'userEmail': widget.email,
      });

      ScaffoldMessenger.of(context).clearSnackBars();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP verified successfully!')),
        );

        if (widget.isForReset) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (context) => ResetPasswordCubit(ResetPasswordUseCase(
                  AuthRepositoryImpl(
                    AuthRemoteDataSourceImpl(
                      ApiManager(),
                    ),
                  ),
                )),
                child: NewPassword(
                  email: widget.email,
                  tokn: response.data['data']['token'],
                ),
              ),
            ),
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, Routes.login, (r) => false);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP! Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying OTP: $e')),
      );
    }
  }

  Future<void> _resendOtp() async {
    final dio = Dio();
    final String url = AppConstatnts.baseUrl + Endpoints.forgotPassword;

    try {
      final response = await dio.post(url, data: {
        'email': widget.email,
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP resent successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to resend OTP.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

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

        _verifyOtp();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
                    TextButton(
                        onPressed: _resendOtp, child: Text('Resend code')),
                    FilledButton(onPressed: _verifyOtp, child: Text('Verify')),
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
