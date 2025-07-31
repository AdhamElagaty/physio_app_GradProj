part of 'chat_history_cubit.dart';

enum ChatHistoryStatus { initial, loading, loadingMore, loaded, error }

class ChatHistoryState extends Equatable {
  final ChatHistoryStatus status;
  final List<Chat> chats;
  final bool hasNextPage;
  final String? errorMessage;

  const ChatHistoryState({
    this.status = ChatHistoryStatus.initial,
    this.chats = const [],
    this.hasNextPage = true,
    this.errorMessage,
  });

  ChatHistoryState copyWith({
    ChatHistoryStatus? status,
    List<Chat>? chats,
    bool? hasNextPage,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ChatHistoryState(
      status: status ?? this.status,
      chats: chats ?? this.chats,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, chats, hasNextPage, errorMessage];
}
