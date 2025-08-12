part of 'chat_message_cubit.dart';

enum ChatMessagesStatus { initial, loading, loaded, error }

class ChatMessagesState extends Equatable {
  final ChatMessagesStatus status;
  final List<ChatMessage> messages;
  final bool hasNextPage;
  final String? title;
  final String? newChatId;
  final String? errorMessage;

  const ChatMessagesState({
    this.status = ChatMessagesStatus.initial,
    this.messages = const [],
    this.hasNextPage = true,
    this.title,
    this.newChatId,
    this.errorMessage,
  });

  ChatMessagesState copyWith({
    ChatMessagesStatus? status,
    List<ChatMessage>? messages,
    bool? hasNextPage,
    String? title,
    String? newChatId,
    String? errorMessage,
  }) {
    return ChatMessagesState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      title: title ?? this.title,
      newChatId: newChatId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, messages, hasNextPage, title, newChatId, errorMessage];
}
