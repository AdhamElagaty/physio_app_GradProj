class SendMessageResult {
  final String chatId;
  final String chatTitle;
  final String aiMessageResult;
  final DateTime messageTime;

  SendMessageResult({
    required this.chatId,
    required this.chatTitle,
    required this.aiMessageResult,
    required this.messageTime,
  });
}
