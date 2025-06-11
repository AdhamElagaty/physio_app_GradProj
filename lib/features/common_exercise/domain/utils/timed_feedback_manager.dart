import '../entities/feedback_event.dart';

class TimedFeedbackManager {
  FeedbackEvent? _currentEvent;
  DateTime? _displayTimestamp; 
  final Duration displayDuration;

  TimedFeedbackManager({this.displayDuration = const Duration(seconds: 3)});

  FeedbackEvent? get currentEvent => _currentEvent;

  void setEvent(FeedbackEvent event) {
    _currentEvent = event;
    _displayTimestamp = DateTime.now();
  }

  void clearEvent() {
    _currentEvent = null;
    _displayTimestamp = null;
  }

  FeedbackEvent? getActiveEvent() {
    if (_currentEvent != null && _displayTimestamp != null) {
      if (DateTime.now().difference(_displayTimestamp!) < displayDuration) {
        return _currentEvent;
      } else {
        clearEvent();
      }
    }
    return null;
  }
}