// lib/chat/ui/chat_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/font.dart';
import 'package:gradproject/core/utils/styles/icons.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/data/repo/chat_repo_impl.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/presentation/manager/chat_history_cubit.dart/cubit/chat_history_cubit.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/presentation/manager/chat_history_cubit.dart/cubit/chat_history_state.dart';

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
            body: Padding(
              padding: EdgeInsets.fromLTRB(22.w, 30.h, 22.w, 0.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 90.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI Chatbot', style: AppTextStyles.title),
                          Text('Chatbot chats history',
                              style: AppTextStyles.subTitle),
                        ],
                      ),
                      ElevatedButton(
                        child: AppIcon(
                          AppIcons.add,
                          size: 32,
                          color: AppColors.black,
                        ),
                        onPressed: () {
                          Navigator.of(innerContext).push(MaterialPageRoute(
                            builder: (_) => const ChatScreen(chatId: null),
                          ));
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 22.h),
                  SearchBar(
                    controller: searchController,
                    hintText: 'Search',
                    leading: AppIcon(AppIcons.search_bulk, size: 30.72.w),
                    onChanged: historyCubit.onSearchTermChanged,
                  ),
                  SizedBox(height: 20.h),
                  Flexible(
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
                              onRefresh: () async => historyCubit
                                  .fetchFirstPage(searchTerm: searchTerm),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 0.w, vertical: 0.h),
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(25.r),
                                ),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
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
                                    if (index >= state.chats.length) {
                                      return const SizedBox.shrink();
                                    }
                                    return ChatHistoryListItem(
                                      chat: state.chats[index],
                                      isFirst: index == 0,
                                      isEnd: index == state.chats.length - 1,
                                    );
                                  },
                                ),
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
            ),
          );
        },
      ),
    );
  }
}
