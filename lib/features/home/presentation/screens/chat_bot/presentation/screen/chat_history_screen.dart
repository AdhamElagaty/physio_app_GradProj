// lib/chat/ui/chat_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/icons.dart';
import 'package:gradproject/features/auth/presentation/manager/login/login_bloc.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/data/repo/chat_repo_impl.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/presentation/manager/chat_history_cubit.dart/cubit/chat_history_cubit.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/presentation/manager/chat_history_cubit.dart/cubit/chat_history_state.dart';
import 'package:intl/intl.dart' as intl;

import 'chat_history_list_item.dart';
import 'chat_screen.dart';
// ولازم تستورد ChatRepository

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ChatHistoryCubit(context.read<ChatRepository>())..fetchFirstPage(),
      child: Builder(
        builder: (innerContext) {
          final historyCubit = innerContext.read<ChatHistoryCubit>();

          final searchTerm = innerContext
              .select((ChatHistoryCubit c) => c.currentSearchTerm ?? '');
          final searchController = TextEditingController(text: searchTerm);
          searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: searchController.text.length),
          );

          return Scaffold(
            appBar: AppBar(
              title: const Text('AI Chat History'),
              
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: AppIcon(
                      AppIcons.add,
                      size: 32,
                      color: AppColors.teal,
                    ),
                    tooltip: 'New Chat',
                    onPressed: () {
                      Navigator.of(innerContext).push(MaterialPageRoute(
                        builder: (_) => const ChatScreen(chatId: null),
                      ));
                    },
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by title...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchTerm.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                historyCubit.onSearchTermChanged('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(innerContext)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.5),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: historyCubit.onSearchTermChanged,
                  ),
                ),
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.pixels >=
                          notification.metrics.maxScrollExtent - 200) {
                        historyCubit.fetchNextPage();
                      }
                      return false;
                    },
                    child: BlocBuilder<ChatHistoryCubit, ChatHistoryState>(
                      builder: (context, state) {
                        // هنا الـ context هو الـ innerContext اللي فيه ChatHistoryCubit
                        if (state is ChatHistoryLoading &&
                            state is! ChatHistoryLoaded) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (state is ChatHistoryError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                  'An error occurred:\n${state.message}',
                                  textAlign: TextAlign.center),
                            ),
                          );
                        }
                        if (state is ChatHistoryLoaded) {
                          if (state.chats.isEmpty) {
                            return Center(
                              child: Text(
                                searchTerm.isEmpty
                                    ? 'No chats found. Start a new one!'
                                    : 'No chats match your search.',
                                style: Theme.of(innerContext)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: Colors.grey),
                              ),
                            );
                          }
                          return RefreshIndicator(
                            onRefresh: () async => historyCubit.fetchFirstPage(
                                searchTerm: searchTerm),
                            child: ListView.builder(
                              itemCount: state.chats.length +
                                  (state.hasNextPage ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == state.chats.length &&
                                    state.hasNextPage) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  );
                                }
                                if (index >= state.chats.length)
                                  return const SizedBox.shrink();

                                return ChatHistoryListItem(
                                    chat: state.chats[index]);
                              },
                            ),
                          );
                        }
                        return const Center(
                            child: Text("Start a search or refresh."));
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
