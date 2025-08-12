import 'dart:ui';

import '../../../core/entities/enums/feedback_type.dart';
import '../../../core/entities/exercise_feedback_color.dart';
import '../../../core/abstractions/feedback_provider.dart';

class BicepCurlFeedbackProvider extends FeedbackProvider {
  BicepCurlFeedbackProvider({
    Map<FeedbackType, MessageProvider>? customMessages,
    Map<FeedbackType, ExerciseFeedbackColor>? customColors,
  }) : super(
          exerciseName: "Bicep Curl",
          customMessages: _getMergedCustomMessages(customMessages),
          customColors: _getMergedCustomColors(customColors),
        );

  static Map<FeedbackType, MessageProvider> _getMergedCustomMessages(
      Map<FeedbackType, MessageProvider>? externalCustomMessages) {
    final Map<FeedbackType, MessageProvider> bicepCurlSpecificMessages = {
      FeedbackType.bicepCurlSetupInitialPrompt: (event) =>
          ["Let's do some Bicep Curls! Stand tall and get ready."],
      FeedbackType.bicepCurlSetupPersonNotVertical: (event) => [
            "Please stand upright, so your body is vertical in the camera view.",
            "Make sure you're standing straight and tall for the camera."
          ],
      FeedbackType.bicepCurlSetupHoldVerticalOrientation: (event) =>
          ["Great! Hold that upright position for a moment..."],
      FeedbackType.bicepCurlSetupVisibilityBad: (event) => [
            "I can't see you clearly. Make sure your whole body is in the frame.",
            "Ensure you're fully visible to the camera."
          ],
      FeedbackType.bicepCurlSetupSuccess: (event) => [
            "Perfect! Ready to curl when you are.",
            "Setup complete! Let's begin the Bicep Curls."
          ],
      FeedbackType.bicepCurlErrorNoPersonDetected: (event) =>
          ["Can't see anyone. Please step into the camera view."],
      FeedbackType.bicepCurlProcessingPosition: (event) =>
          ["Processing your position..."],
      FeedbackType.bicepCurlMoveIntoView: (event) =>
          ["Move into view of the camera."],
      FeedbackType.bicepCurlPleaseStepIntoFrame: (event) =>
          ["Please step into frame to begin."],
      FeedbackType.bicepCurlLeftArmSlowDown: (event) =>
          ["Left arm: A bit too fast, slow down."],
      FeedbackType.bicepCurlLeftArmBeMoreFluid: (event) =>
          ["Left arm: Try for a more fluid motion."],
      FeedbackType.bicepCurlLeftArmFocusOnForm: (event) =>
          ["Left arm: Focus on your form."],
      FeedbackType.bicepCurlLeftArmGoodRep: (event) => ["Left arm: Good rep!"],
      FeedbackType.bicepCurlLeftArmKeepShoulderStill: (event) =>
          ["Left arm: Keep your shoulder still."],
      FeedbackType.bicepCurlLeftArmKeepBackStraight: (event) =>
          ["Left arm: Keep your back straight, avoid leaning."],
      FeedbackType.bicepCurlLeftArmExtendFully: (event) =>
          ["Left arm: Extend your arm fully at the bottom."],
      FeedbackType.bicepCurlLeftArmCurlHigher: (event) =>
          ["Left arm: Curl a bit higher."],
      FeedbackType.bicepCurlLeftArmGoodForm: (event) =>
          ["Left arm: Good form!"],
      FeedbackType.bicepCurlLeftArmMoveInView: (event) =>
          ["Left arm: Not visible. Move into view."],
      FeedbackType.bicepCurlLeftArmRepCounted: (event) =>
          ["Left Rep: {rep_count}!"],
      FeedbackType.bicepCurlRightArmSlowDown: (event) =>
          ["Right arm: A bit too fast, slow down."],
      FeedbackType.bicepCurlRightArmBeMoreFluid: (event) =>
          ["Right arm: Try for a more fluid motion."],
      FeedbackType.bicepCurlRightArmFocusOnForm: (event) =>
          ["Right arm: Focus on your form."],
      FeedbackType.bicepCurlRightArmGoodRep: (event) =>
          ["Right arm: Good rep!"],
      FeedbackType.bicepCurlRightArmKeepShoulderStill: (event) =>
          ["Right arm: Keep your shoulder still."],
      FeedbackType.bicepCurlRightArmKeepBackStraight: (event) =>
          ["Right arm: Keep your back straight, avoid leaning."],
      FeedbackType.bicepCurlRightArmExtendFully: (event) =>
          ["Right arm: Extend your arm fully at the bottom."],
      FeedbackType.bicepCurlRightArmCurlHigher: (event) =>
          ["Right arm: Curl a bit higher."],
      FeedbackType.bicepCurlRightArmGoodForm: (event) =>
          ["Right arm: Good form!"],
      FeedbackType.bicepCurlRightArmMoveInView: (event) =>
          ["Right arm: Not visible. Move into view."],
      FeedbackType.bicepCurlRightArmRepCounted: (event) =>
          ["Right Rep: {rep_count}!"],
      FeedbackType.bicepCurlEncourage: (event) => [
            "Keep it up! You're doing great!",
            "Nice work! Stay focused and keep going.",
            "Push for one more, you're stronger than you think!",
            "Awesome work! Those biceps are firing!",
            "Yes! That's the way to build them."
          ],
      FeedbackType.bicepCurlFormIssueResettingState: (event) => [
            "Incorrect form on {arm_side} arm. Resetting rep attempt. Focus on control."
          ],
      FeedbackType.goalRepTargetMet: (event) => [
            "Goal of {reps_goal} reps met! Fantastic work!",
            "You hit {reps_goal} reps! Awesome!"
          ],
      FeedbackType.goalRepTargetMetNewGoal: (event) => [
            "Target of {reps_achieved} met! New goal: {new_reps_goal} reps. Keep it up!",
            "Crushed {reps_achieved} reps! Aiming for {new_reps_goal} now!"
          ],
      FeedbackType.goalRepExceeded: (event) => [
            "{reps_over_count} reps over your goal! Incredible effort!",
            "Wow, {reps_over_count} extra reps! You're strong!"
          ],
      FeedbackType.goalRepMilestone: (event) => [
            "{reps_milestone} reps! Great milestone. Keep going!",
            "That's {reps_milestone} reps! Solid progress!"
          ],
      FeedbackType.infoTrackerReset: (event) => [
            "Bicep Curl tracker reset. Let's start fresh!",
            "Tracker reset for Bicep Curls."
          ],
    };
    return {...bicepCurlSpecificMessages, ...?externalCustomMessages};
  }

  static Map<FeedbackType, ExerciseFeedbackColor> _getMergedCustomColors(
      Map<FeedbackType, ExerciseFeedbackColor>? externalCustomColors) {
    final Map<FeedbackType, ExerciseFeedbackColor> bicepCurlSpecificColors = {
      FeedbackType.bicepCurlLeftArmGoodForm:
          ExerciseFeedbackColor(const Color(0xFF66BB6A)),
      FeedbackType.bicepCurlRightArmGoodForm:
          ExerciseFeedbackColor(const Color(0xFF66BB6A)),
      FeedbackType.bicepCurlLeftArmGoodRep:
          ExerciseFeedbackColor(const Color(0xFF66BB6A)),
      FeedbackType.bicepCurlRightArmGoodRep:
          ExerciseFeedbackColor(const Color(0xFF66BB6A)),
      FeedbackType.bicepCurlLeftArmFocusOnForm:
          ExerciseFeedbackColor(const Color(0xFFFFA726)),
      FeedbackType.bicepCurlRightArmFocusOnForm:
          ExerciseFeedbackColor(const Color(0xFFFFA726)),
      FeedbackType.bicepCurlFormIssueResettingState:
          ExerciseFeedbackColor(const Color(0xFFEF5350)),
    };
    return {...bicepCurlSpecificColors, ...?externalCustomColors};
  }
}
