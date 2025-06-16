// lib/chat/ui/message_bubble.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/font.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/data/models/ai_chat_message_model.dart';
import 'package:intl/intl.dart' as intl;

// Import AiChatMessage

TextDirection _getTextDirection(String text) {
  if (text.isEmpty) return TextDirection.rtl;
  final firstChar = text.trimLeft().characters.first;
  final isRtl = intl.Bidi.hasAnyRtl(firstChar);
  return isRtl ? TextDirection.rtl : TextDirection.ltr;
}

class MessageBubble extends StatelessWidget {
  final AiChatMessage message;
  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final theme = Theme.of(context);
    final textDirection = _getTextDirection(message.content);

    final markdownStyleSheet = MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: AppTextStyles.message.copyWith(
        color: isUser
            ? AppColors.teal
            : AppColors.black, // Adjusted for user messages
      ),
      code: theme.textTheme.bodyMedium?.copyWith(
        fontFamily: 'monospace',
        backgroundColor: theme.colorScheme.onSurfaceVariant.withOpacity(0.1),
        color: isUser
            ? AppColors.teal
            : theme.colorScheme.onSurfaceVariant, // Adjusted for user messages
      ),
      codeblockDecoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      listBullet: AppTextStyles.message.copyWith(
        color: isUser
            ? AppColors.teal
            : theme.colorScheme.onSurfaceVariant, // Adjusted for user messages
      ),
      tableBorder: TableBorder.all(color: theme.dividerColor),
      tableHead: theme.textTheme.titleSmall?.copyWith(
        color: isUser
            ? AppColors.teal
            : theme.colorScheme.onSurfaceVariant, // Adjusted for user messages
        fontWeight: FontWeight.bold,
      ),
    );

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
            color: isUser ? AppColors.teal.withAlpha(40) : AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: isUser ? Radius.circular(30.r) : Radius.circular(5),
              topRight: isUser ? Radius.circular(5.r) : Radius.circular(30.r),
              bottomLeft: Radius.circular(30.r),
              bottomRight: Radius.circular(30.r),
            )),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.all(15.w),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.isPending)
              SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          isUser ? Colors.white : theme.primaryColor)))
            else if (isUser)
              Text(
                message.content,
                style: AppTextStyles.message,
                textDirection: textDirection,
              )
            else
              Directionality(
                textDirection: textDirection,
                child: MarkdownBody(
                  data: message.content,
                  selectable: true,
                  styleSheet: markdownStyleSheet,
                ),
              ),
            if (message.isError)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error, color: Colors.red[200], size: 16),
                    const SizedBox(width: 4),
                    Text("Failed to send",
                        style: TextStyle(color: Colors.red[200], fontSize: 12)),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
