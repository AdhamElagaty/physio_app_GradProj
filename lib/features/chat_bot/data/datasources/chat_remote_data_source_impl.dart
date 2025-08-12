import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/endpoints.dart';
import '../model/paginated_response_models.dart';
import '../model/send_message_response_model.dart';
import 'chat_remote_data_source.dart';

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiConsumer _apiConsumer;
  ChatRemoteDataSourceImpl(this._apiConsumer);

  @override
  Future<PaginatedChatsResponseModel> getChats({
    required int pageIndex,
    required int pageSize,
    String? titleSearch,
  }) async {
    final response = await _apiConsumer.get(
      Endpoints.chatsGet,
      queryParameters: {
        'PageIndex': pageIndex,
        'PageSize': pageSize,
        if (titleSearch != null && titleSearch.isNotEmpty)
          'TitleSearch': titleSearch,
      },
    );
    return PaginatedChatsResponseModel.fromJson(response);
  }

  @override
  Future<PaginatedMessagesResponseModel> getChatMessages({
    required String chatId,
    required int pageIndex,
    required int pageSize,
  }) async {
    final response = await _apiConsumer.get(
      Endpoints.chatMessagesGet(chatId),
      queryParameters: {
        'PageIndex': pageIndex,
        'PageSize': pageSize,
      },
    );
    return PaginatedMessagesResponseModel.fromJson(response);
  }

  @override
  Future<SendMessageResponseModel> sendMessage({
    String? chatId,
    required String messageContent,
  }) async {
    final response = await _apiConsumer.post(
      Endpoints.sendMessagePost,
      body: {'chatId': chatId, 'messageContent': messageContent},
    );
    return SendMessageResponseModel.fromJson(response);
  }

  @override
  Future<void> updateChatTitle({
    required String chatId,
    required String newTitle,
  }) async {
    await _apiConsumer.put(
      Endpoints.updateChatTitlePut(chatId),
      queryParameters: {'title': newTitle},
    );
  }

  @override
  Future<void> deleteChat({required String chatId}) async {
    await _apiConsumer.delete(Endpoints.deleteChatDelete(chatId));
  }
}
