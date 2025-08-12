import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/chat.dart';

class ChatModel extends Chat {
  const ChatModel({
    required super.id,
    required super.title,
    required super.updatedAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'],
      title: json['title'],
      updatedAt: DateUtils.parseBackendDate(json['updatedAt']),
    );
  }
  
  @override
  ChatModel copyWith({
    String? id,
    String? title,
    DateTime? updatedAt,
  }) {
    return ChatModel(
      id: id ?? this.id,
      title: title ?? this.title,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
