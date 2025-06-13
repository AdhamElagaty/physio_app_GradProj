import 'package:gradproject/features/home/presentation/screens/chat_bot/data/models/ai_chat_message_model.dart';

import 'package:uuid/uuid.dart';

class PaginatedMessagesResponse {
  final List<AiChatMessage> messages;
  final bool hasNextPage;
  final String chatTitle;

  PaginatedMessagesResponse({
    required this.messages,
    required this.hasNextPage,
    required this.chatTitle,
  });

  factory PaginatedMessagesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final chatData = data['chat'];
    final messagesData = data['messages'] as List;
    final uuid = Uuid();

    return PaginatedMessagesResponse(
      chatTitle: chatData['title'],
      messages: messagesData
          .map((i) => AiChatMessage.fromJson(i, uuid.v4()))
          .toList(),
      hasNextPage: json['pageNumber'] * json['pageSize'] < json['totalCount'],
    );
  }
}
