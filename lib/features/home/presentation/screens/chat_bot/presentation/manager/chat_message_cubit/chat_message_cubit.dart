import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradproject/features/auth/presentation/manager/login/login_bloc.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/data/models/ai_chat_message_model.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/data/repo/chat_repo_impl.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/presentation/manager/chat_history_cubit.dart/cubit/chat_history_cubit.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/presentation/manager/chat_history_cubit.dart/cubit/chat_history_state.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/presentation/manager/chat_message_cubit/chat_message_state.dart';
import 'package:uuid/uuid.dart';

class ChatMessagesCubit extends Cubit<ChatMessagesState> {
  final ChatRepository _repository;

  final ChatHistoryCubit _chatHistoryCubit;
  String? _chatId;
  int _page = 1;
  bool _isLoading = false;
  final Uuid _uuid = const Uuid();
  StreamSubscription? _chatHistorySubscription;

  ChatMessagesCubit({
    required ChatRepository repository,
    required ChatHistoryCubit chatHistoryCubit,
    required String? chatId,
  })  : _repository = repository,
        _chatHistoryCubit = chatHistoryCubit,
        _chatId = chatId,
        super(ChatMessagesInitial()) {
    _listenForChatUpdates();

    if (_chatId != null) {
      fetchFirstPage();
    } else {
      emit(
          const ChatMessagesLoaded(ChatMessagesLoadedData(hasNextPage: false)));
    }
  }

  void _listenForChatUpdates() {
    _chatHistorySubscription = _chatHistoryCubit.stream.listen((historyState) {
      if (state is ChatMessagesLoaded && historyState is ChatHistoryLoaded) {
        final currentData = (state as ChatMessagesLoaded).data;

        if (_chatId == null || currentData.chatTitle == null) return;

        try {
          final updatedChatInHistory =
              historyState.chats.firstWhere((chat) => chat.id == _chatId);

          if (updatedChatInHistory.title != currentData.chatTitle) {
            emit(ChatMessagesLoaded(
                currentData.copyWith(chatTitle: updatedChatInHistory.title)));
          }
        } catch (e) {
          // Chat not found in history, perhaps it was deleted or a new chat
          // No action needed for this scenario in this context as per original code.
        }
      }
    });
  }

  @override
  Future<void> close() {
    _chatHistorySubscription?.cancel();
    return super.close();
  }

  Future<void> fetchFirstPage() async {
    if (_chatId == null) return;
    _page = 1;
    emit(ChatMessagesLoading());
    await _fetchMessages();
  }

  Future<void> fetchNextPage() async {
    if (_isLoading ||
        _chatId == null ||
        (state is! ChatMessagesLoaded) ||
        !((state as ChatMessagesLoaded).data.hasNextPage)) {
      return;
    }
    _isLoading = true;
    _page++;
    await _fetchMessages();
    _isLoading = false;
  }

  Future<void> _fetchMessages() async {
    // if (_authCubit.state is AuthSessionExpired) {
    //   emit(const ChatMessagesError("Session expired."));
    //   return;
    // }
    try {
      final response =
          await _repository.getChatMessages(_chatId!, pageIndex: _page);

      List<AiChatMessage> currentMessages = [];
      if (state is ChatMessagesLoaded && _page > 1) {
        currentMessages = (state as ChatMessagesLoaded).data.messages;
      }

      final newMessages = [...response.messages, ...currentMessages];

      emit(ChatMessagesLoaded(ChatMessagesLoadedData(
        messages: newMessages,
        hasNextPage: response.hasNextPage,
        chatTitle: response.chatTitle,
      )));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        if (_page == 1) {
          emit(const ChatMessagesError("Chat not found."));
        } else {
          if (state is ChatMessagesLoaded) {
            emit(ChatMessagesLoaded((state as ChatMessagesLoaded)
                .data
                .copyWith(hasNextPage: false)));
          }
        }
      } else if (e.response?.statusCode != 401) {
        emit(ChatMessagesError(e.message ?? 'An unknown error occurred'));
      }
    } catch (e) {
      emit(ChatMessagesError(e.toString()));
    }
  }

  Future<void> sendMessage(String messageContent) async {
    if (state is! ChatMessagesLoaded) return;
    final currentState = state as ChatMessagesLoaded;

    final userMessageId = _uuid.v4();
    final userMessage = AiChatMessage(
        id: userMessageId,
        content: messageContent,
        role: MessageRole.user,
        timestamp: DateTime.now());
    final pendingAiMessage = AiChatMessage(
        id: _uuid.v4(),
        content: "...",
        role: MessageRole.model,
        timestamp: DateTime.now(),
        isPending: true);

    emit(ChatMessagesLoaded(currentState.data.copyWith(
      messages: [pendingAiMessage, userMessage, ...currentState.data.messages],
    )));

    try {
      final response = await _repository.sendMessage(
          chatId: _chatId, messageContent: messageContent);

      final aiMessage = AiChatMessage(
          id: _uuid.v4(),
          content: response.aiMessageResult,
          role: MessageRole.model,
          timestamp: response.messageTime);

      bool wasNewChat = _chatId == null;
      if (wasNewChat) {
        _chatId = response.chatId;
      }

      final optimisticMessages = (state as ChatMessagesLoaded).data.messages;

      // Find and remove the pending AI message and replace the user message (if error was shown)
      // then insert the actual AI response.
      final List<AiChatMessage> updatedMessages = [];
      bool userMessageHandled = false;
      bool pendingAiRemoved = false;

      for (var msg in optimisticMessages) {
        if (msg.id == userMessageId) {
          // updatedMessages.add(userMessage.copyWith(isError: false)); // Ensure error is reset
          userMessageHandled = true;
        } else if (msg.isPending && !pendingAiRemoved) {
          pendingAiRemoved = true; // Skip the pending AI message
        } else {
          updatedMessages.add(msg);
        }
      }

      // Add the actual AI message if it wasn't already added (e.g., first message)
      updatedMessages.insert(0, aiMessage);

      emit(ChatMessagesLoaded(currentState.data.copyWith(
        messages: updatedMessages,
        newChatId: wasNewChat ? _chatId : null,
        chatTitle: response.chatTitle,
      )));

      _chatHistoryCubit.refreshList();
    } catch (e) {
      debugPrint("Error sending message: $e");
      final errorUserMessage = AiChatMessage(
          id: userMessageId,
          content: messageContent,
          role: MessageRole.user,
          timestamp: userMessage.timestamp,
          isError: true);
      final messages = (state as ChatMessagesLoaded).data.messages;

      // Replace the original user message with an error state, and remove pending AI message
      final List<AiChatMessage> messagesAfterError = [];
      bool pendingAiRemoved = false;
      for (var msg in messages) {
        if (msg.id == userMessageId) {
          messagesAfterError.add(errorUserMessage);
        } else if (msg.isPending && !pendingAiRemoved) {
          pendingAiRemoved = true; // Skip the pending AI message
        } else {
          messagesAfterError.add(msg);
        }
      }

      emit(ChatMessagesLoaded(currentState.data.copyWith(
        messages: messagesAfterError,
      )));
    }
  }

  // Method to set chat ID externally, useful when a new chat is created
  void setChatId(String newId) {
    _chatId = newId;
    // Optionally refresh messages if needed after ID is set (e.g., after initial message sent)
    // fetchFirstPage();
  }
}
