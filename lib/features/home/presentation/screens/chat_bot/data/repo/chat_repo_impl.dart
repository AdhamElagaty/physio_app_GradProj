// lib/chat/repository/chat_repository.dart
import 'package:dio/dio.dart';
import 'package:gradproject/core/api/api_manger.dart';
import 'package:gradproject/core/api/end_points.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/data/models/ai_message_respone.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/data/models/paginated_message_mosel.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/data/models/paginted_chat_response.dart'; // Still need DioException

class ChatRepository {
  final ApiManager _apiManager;

  ChatRepository(this._apiManager);

  Future<PaginatedChatsResponse> getChats(
      {int pageIndex = 1, int pageSize = 15, String? titleSearch}) async {
    final response = await _apiManager.getData(
      endPoint: Endpoints.getChats, // Corrected to use named parameter
      params: {
        'PageIndex': pageIndex,
        'PageSize': pageSize,
        if (titleSearch != null && titleSearch.isNotEmpty)
          'TitleSearch': titleSearch,
      },
    );
    return PaginatedChatsResponse.fromJson(response.data);
  }

  Future<PaginatedMessagesResponse> getChatMessages(String chatId,
      {int pageIndex = 1, int pageSize = 20}) async {
    final response = await _apiManager.getData(
      endPoint:
          Endpoints.getChatMessages(chatId), // Corrected to use named parameter
      params: {
        'PageIndex': pageIndex,
        'PageSize': pageSize,
      },
    );
    return PaginatedMessagesResponse.fromJson(response.data);
  }

  Future<AiMessageResponse> sendMessage(
      {String? chatId, required String messageContent}) async {
    final response = await _apiManager.postData(
      endPoint: Endpoints.sendMessage, // Use the named parameter 'endPoint'
      body: {
        // This is the 'body' parameter for postData
        'chatId': chatId,
        'messageContent': messageContent,
      },
    );
    return AiMessageResponse.fromJson(response.data);
  }

  Future<void> updateChatTitle(
      {required String chatId, required String newTitle}) async {
    // Corrected call: 'endPoint' is a required named parameter, 'body' for data.
    await _apiManager.putData(
      endPoint: Endpoints.updateChatTitle(
          chatId), // Pass endpoint using named parameter
      body: {
        // Data for the PUT request goes into the 'body' map
        'title': newTitle,
      },
    );
  }

  Future<void> deleteChat({required String chatId}) async {
    // Corrected call: 'endPoint' is a required named parameter.
    await _apiManager.deleteData(
      endPoint: Endpoints.deleteChat(chatId),
    );
  }
}
