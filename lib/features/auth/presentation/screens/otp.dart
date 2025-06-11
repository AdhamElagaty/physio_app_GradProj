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
          Navigator.pushNamedAndRemoveUntil(context, Routes.home, (r) => false);
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
    final String url = AppConstatnts.baseUrl +
        (widget.isForReset
            ? Endpoints.confirmResetPassword
            : Endpoints.confirmEmail);

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
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 30.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top image
            SizedBox(
              height: 200.h,
              width: screenWidth,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: 0,
                    right: -87.w,
                    child:
                        SvgPicture.asset('assets/images/Rounded_Pattern.svg'),
                  ),
                ],
              ),
            ),

            // Text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Check your\nmail', style: AppTextStyles.title),
                Text('Enter the OTP code', style: AppTextStyles.subTitle),
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
              ],
            ),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _resendOtp,
                  child: const Text('Resend code'),
                ),
                FilledButton(
                  onPressed: _verifyOtp,
                  child: const Text('Verify'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
