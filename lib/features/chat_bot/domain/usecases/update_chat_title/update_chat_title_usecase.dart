import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../repositories/chat_repository.dart';
import 'update_chat_title_params.dart';

class UpdateChatTitleUseCase implements UseCase<void, UpdateChatTitleParams> {
  final ChatRepository _repository;
  UpdateChatTitleUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(UpdateChatTitleParams params) {
    return _repository.updateChatTitle(
      chatId: params.chatId,
      newTitle: params.newTitle,
    );
  }
}
