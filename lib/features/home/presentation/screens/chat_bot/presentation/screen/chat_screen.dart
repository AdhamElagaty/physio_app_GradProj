// lib/chat/ui/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradproject/features/auth/presentation/manager/login/login_bloc.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/data/repo/chat_repo_impl.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/presentation/manager/chat_history_cubit.dart/cubit/chat_history_cubit.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/presentation/manager/chat_message_cubit/chat_message_cubit.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/presentation/manager/chat_message_cubit/chat_message_state.dart';
import 'package:intl/intl.dart' as intl; // For _getTextDirection
import 'package:flutter_markdown/flutter_markdown.dart'; // For MarkdownBody

import 'message_bubble.dart'; // Import MessageBubble

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
      appBar: AppBar(
        title: BlocBuilder<ChatMessagesCubit, ChatMessagesState>(
          builder: (context, state) {
            if (state is ChatMessagesLoaded && state.data.title != null) {
              return Text(state.data.title!);
            }
            return Text(initialChatId != null ? 'Loading...' : 'New Chat');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceVariant
                        .withOpacity(0.5),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                  onSubmitted: (_) => sendMessage(),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.all(12),
                ),
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: sendMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
