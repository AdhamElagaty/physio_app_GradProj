import 'package:equatable/equatable.dart';

class SendMessageParams extends Equatable {
  final String? chatId;
  final String messageContent;

  const SendMessageParams({this.chatId, required this.messageContent});

  @override
  List<Object?> get props => [chatId, messageContent];
}
