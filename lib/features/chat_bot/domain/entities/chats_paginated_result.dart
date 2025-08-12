import '../../../../core/entities/paginated_result.dart';
import 'chat.dart';

class ChatsPaginatedResult extends PaginatedResult<Chat> {
  ChatsPaginatedResult({required super.items, required super.hasNextPage});
}
