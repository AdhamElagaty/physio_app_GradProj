class RepGoalConfig {
  int _currentGoal;
  final int defaultGoal;
  final int increment; 
  final int milestoneInterval;
  bool autoIncreaseEnabled;

  RepGoalConfig({
    required int initialGoal,
    required this.defaultGoal,
    required this.increment,
    required this.milestoneInterval,
    this.autoIncreaseEnabled = true,
  }) : _currentGoal = initialGoal;

  int get currentGoal => _currentGoal;

  set currentGoal(int value) {
    if (value > 0) {
      _currentGoal = value;
    }
  }

  bool increaseGoal() {
    if (autoIncreaseEnabled) {
      _currentGoal += increment;
      return true;
    }
    return false;
  }

  void reset() {
    _currentGoal = defaultGoal;
  }
}