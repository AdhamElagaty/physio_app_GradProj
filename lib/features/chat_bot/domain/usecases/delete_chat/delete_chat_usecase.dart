import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../repositories/chat_repository.dart';

class DeleteChatUseCase implements UseCase<void, String> {
  final ChatRepository _repository;
  DeleteChatUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(String chatId) {
    return _repository.deleteChat(chatId: chatId);
  }
}
