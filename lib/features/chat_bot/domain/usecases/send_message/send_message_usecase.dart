import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../entities/send_message_result.dart';
import '../../repositories/chat_repository.dart';
import 'send_message_params.dart';

class SendMessageUseCase implements UseCase<SendMessageResult, SendMessageParams> {
  final ChatRepository _repository;
  SendMessageUseCase(this._repository);

  @override
  Future<Either<Failure, SendMessageResult>> call(SendMessageParams params) {
    return _repository.sendMessage(
      chatId: params.chatId,
      messageContent: params.messageContent,
    );
  }
}
