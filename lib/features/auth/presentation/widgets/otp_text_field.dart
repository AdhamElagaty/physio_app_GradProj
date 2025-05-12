import 'package:flutter/material.dart';
import 'package:gradproject/core/utils/styles/font.dart';

class OtpTextField extends StatelessWidget {
  const OtpTextField(
      {super.key,
      required this.controllers,
      required this.index,
      required this.onChanged,
      this.isLast = false});
  final List<TextEditingController> controllers;
  final int index;
  final bool isLast;
  final void Function({required String value, required int index}) onChanged;
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: TextFormField(
          keyboardType: TextInputType.number,
          onTap: () {
            if (controllers[index].text.isNotEmpty) {
              controllers[index].selection =
                  TextSelection(baseOffset: 0, extentOffset: 1);
            }
          },
          style: AppTextStyles.header,
          controller: controllers[index],
          textAlign: TextAlign.center,
          textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
          onChanged: (value) {
            onChanged(value: value, index: index);
          }),
    );
  }
}
