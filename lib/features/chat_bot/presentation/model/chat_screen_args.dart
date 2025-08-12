import '../cubit/chat_history/chat_history_cubit.dart';

class ChatScreenArgs {
  final String? chatId;
  final ChatHistoryCubit chatHistoryCubit;

  ChatScreenArgs({required this.chatId, required this.chatHistoryCubit});
}