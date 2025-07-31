import 'package:equatable/equatable.dart';

class GetChatMessagesParams extends Equatable {
  final String chatId;
  final int pageIndex;
  final int pageSize;

  const GetChatMessagesParams({
    required this.chatId,
    required this.pageIndex,
    this.pageSize = 20,
  });

  @override
  List<Object> get props => [chatId, pageIndex, pageSize];
}
