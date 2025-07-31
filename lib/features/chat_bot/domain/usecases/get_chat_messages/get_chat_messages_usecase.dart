import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../entities/chat_messages_paginated_result.dart';
import '../../repositories/chat_repository.dart';
import 'get_chat_messages_params.dart';

class GetChatMessagesUseCase implements UseCase<ChatMessagesPaginatedResult, GetChatMessagesParams> {
  final ChatRepository _repository;
  GetChatMessagesUseCase(this._repository);

  @override
  Future<Either<Failure, ChatMessagesPaginatedResult>> call(GetChatMessagesParams params) {
    return _repository.getChatMessages(
      chatId: params.chatId,
      pageIndex: params.pageIndex,
      pageSize: params.pageSize,
    );
  }
}
