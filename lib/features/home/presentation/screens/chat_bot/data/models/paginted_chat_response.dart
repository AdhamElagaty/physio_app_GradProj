import 'package:gradproject/features/home/presentation/screens/chat_bot/data/models/ai_chat_model.dart';

class PaginatedChatsResponse {
  final List<AiChat> chats;
  final bool hasNextPage;

  PaginatedChatsResponse({required this.chats, required this.hasNextPage});

  factory PaginatedChatsResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> chatList = json['data'];
    return PaginatedChatsResponse(
      chats: chatList.map((i) => AiChat.fromJson(i)).toList(),
      hasNextPage: json['pageNumber'] * json['pageSize'] < json['totalCount'],
    );
  }
}
