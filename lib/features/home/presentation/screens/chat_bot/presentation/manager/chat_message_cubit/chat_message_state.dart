// lib/chat/cubits/chat_messages_cubit.dart
import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart'; // For DioException
import 'package:gradproject/features/auth/presentation/manager/login/login_bloc.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/data/models/ai_chat_message_model.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/data/repo/chat_repo_impl.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/presentation/manager/chat_history_cubit.dart/cubit/chat_history_cubit.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/presentation/manager/chat_history_cubit.dart/cubit/chat_history_state.dart';
import 'package:uuid/uuid.dart';
// Import ChatHistoryCubit

class ChatMessagesLoadedData extends Equatable {
  final List<AiChatMessage> messages;
  final bool hasNextPage;
  final String? newChatId;
  final String? chatTitle;

  const ChatMessagesLoadedData({
    this.messages = const [],
    this.hasNextPage = true,
    this.newChatId,
    this.chatTitle,
  });

  ChatMessagesLoadedData copyWith({
    List<AiChatMessage>? messages,
    bool? hasNextPage,
    String? newChatId,
    String? chatTitle,
  }) {
    return ChatMessagesLoadedData(
      messages: messages ?? this.messages,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      newChatId:
          newChatId ?? this.newChatId, // This should be null if not a new chat
      chatTitle: chatTitle ?? this.chatTitle,
    );
  }

  @override
  List<Object?> get props => [messages, hasNextPage, newChatId, chatTitle];
}

abstract class ChatMessagesState extends Equatable {
  const ChatMessagesState();
  @override
  List<Object> get props => [];
}

class ChatMessagesInitial extends ChatMessagesState {}

class ChatMessagesLoading extends ChatMessagesState {}

class ChatMessagesError extends ChatMessagesState {
  final String message;
  const ChatMessagesError(this.message);
  @override
  List<Object> get props => [message];
}

class ChatMessagesLoaded extends ChatMessagesState {
  final ChatMessagesLoadedData data;
  const ChatMessagesLoaded(this.data);
  @override
  List<Object> get props => [data];
}
