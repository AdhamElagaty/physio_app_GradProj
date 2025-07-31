import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../entities/chats_paginated_result.dart';
import '../../repositories/chat_repository.dart';
import 'get_chats_params.dart';

class GetChatsUseCase implements UseCase<ChatsPaginatedResult, GetChatsParams> {
  final ChatRepository _repository;
  GetChatsUseCase(this._repository);

  @override
  Future<Either<Failure, ChatsPaginatedResult>> call(GetChatsParams params) {
    return _repository.getChats(
      pageIndex: params.pageIndex,
      pageSize: params.pageSize,
      titleSearch: params.titleSearch,
    );
  }
}
