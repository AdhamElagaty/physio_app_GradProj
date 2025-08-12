import '../../../../core/entities/paginated_result.dart';
import 'chat_message.dart';

class ChatMessagesPaginatedResult extends PaginatedResult<ChatMessage> {
  final String title;
  ChatMessagesPaginatedResult({required super.items, required super.hasNextPage, required this.title});
}
