import '../model/paginated_response_models.dart';
import '../model/send_message_response_model.dart';

abstract class ChatRemoteDataSource {
  Future<PaginatedChatsResponseModel> getChats({
    required int pageIndex,
    required int pageSize,
    String? titleSearch,
  });

  Future<PaginatedMessagesResponseModel> getChatMessages({
    required String chatId,
    required int pageIndex,
    required int pageSize,
  });

  Future<SendMessageResponseModel> sendMessage({
    String? chatId,
    required String messageContent,
  });

  Future<void> updateChatTitle({
    required String chatId,
    required String newTitle,
  });

  Future<void> deleteChat({
    required String chatId,
  });
}
