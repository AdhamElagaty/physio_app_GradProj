import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  // State for OTP controllers and loading status
  final List<TextEditingController> controllers = List.generate(6, (_) => TextEditingController());
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (_isLoading) return;

    if (controllers.any((c) => c.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full OTP.')),
      );
      return;
    }
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      final String otp = controllers.map((e) => e.text).join();
      final String url = widget.isForReset
          ? AppConstatnts.baseUrl + Endpoints.confirmResetPassword
          : AppConstatnts.baseUrl + Endpoints.confirmEmail;
      
      final response = await Dio().post(url, data: {'code': otp, 'userEmail': widget.email});

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP verified successfully!')));

        if (widget.isForReset) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (context) => ResetPasswordCubit(ResetPasswordUseCase(
                  AuthRepositoryImpl(AuthRemoteDataSourceImpl(ApiManager())),
                )),
                child: NewPassword(email: widget.email, tokn: response.data['data']['token']),
              ),
            ),
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid OTP. Please try again.')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resending OTP...')));
    try {
      final String url = AppConstatnts.baseUrl + Endpoints.forgotPassword;
      final response = await Dio().post(url, data: {'email': widget.email});
      
      if (!mounted) return;
      
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A new OTP has been sent.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to resend OTP.')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onChangeAction({required String value, required int index}) {
    if (value.isNotEmpty) {
      for (int i = index, j = 0; i < controllers.length && j < value.length; i++, j++) {
        controllers[i].text = value[j];
        if (i < controllers.length - 1) {
          FocusScope.of(context).nextFocus();
          controllers[i + 1].selection = TextSelection(baseOffset: 0, extentOffset: controllers[i + 1].text.length);
        }
      }
      if (value.length == controllers.length || index == controllers.length - 1) {
        if (controllers.every((c) => c.text.isNotEmpty)) {
          _verifyOtp();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // CHILD 1: TOP IMAGE
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
                            child: SvgPicture.asset('assets/images/Rounded_Pattern.svg'),
                          )
                        ],
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Check your\nmail', style: AppTextStyles.title),
                          SizedBox(height: 8.h),
                          Text('Enter the OTP code sent to\n${widget.email}', style: AppTextStyles.subTitle),
                          SizedBox(height: 30.h),
                          Row(
                            spacing: 10.w,
                            children: List.generate(6, (index) {
                              return OtpTextField(
                                controllers: controllers,
                                index: index,
                                isLast: index == 5,
                                onChanged: _onChangeAction,
                              );
                            }),
                          ),
                          SizedBox(height: 30.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: _isLoading ? null : _resendOtp,
                                child: const Text('Resend code'),
                              ),
                              FilledButton(
                                onPressed: _isLoading ? null : _verifyOtp,
                                child: _isLoading
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                  : const Text('Verify'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}