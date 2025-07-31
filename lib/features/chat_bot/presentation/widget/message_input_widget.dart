import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/presentation/widget/app_icon.dart';
import '../../../../core/utils/styles/app_assets.dart';
import '../../../../core/utils/styles/app_colors.dart';
import '../cubit/chat_messages/chat_message_cubit.dart';

class MessageInputWidget extends StatefulWidget {
  const MessageInputWidget({super.key});

  @override
  State<MessageInputWidget> createState() => _MessageInputWidgetState();
}

class _MessageInputWidgetState extends State<MessageInputWidget> {
  final _messageController = TextEditingController();

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      context.read<ChatMessagesCubit>().sendMessage(message);
      _messageController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              SizedBox(width: 8.w),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(9),
                ),
                icon: AppIcon(AppAssets.iconly.bold.send, color: AppColors.white, size: 32.h),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
