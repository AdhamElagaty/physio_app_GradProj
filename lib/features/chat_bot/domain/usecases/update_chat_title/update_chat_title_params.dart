import 'package:equatable/equatable.dart';

class UpdateChatTitleParams extends Equatable {
  final String chatId;
  final String newTitle;

  const UpdateChatTitleParams({required this.chatId, required this.newTitle});

  @override
  List<Object> get props => [chatId, newTitle];
}
