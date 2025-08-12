import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/message_role.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.content,
    required super.role,
    required super.timestamp,
    super.isPending = false,
    super.isError = false,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json, String id) {
    return ChatMessageModel(
      id: id,
      content: json['messageContent'],
      role: (json['roleType'] as int) == 1 ? MessageRole.user : MessageRole.model,
      timestamp: DateUtils.parseBackendDate(json['messageTime']),
    );
  }

  @override
  ChatMessageModel copyWith({
    String? id,
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    bool? isPending,
    bool? isError,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      isPending: isPending ?? this.isPending,
      isError: isError ?? this.isError,
    );
  }
}
