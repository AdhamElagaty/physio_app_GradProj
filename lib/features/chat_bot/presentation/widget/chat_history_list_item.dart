import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../core/presentation/widget/app_icon.dart';
import '../../../../core/presentation/widget/tile_list_item.dart';
import '../../../../core/utils/config/routes.dart';
import '../../../../core/utils/styles/app_colors.dart';
import '../../../../core/utils/styles/font.dart';
import '../../../../core/utils/styles/app_assets.dart';
import '../../domain/entities/chat.dart';
import '../cubit/chat_history/chat_history_cubit.dart';
import '../model/chat_screen_args.dart';

class ChatHistoryListItem extends StatelessWidget {
  final Chat chat;
  final int index;
  final int length;
  final bool isFirst;
  final bool isEnd;

  const ChatHistoryListItem({
    super.key,
    required this.chat,
    required this.index,
    required this.length,
    this.isFirst = false,
    this.isEnd = false,
  });

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
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty && newTitle != currentTitle) {
                Navigator.of(dialogContext).pop();

                final historyCubit = context.read<ChatHistoryCubit>();
                final success =
                    await historyCubit.updateChatTitle(chat.id, newTitle);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Chat renamed successfully.'
                          : 'Failed to rename chat.'),
                      backgroundColor: success ? AppColors.teal : AppColors.red,
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
            child: const Text('Cancel'),
          ),
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
                    backgroundColor: success ? AppColors.green : AppColors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatHistoryCubit = context.read<ChatHistoryCubit>();

    return TileListItem(
      index: index,
      length: length,
      icon: SizedBox(
        width: 36.w,
        height: 36.h,
        child: Center(
          child: Text(
            ' ${chat.title[0]} ',
            style: AppTextStyles.header.copyWith(color: AppColors.teal),
          ),
        ),
      ),
      title: chat.title,
      subTitle:
          'Updated: ${intl.DateFormat.yMd().add_jm().format(chat.updatedAt.toLocal())}',
      isFirst: isFirst,
      isEnd: isEnd,
      onTap: () {
        Navigator.pushNamed(context, Routes.chatBotChatScreen, arguments: ChatScreenArgs(chatId: chat.id, chatHistoryCubit: chatHistoryCubit));
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
              AppIcon(AppAssets.iconly.bulk.edit, size: 23.w),
              SizedBox(width: 8.w),
              Text('Rename', style: AppTextStyles.text),
            ]),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(children: [
              AppIcon(AppAssets.iconly.bulk.delete, size: 23.w, color: AppColors.red),
              SizedBox(width: 8.w),
              Text('Delete',
                  style: AppTextStyles.text.copyWith(color: AppColors.red)),
            ]),
          ),
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
