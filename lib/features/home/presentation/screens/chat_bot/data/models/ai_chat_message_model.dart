import 'package:equatable/equatable.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/data/models/ai_chat_model.dart';

enum MessageRole { user, model }

class AiChatMessage extends Equatable {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final bool isPending;
  final bool isError;

  const AiChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isPending = false,
    this.isError = false,
  });

  factory AiChatMessage.fromJson(Map<String, dynamic> json, String id) {
    return AiChatMessage(
      id: id,
      content: json['messageContent'],
      role:
          (json['roleType'] as int) == 1 ? MessageRole.user : MessageRole.model,
      timestamp: AiChat.parseBackendDate(json['messageTime']),
    );
  }

  AiChatMessage copyWith({
    String? id,
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    bool? isPending,
    bool? isError,
  }) {
    return AiChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      isPending: isPending ?? this.isPending,
      isError: isError ?? this.isError,
    );
  }

  @override
  List<Object?> get props => [id, content, role, timestamp, isPending, isError];
}
