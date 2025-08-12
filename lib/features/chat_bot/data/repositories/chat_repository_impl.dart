import 'package:dartz/dartz.dart';

import '../../../../core/error/error_context.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../domain/entities/chat_messages_paginated_result.dart';
import '../../domain/entities/chats_paginated_result.dart';
import '../../domain/entities/send_message_result.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl extends BaseRepository implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  ChatRepositoryImpl(this._remoteDataSource, NetworkInfo networkInfo) : super(networkInfo);

  @override
  Future<Either<Failure, ChatsPaginatedResult>> getChats({
    required int pageIndex,
    required int pageSize,
    String? titleSearch,
  }) {
    return handleRequest(() async {
      final responseModel = await _remoteDataSource.getChats(
        pageIndex: pageIndex,
        pageSize: pageSize,
        titleSearch: titleSearch,
      );
      return ChatsPaginatedResult(items: responseModel.chats, hasNextPage: responseModel.hasNextPage);
    }, context: ErrorContext.chatGetChats);
  }

  @override
  Future<Either<Failure, ChatMessagesPaginatedResult>> getChatMessages({
    required String chatId,
    required int pageIndex,
    required int pageSize,
  }) {
    return handleRequest(() async {
      final responseModel = await _remoteDataSource.getChatMessages(
        chatId: chatId,
        pageIndex: pageIndex,
        pageSize: pageSize,
      );
      return ChatMessagesPaginatedResult(
        items: responseModel.messages,
        hasNextPage: responseModel.hasNextPage,
        title: responseModel.chatTitle,
      );
    }, context: ErrorContext.chatGetChatMessages);
  }

  @override
  Future<Either<Failure, SendMessageResult>> sendMessage({
    String? chatId,
    required String messageContent,
  }) {
    return handleRequest(() => _remoteDataSource.sendMessage(
      chatId: chatId,
      messageContent: messageContent,
    ), context: ErrorContext.chatSendMessage);
  }

  @override
  Future<Either<Failure, void>> updateChatTitle({
    required String chatId,
    required String newTitle,
  }) {
    return handleRequest(() => _remoteDataSource.updateChatTitle(
      chatId: chatId,
      newTitle: newTitle,
    ), context: ErrorContext.chatUpdateTitle);
  }

  @override
  Future<Either<Failure, void>> deleteChat({required String chatId}) {
    return handleRequest(() => _remoteDataSource.deleteChat(chatId: chatId), context: ErrorContext.chatDeleteChat);
  }
}
