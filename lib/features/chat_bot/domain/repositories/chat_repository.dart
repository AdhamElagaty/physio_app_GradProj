import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/chat_messages_paginated_result.dart';
import '../entities/chats_paginated_result.dart';
import '../entities/send_message_result.dart';

abstract class ChatRepository {
  Future<Either<Failure, ChatsPaginatedResult>> getChats({
    required int pageIndex,
    required int pageSize,
    String? titleSearch,
  });

  Future<Either<Failure, ChatMessagesPaginatedResult>> getChatMessages({
    required String chatId,
    required int pageIndex,
    required int pageSize,
  });

  Future<Either<Failure, SendMessageResult>> sendMessage({
    String? chatId,
    required String messageContent,
  });

  Future<Either<Failure, void>> updateChatTitle({
    required String chatId,
    required String newTitle,
  });

  Future<Either<Failure, void>> deleteChat({
    required String chatId,
  });
}
