// lib/chat/cubits/chat_history_cubit.dart
import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:gradproject/features/auth/presentation/manager/login/login_bloc.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/data/models/ai_chat_model.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/data/repo/chat_repo_impl.dart'; // For DioException

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
