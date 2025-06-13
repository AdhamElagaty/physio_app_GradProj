import 'package:gradproject/features/home/presentation/screens/chat_bot/data/models/ai_chat_model.dart';

class AiMessageResponse {
  final String chatId;
  final String chatTitle;
  final String aiMessageResult;
  final DateTime messageTime;

  AiMessageResponse({
    required this.chatId,
    required this.chatTitle,
    required this.aiMessageResult,
    required this.messageTime,
  });

  factory AiMessageResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return AiMessageResponse(
      chatId: data['chatId'],
      chatTitle: data['chatTitle'],
      aiMessageResult: data['aiMessageResult'],
      messageTime: AiChat.parseBackendDate(data['messageTime']),
    );
  }
}
