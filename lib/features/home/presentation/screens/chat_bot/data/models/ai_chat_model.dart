import 'package:gradproject/core/utils/date_utils.dart';
import 'package:intl/intl.dart' as intl;

class AiChat {
  final String id;
  String title;
  DateTime updatedAt;

  AiChat({required this.id, required this.title, required this.updatedAt});

  factory AiChat.fromJson(Map<String, dynamic> json) {
    return AiChat(
      id: json['id'],
      title: json['title'],
      updatedAt: DateUtils.parseBackendDate(json['updatedAt']),
    );
  }

  AiChat copyWith({
    String? title,
    DateTime? updatedAt,
  }) {
    return AiChat(
      id: id,
      title: title ?? this.title,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime parseBackendDate(String dateString) {
    final initialParse = DateTime.parse(dateString);
    if (initialParse.isUtc) {
      return initialParse;
    } else {
      return DateTime.utc(
        initialParse.year,
        initialParse.month,
        initialParse.day,
        initialParse.hour,
        initialParse.minute,
        initialParse.second,
        initialParse.millisecond,
        initialParse.microsecond,
      );
    }
  }
}
