import 'package:equatable/equatable.dart';

import 'message_role.dart';

class ChatMessage extends Equatable {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final bool isPending;
  final bool isError;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isPending = false,
    this.isError = false,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    bool? isPending,
    bool? isError,
  }) {
    return ChatMessage(
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
