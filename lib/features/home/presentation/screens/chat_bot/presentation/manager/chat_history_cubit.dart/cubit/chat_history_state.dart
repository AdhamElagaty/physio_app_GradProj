import 'package:equatable/equatable.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/data/models/ai_chat_model.dart';

// Ensure this is imported

abstract class ChatHistoryState extends Equatable {
  const ChatHistoryState();
  @override
  List<Object> get props => [];
}

class ChatHistoryInitial extends ChatHistoryState {}

class ChatHistoryLoading extends ChatHistoryState {}

class ChatHistoryError extends ChatHistoryState {
  final String message;
  const ChatHistoryError(this.message);
  @override
  List<Object> get props => [message];
}

class ChatHistoryLoaded extends ChatHistoryState {
  final List<AiChat> chats;
  final bool hasNextPage;

  const ChatHistoryLoaded(this.chats, this.hasNextPage);

  @override
  List<Object> get props => [chats, hasNextPage];
}
