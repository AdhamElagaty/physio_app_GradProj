import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'otp_field_box.dart';

class OtpField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onCompleted;
  final bool isSuccess;
  final bool isError;
  final bool isLoading;

  const OtpField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onCompleted,
    this.isSuccess = false,
    this.isError = false,
    this.isLoading = false,
  });

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  bool _isPasting = false;
  bool _isRemoving = false;
  String _previousValue = '';

  void _handlePaste() {
    setState(() => _isPasting = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _isPasting = false);
    });
  }

  void _handleRemove() {
    setState(() => _isRemoving = true);
    // Reset removing animation state.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isRemoving = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!widget.isSuccess && !widget.isLoading) {
          FocusScope.of(context).requestFocus(widget.focusNode);
        }
      },
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: 60.0,
            child: TextFormField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              keyboardType: TextInputType.number,
              enabled: !widget.isLoading && !widget.isSuccess && !widget.isError,
              inputFormatters: [
                OtpPasteFormatter(onPaste: _handlePaste),
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              showCursor: false,
              enableInteractiveSelection: false,
              style: const TextStyle(color: Colors.transparent, height: 0, fontSize: 0),
              cursorColor: Colors.transparent,
              decoration: const InputDecoration(
                fillColor: Colors.transparent,
                filled: true,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                counterText: "",
              ),
              onChanged: (value) {
                // Handle remove animation trigger
                if (value.length < _previousValue.length && !_isPasting) {
                  _handleRemove();
                }
                _previousValue = value;
                
                // When 6 digits are entered, notify the parent. That's it.
                if (value.length == 6) {
                  widget.onCompleted(value);
                }
              },
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller,
            builder: (context, value, child) {
              final text = value.text;
              return IgnorePointer(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return OtpFieldBox(
                      text: index < text.length ? text[index] : '',
                      isFocused: text.length == index && widget.focusNode.hasFocus && !widget.isLoading,
                      isPasting: _isPasting,
                      isRemoving: _isRemoving && index == text.length,
                      // Pass state directly to the box for animation.
                      isSuccess: widget.isSuccess,
                      isError: widget.isError,
                      index: index,
                    );
                  }),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class OtpPasteFormatter extends TextInputFormatter {
  final VoidCallback? onPaste;

  OtpPasteFormatter({this.onPaste});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length - oldValue.text.length > 1) {
      final pastedText = newValue.text.substring(
        oldValue.selection.start,
        newValue.selection.end,
      );

      final is6Digits = RegExp(r'^\d{6}$').hasMatch(pastedText);

      if (is6Digits) {
        onPaste?.call();
        return TextEditingValue(
          text: pastedText,
          selection: TextSelection.collapsed(offset: pastedText.length),
        );
      } else {
        return oldValue;
      }
    }
    return newValue;
  }
}