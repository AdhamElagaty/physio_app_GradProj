import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/font.dart';
import 'package:gradproject/core/utils/styles/icons.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/data/models/ai_chat_model.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/presentation/manager/chat_history_cubit.dart/cubit/chat_history_cubit.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/presentation/screen/chat_screen.dart';
import 'package:intl/intl.dart' as intl;

class ChatHistoryListItem extends StatelessWidget {
  final AiChat chat;
  const ChatHistoryListItem({super.key, required this.chat});

  void _showRenameDialog(BuildContext context, String currentTitle) {
    final controller = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename Chat'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter new title'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty && newTitle != currentTitle) {
                Navigator.of(dialogContext).pop();

                final historyCubit = context.read<ChatHistoryCubit>();
                final success =
                    await historyCubit.updateChatTitle(chat.id, newTitle);

                if (success) {
                  await historyCubit.fetchFirstPage(); //  refresh list
                }

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Chat renamed successfully.'
                          : 'Failed to rename chat.'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Chat?'),
        content: const Text('This will permanently delete the chat history.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final success =
                  await context.read<ChatHistoryCubit>().deleteChat(chat.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        success ? 'Chat deleted.' : 'Failed to delete chat.'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: AppIcon(AppIcons.chat),
      title: Text(chat.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
          'Updated: ${intl.DateFormat.yMd().add_jm().format(chat.updatedAt.toLocal())}'),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ChatScreen(chatId: chat.id)),
        );
      },
      trailing: PopupMenuButton(
        elevation: 0,
        color: AppColors.white,
        borderRadius: BorderRadius.circular(5.r),
        icon: const Icon(Icons.more_vert),
        itemBuilder: (_) => [
          PopupMenuItem(
              value: 'rename',
              child: Row(children: [
                AppIcon(AppIcons.edit, size: 23.w),
                SizedBox(width: 8.w),
                Text(
                  'Rename',
                  style: AppTextStyles.text,
                )
              ])),
          PopupMenuItem(
              value: 'delete',
              child: Row(children: [
                AppIcon(AppIcons.delete, size: 23.w, color: AppColors.red),
                SizedBox(width: 8.w),
                Text(
                  'Delete',
                  style: AppTextStyles.text.copyWith(color: AppColors.red),
                )
              ])),
        ],
        onSelected: (value) {
          if (value == 'rename') {
            _showRenameDialog(context, chat.title);
          } else if (value == 'delete') {
            _showDeleteConfirmation(context);
          }
        },
      ),
    );
  }
}
