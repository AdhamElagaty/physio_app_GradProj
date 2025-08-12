import 'package:flutter/material.dart';

import 'custom_text_field_widget.dart';


class EmailTextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?) validator;
  final String hintText;

  const EmailTextFieldWidget({
    super.key,
    required this.controller,
    required this.validator,
    this.hintText = 'Email',
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextFieldWidget(
      controller: controller,
      hintText: hintText,
      validator: validator,
      keyboardType: TextInputType.emailAddress,
    );
  }
}