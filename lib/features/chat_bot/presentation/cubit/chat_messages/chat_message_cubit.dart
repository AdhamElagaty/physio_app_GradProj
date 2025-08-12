import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/error/error_handler_service.dart';
import '../../../../../core/error/failure.dart';
import '../../../domain/entities/chat.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/entities/message_role.dart';
import '../../../domain/usecases/get_chat_messages/get_chat_messages_params.dart';
import '../../../domain/usecases/get_chat_messages/get_chat_messages_usecase.dart';
import '../../../domain/usecases/send_message/send_message_params.dart';
import '../../../domain/usecases/send_message/send_message_usecase.dart';
import '../chat_history/chat_history_cubit.dart';

part 'chat_message_state.dart';

class ChatMessagesCubit extends Cubit<ChatMessagesState> {
  final GetChatMessagesUseCase _getMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final ErrorHandlerService _errorHandler;
  late ChatHistoryCubit _chatHistoryCubit;

  String? _chatId;
  int _page = 1;
  final Uuid _uuid = const Uuid();

  bool _isFetchingNextPage = false;

  ChatMessagesCubit({
    required GetChatMessagesUseCase getMessagesUseCase,
    required SendMessageUseCase sendMessageUseCase,
    required ErrorHandlerService errorHandler,
  })  : _getMessagesUseCase = getMessagesUseCase,
        _sendMessageUseCase = sendMessageUseCase,
        _errorHandler = errorHandler,
        super(const ChatMessagesState());

  Future<void> initialize(
      String? chatId, ChatHistoryCubit chatHistoryCubit) async {
    _chatId = chatId;
    _chatHistoryCubit = chatHistoryCubit;
    if (_chatId != null) {
      emit(state.copyWith(status: ChatMessagesStatus.loading));
      await fetchFirstPage();
    } else {
      emit(const ChatMessagesState(
          status: ChatMessagesStatus.initial, hasNextPage: false));
    }
  }

  Future<void> fetchFirstPage() async {
    if (_chatId == null) return;
    _page = 1;
    _isFetchingNextPage = false;
    emit(state.copyWith(
        status: ChatMessagesStatus.loading, messages: [], hasNextPage: true));
    await _fetchMessages();
  }

  Future<void> fetchNextPage() async {
    if (_isFetchingNextPage || !state.hasNextPage || _chatId == null) return;

    _isFetchingNextPage = true;
    _page++;
    await _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    final result = await _getMessagesUseCase(
      GetChatMessagesParams(chatId: _chatId!, pageIndex: _page),
    );

    result.fold(
      (failure) {
        if (failure is NotFoundFailure && _page > 1) {
          emit(state.copyWith(hasNextPage: false));
        } else {
          final friendlyMessage = _errorHandler.getMessageFromFailure(failure);
          emit(state.copyWith(
              status: ChatMessagesStatus.error, errorMessage: friendlyMessage));
        }
      },
      (paginatedResult) {
        final currentMessages = _page > 1 ? state.messages : <ChatMessage>[];

        final newMessages = [...currentMessages, ...paginatedResult.items];

        if (isClosed) return;

        emit(state.copyWith(
          status: ChatMessagesStatus.loaded,
          messages: newMessages,
          hasNextPage: paginatedResult.hasNextPage,
          title: paginatedResult.title,
        ));
      },
    );

    _isFetchingNextPage = false;
  }

  Future<void> sendMessage(String messageContent) async {
    final userMessageId = _uuid.v4();
    final userMessage = ChatMessage(
      id: userMessageId,
      content: messageContent,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );
    final pendingAiMessage = ChatMessage(
      id: _uuid.v4(),
      content: "...",
      role: MessageRole.model,
      timestamp: DateTime.now(),
      isPending: true,
    );

    if (isClosed) return;
    emit(state.copyWith(
      status: ChatMessagesStatus.loaded,
      messages: [pendingAiMessage, userMessage, ...state.messages],
    ));

    final result = await _sendMessageUseCase(
      SendMessageParams(chatId: _chatId, messageContent: messageContent),
    );

    result.fold(
      (failure) {
        final errorMessages = state.messages
            .map((msg) {
              if (msg.id == userMessageId) {
                return msg.copyWith(isError: true);
              }
              return msg;
            })
            .where((msg) => !msg.isPending)
            .toList();

        if (isClosed) return;
        emit(state.copyWith(
            messages: errorMessages, status: ChatMessagesStatus.loaded));
      },
      (response) {
        final wasNewChat = _chatId == null;
        if (wasNewChat) {
          _chatId = response.chatId;
        }

        final finalAiMessage = ChatMessage(
          id: _uuid.v4(),
          content: response.aiMessageResult,
          role: MessageRole.model,
          timestamp: response.messageTime,
        );

        final finalUserMessage = userMessage.copyWith(
          timestamp: response.messageTime.subtract(const Duration(seconds: 1)),
        );

        final finalMessages = state.messages
            .where((msg) => !msg.isPending && msg.id != userMessageId)
            .toList();

        final newHasNextPage = wasNewChat ? false : state.hasNextPage;

        if (!isClosed) {
          emit(state.copyWith(
            messages: [finalAiMessage, finalUserMessage, ...finalMessages],
            title: response.chatTitle,
            newChatId: wasNewChat ? _chatId : null,
            hasNextPage: newHasNextPage,
            status: ChatMessagesStatus.loaded,
          ));
        }

        final updatedChat = Chat(
          id: response.chatId,
          title: response.chatTitle,
          updatedAt: response.messageTime,
        );
        _chatHistoryCubit.addOrUpdateChat(updatedChat);
      },
    );
  }
}
