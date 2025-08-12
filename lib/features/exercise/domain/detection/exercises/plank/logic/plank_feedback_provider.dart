import 'dart:ui';

import '../../../core/entities/enums/feedback_type.dart';
import '../../../core/entities/exercise_feedback_color.dart';
import '../../../core/abstractions/feedback_provider.dart';

class PlankFeedbackProvider extends FeedbackProvider {
  PlankFeedbackProvider({
    Map<FeedbackType, MessageProvider>? customMessages,
    Map<FeedbackType, ExerciseFeedbackColor>? customColors,
  }) : super(
          exerciseName: "Plank",
          customMessages: _getMergedCustomMessages(customMessages),
          customColors: _getMergedCustomColors(customColors),
        );

  static Map<FeedbackType, MessageProvider> _getMergedCustomMessages(
      Map<FeedbackType, MessageProvider>? externalCustomMessages) {
    final Map<FeedbackType, MessageProvider> plankSpecificMessages = {
      // --- Setup ---
      FeedbackType.plankSetupInitialPrompt: (event) => [
            "Let's get ready for the Plank! Assume the starting position on your forearms (or hands).",
            "Prepare for Plank. Find a stable position.",
            "Plank time! Get into position.",
          ],
      FeedbackType.setupPersonNotHorizontal: (event) => [
            "For Plank, please align your body horizontally to the camera.",
            "Make sure you're horizontal for the Plank exercise."
          ],
      FeedbackType.plankSetupIncompleteLandmarks: (event) => [
            "Ensure your shoulders, hips, and ankles are clearly visible.",
            "I need to see your full body alignment for Plank setup.",
            "Adjust your position so I can see your shoulders, hips, and ankles.",
          ],
      FeedbackType.plankSetupHipsTooHigh: (event) => [
            "For setup: lower your hips to form a straight line.",
            "Hips are a bit high for the starting position. Lower them.",
            "Straighten your body by lowering your hips for setup.",
          ],
      FeedbackType.plankSetupHipsTooLow: (event) => [
            "For setup: lift your hips to form a straight line.",
            "Hips are sagging a bit for setup. Lift them.",
            "Engage your core and lift your hips for the starting position.",
          ],
      FeedbackType.plankSetupHoldStraightPosition: (event) => [
            "Hold that straight position for Plank setup...",
            "Almost there, keep your body aligned for setup.",
            "Holding setup position... stay steady.",
          ],
      FeedbackType.plankSetupFaceUp: (event) => [
            "Turn your face down toward the ground for plank position.",
            "For plank, your face should be facing down, not up.",
            "Flip over - plank requires face down position.",
          ],
      FeedbackType.plankSetupFaceNotVisible: (event) => [
            "Make sure your face is visible for proper plank detection.",
            "I need to see your face to confirm plank position.",
            "Position yourself so I can see your face clearly.",
          ],
      FeedbackType.plankSetupSuccess: (event) => [
            "Great starting position for Plank! Hold it steady.",
            "Setup complete! Ready to hold that Plank!",
            "Perfect Plank setup. Engage your core!",
          ],

      FeedbackType.plankCorrectForm: (event) => [
            "Excellent plank! Body is straight.",
            "Perfect form! Keep holding strong.",
            "That's a solid plank!",
          ],
      FeedbackType.plankHighHips: (event) => [
            "Lower your hips slightly to straighten your body.",
            "Hips are a bit high. Try to bring them down.",
            "Flatten your back by lowering your hips.",
          ],
      FeedbackType.plankLowHips: (event) => [
            "Lift your hips slightly to engage your core.",
            "Hips are sagging. Raise them to form a straight line.",
            "Engage your abs and lift your hips.",
          ],
      FeedbackType.plankMaintainStraightLine: (event) => [
            "Maintain a straight line from head to heels.",
            "Focus on keeping your body aligned.",
            "Imagine a straight plank from head to feet.",
          ],
      FeedbackType.plankEngageCore: (event) => [
            "Remember to engage your core muscles!",
            "Tighten your abs to support your back.",
            "Keep that core strong!",
          ],
      FeedbackType.plankFormIssueGeneric: (event) => [
            "Adjust your plank form for better stability.",
            "Focus on your alignment. Try to hold steady.",
            "Small adjustments needed for a perfect plank.",
          ],
      FeedbackType.plankHoldingCorrectly: (event) => [
            "Holding: {duration_s}! Keep it up!",
            "Strong hold for {duration_s}!",
            "{duration_s} and counting! Great work!",
          ],
      FeedbackType.plankAdjustingForm: (event) => [
            "Adjusting... try to hold your form steady.",
            "Slight instability detected. Focus and stabilize.",
            "Almost there, keep your plank form consistent.",
          ],
      FeedbackType.plankTooFast: (event) => [
            "Movement detected. Plank is a static hold, try to stay still.",
            "Hold your position steady for the plank.",
            "Try to minimize movement.",
          ],

      FeedbackType.errorNoPersonDetected: (event) => [
            "I can't see you for the Plank. Are you in the frame?",
            "No one detected. Please position yourself for the Plank.",
          ],
      FeedbackType.infoTrackerReset: (event) => [
            "Plank tracker reset! Let's get you set up again.",
            "Okay, starting fresh with the Plank tracker.",
          ],
      FeedbackType.exerciseDownPositionReady: (event) {
        final bool? isFirstTime = event.args?['is_first_time'];
        if (isFirstTime == true) {
          return [
            "Ready for your first Plank hold!",
            "First Plank! Let's see that form.",
          ];
        }
        return [
          "Ready to start your Plank!",
          "Assume the Plank position.",
        ];
      },

      FeedbackType.goalRepTargetMet: (event) => [
            "Target of {reps_goal} successful Plank holds achieved! 🎉 Amazing focus!",
            "You've completed {reps_goal} Plank holds! Fantastic work!",
          ],
      FeedbackType.goalHoldTimeMet: (event) => [
            "Hold Goal: {target_hold_s} reached (held {actual_hold_s})! 💪 Awesome Plank!",
            "You hit your {target_hold_s} Plank hold goal (actual: {actual_hold_s})! Excellent!",
          ],
    };

    return {...plankSpecificMessages, ...?externalCustomMessages};
  }

  static Map<FeedbackType, ExerciseFeedbackColor> _getMergedCustomColors(
      Map<FeedbackType, ExerciseFeedbackColor>? externalCustomColors) {
    final Map<FeedbackType, ExerciseFeedbackColor> plankSpecificColors = {
      // Setup
      FeedbackType.plankSetupSuccess:
          ExerciseFeedbackColor(const Color(0xFF00ACC1)),
      // New Setup Feedback Colors
      FeedbackType.plankSetupIncompleteLandmarks:
          ExerciseFeedbackColor(const Color(0xFFFF9800)),
      FeedbackType.plankSetupHipsTooHigh:
          ExerciseFeedbackColor(const Color(0xFFFFC107)),
      FeedbackType.plankSetupHipsTooLow:
          ExerciseFeedbackColor(const Color(0xFFFFC107)),
      FeedbackType.plankSetupHoldStraightPosition:
          ExerciseFeedbackColor(const Color(0xFF2196F3)),
      FeedbackType.plankSetupFaceUp:
          ExerciseFeedbackColor(const Color(0xFFFF9800)),
      FeedbackType.plankSetupFaceNotVisible:
          ExerciseFeedbackColor(const Color(0xFFFF9800)),

      // Execution - Correct
      FeedbackType.plankCorrectForm:
          ExerciseFeedbackColor(const Color(0xFF4CAF50)),
      FeedbackType.plankHoldingCorrectly:
          ExerciseFeedbackColor(const Color(0xFF2196F3)),

      // Execution - Corrections
      FeedbackType.plankHighHips:
          ExerciseFeedbackColor(const Color(0xFFFFC107)),
      FeedbackType.plankLowHips: ExerciseFeedbackColor(const Color(0xFFFFC107)),
      FeedbackType.plankFormIssueGeneric:
          ExerciseFeedbackColor(const Color(0xFFFF9800)),
      FeedbackType.plankAdjustingForm:
          ExerciseFeedbackColor(const Color(0xFFFF9800)),
      FeedbackType.plankTooFast: ExerciseFeedbackColor(const Color(0xFFFFC107)),

      // Execution - Encouragement/Neutral during execution
      FeedbackType.plankMaintainStraightLine:
          ExerciseFeedbackColor(const Color(0xFF00ACC1)),
      FeedbackType.plankEngageCore:
          ExerciseFeedbackColor(const Color(0xFF00ACC1)),
    };

    return {...plankSpecificColors, ...?externalCustomColors};
  }
}
