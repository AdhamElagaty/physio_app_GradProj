import 'package:uuid/uuid.dart';

import 'chat_message_model.dart';
import 'chat_model.dart';

class PaginatedChatsResponseModel {
  final List<ChatModel> chats;
  final bool hasNextPage;

  PaginatedChatsResponseModel({required this.chats, required this.hasNextPage});

  factory PaginatedChatsResponseModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> chatList = json['data'];
    return PaginatedChatsResponseModel(
      chats: chatList.map((i) => ChatModel.fromJson(i)).toList(),
      hasNextPage: json['pageNumber'] * json['pageSize'] < json['totalCount'],
    );
  }
}

class PaginatedMessagesResponseModel {
  final List<ChatMessageModel> messages;
  final bool hasNextPage;
  final String chatTitle;

  PaginatedMessagesResponseModel({
    required this.messages,
    required this.hasNextPage,
    required this.chatTitle,
  });

  factory PaginatedMessagesResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final chatData = data['chat'];
    final messagesData = data['messages'] as List;
    const uuid = Uuid();

    return PaginatedMessagesResponseModel(
      chatTitle: chatData['title'],
      messages: messagesData
          .map((i) => ChatMessageModel.fromJson(i, uuid.v4()))
          .toList(),
      hasNextPage: json['pageNumber'] * json['pageSize'] < json['totalCount'],
    );
  }
}
