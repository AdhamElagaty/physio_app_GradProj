import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/presentation/cubit/app_cubit/app_manager_cubit.dart';
import '../../../../core/presentation/widget/app_icon.dart';
import '../../../../core/presentation/widget/custom_logo_transparent_progress_indicator_widget.dart';
import '../../../../core/presentation/widget/title_bar_widget.dart';
import '../../../../core/utils/config/routes.dart';
import '../../../../core/utils/styles/app_colors.dart';
import '../../../../core/utils/styles/app_assets.dart';
import '../cubit/chat_history/chat_history_cubit.dart';
import '../model/chat_screen_args.dart';
import '../widget/chat_history_list_item.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyCubit = context.read<ChatHistoryCubit>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 26.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleBarWidget(
            title: 'Chat History',
            subtitle: 'Chatbot chats history',
            onActionButtonPressed: () {
              Navigator.pushNamed(
                context,
                Routes.chatBotChatScreen,
                arguments: ChatScreenArgs(
                  chatId: null,
                  chatHistoryCubit: historyCubit,
                ),
              );
            },
            actionButtonIconSvgAsset: AppAssets.iconly.bulk.plus,
            heroTag: 'chat_title_bar',
            isHeroEnabled: true,
          ),
          SizedBox(height: 30.h),
          SearchBar(
            hintText: 'Search',
            leading: AppIcon(AppAssets.iconly.bulk.search, size: 30.72.w),
            onChanged: (term) => historyCubit.onSearchTermChanged(term),
          ),
          SizedBox(height: 20.h),
          BlocListener<AppManagerCubit, AppManagerState>(
            listenWhen: (previous, current) =>
                previous.connectivityStatus != current.connectivityStatus,
            listener: (appManagerContext, appManagerState) {
              if (appManagerState.connectivityStatus == ConnectivityStatus.online && context.read<ChatHistoryCubit>().state.status == ChatHistoryStatus.error && context.read<ChatHistoryCubit>().state.chats.isEmpty) {
                historyCubit.refreshList();
              }
            },
            child: Expanded(
              child: RefreshIndicator(
                onRefresh: () async => historyCubit.refreshList(),
                child: BlocListener<ChatHistoryCubit, ChatHistoryState>(
                  listener: (context, state) {
                    if (state.errorMessage != null &&
                        state.status == ChatHistoryStatus.loaded) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                          content: Text(state.errorMessage!),
                          backgroundColor: AppColors.red,
                        ));
                    }
                  },
                  child: BlocBuilder<ChatHistoryCubit, ChatHistoryState>(
                    builder: (context, state) {
                      if (state.status == ChatHistoryStatus.loading &&
                          state.chats.isEmpty) {
                        return const Center(
                          child: SizedBox(
                            width: 250,
                            height: 250,
                            child:
                                CustomLogoTransparentProgressIndicatorWidget(),
                          ),
                        );
                      }

                      if (state.status == ChatHistoryStatus.error &&
                          state.chats.isEmpty) {
                        return _buildScrollableMessage(context,
                            'An error occurred:\n${state.errorMessage}');
                      }

                      if (state.chats.isEmpty) {
                        final message =
                            historyCubit.currentSearchTerm?.isEmpty ?? true
                                ? 'No chats found. Start a new one!'
                                : 'No chats match your search.';
                        return _buildScrollableMessage(context, message);
                      }
                      return Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.r),
                          border: Border.all(color: Colors.transparent),
                        ),
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: state.chats.length +
                              (state.status == ChatHistoryStatus.loadingMore
                                  ? 1
                                  : 0),
                          itemBuilder: (context, index) {
                            if (index >= state.chats.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: SizedBox(
                                      width: 120,
                                      height: 120,
                                      child:
                                          CustomLogoTransparentProgressIndicatorWidget()),
                                ),
                              );
                            }

                            if (index == state.chats.length - 1 &&
                                state.hasNextPage) {
                              historyCubit.fetchNextPage();
                            }

                            return ChatHistoryListItem(
                              index: index,
                              length: state.chats.length,
                              chat: state.chats[index],
                              isFirst: index == 0,
                              isEnd: index == state.chats.length - 1 &&
                                  state.status != ChatHistoryStatus.loadingMore,
                            );
                          },
                        ),
                      );
                      // MODIFICATION END
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableMessage(BuildContext context, String message) {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.grey),
              ),
            ),
          ),
        ),
      );
    });
  }
}
