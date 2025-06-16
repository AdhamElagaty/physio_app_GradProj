// lib/chat/ui/chat_screen.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/font.dart';
import 'package:gradproject/core/utils/styles/icons.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/data/repo/chat_repo_impl.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/presentation/manager/chat_history_cubit.dart/cubit/chat_history_cubit.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/presentation/manager/chat_message_cubit/chat_message_cubit.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/presentation/manager/chat_message_cubit/chat_message_state.dart';
import 'message_bubble.dart';

class ChatScreen extends StatelessWidget {
  final String? chatId;
  const ChatScreen({super.key, this.chatId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatMessagesCubit(
        repository: context.read<ChatRepository>(),
        chatHistoryCubit: context.read<ChatHistoryCubit>(),
        chatId: chatId,
      ),
      child: ChatView(initialChatId: chatId),
    );
  }
}

class ChatView extends StatelessWidget {
  final String? initialChatId;
  const ChatView({super.key, this.initialChatId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(22.w, 30.h, 22.w, 0.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 34.h),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: AppIcon(AppIcons.arrow_left_bulk, size: 33.33.w),
                    ),
                    SizedBox(height: 10.h),
                    BlocBuilder<ChatMessagesCubit, ChatMessagesState>(
                      builder: (context, state) {
                        if (state is ChatMessagesLoaded &&
                            state.data.title != null) {
                          return Text(
                            state.data.title!,
                            style: AppTextStyles.title,
                          );
                        }
                        return Text(
                          initialChatId != null ? 'Loading...' : 'New Chat',
                          style: AppTextStyles.title,
                        );
                      },
                    ),
                    Text('Ask about anything', style: AppTextStyles.subTitle),
                  ],
                ),
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(),
                    Positioned(
                      top: -150.h,
                      right: -100.w,
                      child: Image.asset(
                        'assets/images/AI_blur_effect.png',
                        width: 350.w,
                        height: 350.h,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 22.h),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.extentAfter < 200) {
                    context.read<ChatMessagesCubit>().fetchNextPage();
                  }
                  return false;
                },
                child: BlocBuilder<ChatMessagesCubit, ChatMessagesState>(
                  builder: (context, state) {
                    if (state is ChatMessagesLoading &&
                        state is! ChatMessagesLoaded) {
                      // Added condition to allow showing current messages while loading next page
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is ChatMessagesError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('An error occurred:\n${state.message}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red)),
                        ),
                      );
                    }
                    if (state is ChatMessagesLoaded) {
                      final data = state.data;
                      if (data.messages.isEmpty && !data.hasNextPage) {
                        // If no messages and no more to load
                        return Center(
                            child: Text("Ask me anything!",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(color: Colors.grey)));
                      }
                      return ListView.builder(
                        physics: BouncingScrollPhysics(),
                        reverse: true,
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        itemCount:
                            data.messages.length + (data.hasNextPage ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (data.hasNextPage &&
                              index == data.messages.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return MessageBubble(message: data.messages[index]);
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            if (context.watch<ChatMessagesCubit>().state is! ChatMessagesError)
              _MessageInput(),
          ],
        ),
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final messageController = TextEditingController();

    void sendMessage() {
      final message = messageController.text.trim();
      if (message.isNotEmpty) {
        context.read<ChatMessagesCubit>().sendMessage(message);
        messageController.clear();
        FocusScope.of(context).unfocus();
      }
    }

    return SafeArea(
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                  onSubmitted: (_) => sendMessage(),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              SizedBox(width: 8.w),
              ConstrainedBox(
                constraints: BoxConstraints.tight(Size(45, 45)),
                child: IconButton(
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: AppColors.teal,
                  ),
                  padding: EdgeInsets.zero,
                  icon: AppIcon(
                    AppIcons.send,
                    color: AppColors.white,
                    size: 30.w,
                  ),
                  onPressed: sendMessage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
