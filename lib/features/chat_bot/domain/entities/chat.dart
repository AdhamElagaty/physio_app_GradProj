import 'package:equatable/equatable.dart';

class Chat extends Equatable {
  final String id;
  final String title;
  final DateTime updatedAt;

  const Chat({
    required this.id,
    required this.title,
    required this.updatedAt,
  });

  Chat copyWith({
    String? id,
    String? title,
    DateTime? updatedAt,
  }) {
    return Chat(
      id: id ?? this.id,
      title: title ?? this.title,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object> get props => [id, title, updatedAt];
}
