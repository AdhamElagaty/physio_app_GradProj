import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/presentation/cubit/app_cubit/app_manager_cubit.dart';
import '../../../../core/presentation/widget/custom_logo_transparent_progress_indicator_widget.dart';
import '../../../../core/presentation/widget/title_bar_widget.dart';
import '../../../../core/utils/styles/app_assets.dart';
import '../cubit/chat_messages/chat_message_cubit.dart';
import '../widget/message_bubble.dart';
import '../widget/message_input_widget.dart';

class ChatScreen extends StatelessWidget {
  final String? chatId;
  const ChatScreen({super.key, this.chatId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(22.w, 30.h, 22.w, 0.h),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BlocBuilder<ChatMessagesCubit, ChatMessagesState>(
                        buildWhen: (prev, curr) => prev.title != curr.title,
                        builder: (context, state) {
                          return BlocBuilder<AppManagerCubit, AppManagerState>(
                            buildWhen: (prev, curr) =>
                                prev.connectivityStatus !=
                                curr.connectivityStatus,
                            builder: (appManagerContext, appManagerState) {
                              return TitleBarWidget(
                                title: state.title ??
                                    (chatId != null
                                        ? 'Loading...'
                                        : 'New Chat'),
                                subtitle: 'Ask about anything',
                                spaceBetweenTitles: 8,
                                heroTag: appManagerState.connectivityStatus ==
                                        ConnectivityStatus.online
                                    ? 'chat_title_bar'
                                    : "no_internet_title_bar",
                                isHeroEnabled: true,
                                isReturnButtonEnabled: true,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
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
                        AppAssets.patternAndEffect.blurEffectTopRight,
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
                    if (state.status == ChatMessagesStatus.error) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'An error occurred:\n${state.errorMessage}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    }

                    if (state.status == ChatMessagesStatus.loading &&
                        state.messages.isEmpty) {
                      return const Center(
                        child: SizedBox(
                          width: 250,
                          height: 250,
                          child: CustomLogoTransparentProgressIndicatorWidget(),
                        ),
                      );
                    }

                    if (state.messages.isEmpty) {
                      return Center(
                        child: Text(
                          "Ask me anything!",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      reverse: true,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      itemCount:
                          state.messages.length + (state.hasNextPage ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == state.messages.length) {
                          return state.hasNextPage
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: SizedBox(
                                      width: 150,
                                      height: 150,
                                      child:
                                          CustomLogoTransparentProgressIndicatorWidget(),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink();
                        }
                        return MessageBubble(message: state.messages[index]);
                      },
                    );
                  },
                ),
              ),
            ),
            if (context.watch<ChatMessagesCubit>().state.status !=
                ChatMessagesStatus.error)
              const MessageInputWidget(),
          ],
        ),
      ),
    );
  }
}
