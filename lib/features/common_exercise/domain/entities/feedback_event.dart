import 'enums/feedback_type.dart';

class FeedbackEvent {
  final FeedbackType type;
  final Map<String, dynamic>? args;

  FeedbackEvent(this.type, {this.args});


  bool isEquals(FeedbackEvent? other) {
    if (other == null) return false;

    if (type != other.type) return false;

    return _mapsAreEqual(args, other.args);
  }


  static bool _mapsAreEqual(Map<String, dynamic>? map1, Map<String, dynamic>? map2) {
    if (map1 == null && map2 == null) return true;
    if (map1 == null || map2 == null) return false;
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) {
        return false;
      }
    }
    return true;
  }
}


