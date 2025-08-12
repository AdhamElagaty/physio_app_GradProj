import 'dart:collection';

class AngleSmoothing {
  final int windowSize;
  final Queue<List<double>> _angleHistory = Queue();
  
  AngleSmoothing({this.windowSize = 5});
  
  void addAngles(List<double> angles) {
    _angleHistory.add(angles);
    if (_angleHistory.length > windowSize) {
      _angleHistory.removeFirst();
    }
  }
  
  List<double> getSmoothedAngles() {
    if (_angleHistory.isEmpty) return [];
    
    final result = List<double>.filled(_angleHistory.first.length, 0.0);
    
    for (final angles in _angleHistory) {
      for (int i = 0; i < angles.length; i++) {
        result[i] += angles[i] / _angleHistory.length;
      }
    }
    
    return result;
  }
  
  void reset() {
    _angleHistory.clear();
  }
}