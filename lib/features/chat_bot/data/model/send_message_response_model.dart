import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/send_message_result.dart';

class SendMessageResponseModel extends SendMessageResult {
  SendMessageResponseModel({
    required super.chatId,
    required super.chatTitle,
    required super.aiMessageResult,
    required super.messageTime,
  });

  factory SendMessageResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return SendMessageResponseModel(
      chatId: data['chatId'],
      chatTitle: data['chatTitle'],
      aiMessageResult: data['aiMessageResult'],
      messageTime: DateUtils.parseBackendDate(data['messageTime']),
    );
  }
}
