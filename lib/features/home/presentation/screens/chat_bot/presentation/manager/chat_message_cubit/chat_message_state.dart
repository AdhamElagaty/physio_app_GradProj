import 'package:equatable/equatable.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/data/models/ai_chat_message_model.dart';

class ChatMessagesLoadedData extends Equatable {
  final List<AiChatMessage> messages;
  final bool hasNextPage;
  final String? newChatId;
  final String? title; // ← تم تغيير الاسم من chatTitle إلى title

  const ChatMessagesLoadedData({
    this.messages = const [],
    this.hasNextPage = true,
    this.newChatId,
    this.title,
  });

  ChatMessagesLoadedData copyWith({
    List<AiChatMessage>? messages,
    bool? hasNextPage,
    String? newChatId,
    String? title,
  }) {
    return ChatMessagesLoadedData(
      messages: messages ?? this.messages,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      newChatId: newChatId ?? this.newChatId,
      title: title ?? this.title,
    );
  }

  @override
  List<Object?> get props => [messages, hasNextPage, newChatId, title];
}

abstract class ChatMessagesState extends Equatable {
  const ChatMessagesState();

  @override
  List<Object?> get props => [];
}

class ChatMessagesInitial extends ChatMessagesState {}

class ChatMessagesLoading extends ChatMessagesState {}

class ChatMessagesError extends ChatMessagesState {
  final String message;

  const ChatMessagesError(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatMessagesLoaded extends ChatMessagesState {
  final ChatMessagesLoadedData data;

  const ChatMessagesLoaded(this.data);

  @override
  List<Object?> get props => [data];
}
