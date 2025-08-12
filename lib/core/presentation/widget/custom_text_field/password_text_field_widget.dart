import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/styles/app_colors.dart';
import '../../../utils/styles/app_assets.dart';
import '../app_icon.dart';
import 'custom_text_field_widget.dart';

class PasswordTextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String hintText;
  final bool isPasswordVisible;
  final VoidCallback onVisibilityToggle;

  const PasswordTextFieldWidget({
    super.key,
    required this.controller,
    required this.validator,
    required this.hintText,
    required this.isPasswordVisible,
    required this.onVisibilityToggle,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextFieldWidget(
      controller: controller,
      hintText: hintText,
      validator: validator,
      obscureText: !isPasswordVisible,
      suffixIcon: Padding(
        padding: EdgeInsets.only(right: 5.0.w),
        child: IconButton(
          icon: AppIcon(
            color: AppColors.black50,
            size: 30,
            isPasswordVisible ? AppAssets.iconly.bulk.hide : AppAssets.iconly.bulk.show,
          ),
          onPressed: onVisibilityToggle,
        ),
      ),
    );
  }
}