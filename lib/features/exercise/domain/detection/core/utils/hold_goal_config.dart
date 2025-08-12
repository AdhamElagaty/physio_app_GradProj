class HoldGoalConfig {
  double currentGoal;
  final double defaultGoal;
  final double incrementStep;
  final double minValidHoldTime;
  bool autoIncreaseEnabled;

  HoldGoalConfig({
    required double initialGoal,
    required this.defaultGoal,
    required this.incrementStep,
    required this.minValidHoldTime,
    this.autoIncreaseEnabled = true,
  }) : currentGoal = initialGoal;


  bool increaseGoal(double achievedHoldTime) {
    if (!autoIncreaseEnabled) {
      return false;
    }

    double potentialNewGoal =
        ((achievedHoldTime / incrementStep).ceil() * incrementStep) +
            incrementStep;

    if (potentialNewGoal > currentGoal) {
      currentGoal = potentialNewGoal;
      return true;
    }

    return false;
  }

  void reset() {
    currentGoal = defaultGoal;
  }
}