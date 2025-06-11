import 'dart:ui';

import '../../../../common_exercise/domain/entities/enums/feedback_type.dart';
import '../../../../common_exercise/domain/entities/exercise_feedback_color.dart';
import '../../../../common_exercise/domain/utils/feedback_provider.dart';

class GluteBridgeFeedbackProvider extends FeedbackProvider {
  GluteBridgeFeedbackProvider({
    Map<FeedbackType, MessageProvider>? customMessages,
    Map<FeedbackType, ExerciseFeedbackColor>? customColors,
  }) : super(
          exerciseName: "Glute Bridge",
          customMessages: _getMergedCustomMessages(customMessages),
          customColors: _getMergedCustomColors(customColors),
        );

  static Map<FeedbackType, MessageProvider> _getMergedCustomMessages(
      Map<FeedbackType, MessageProvider>? externalCustomMessages) {
    final Map<FeedbackType, MessageProvider> gluteBridgeSpecificMessages = {
      FeedbackType.setupInitialPrompt: (event) => [
            "Let's get started! Please lie on your back, ready for Glute Bridges."
          ],
      FeedbackType.setupPersonNotHorizontal: (event) => [
            "{guidance}",
            "To start, please lie down horizontally in the camera view."
          ],
      FeedbackType.setupHoldHorizontalOrientation: (event) =>
          ["Almost there! Hold that position for just a moment..."],
      FeedbackType.setupSupineCheckIncompleteLandmarks: (event) => [
            "I need a clearer view. Please make sure I can see your shoulders, hips, knees, and ankles."
          ],
      FeedbackType.setupSupineKneesNotBentEnough: (event) => [
            "Try bending your {side_name} a little more. Bring your foot closer to your hip."
          ],
      FeedbackType.setupSupineKneesTooStraight: (event) => [
            "Check your {side_name}. Your knee might be a bit too straight, or your foot too far out."
          ],
      FeedbackType.setupSupineShinPositionIncorrect: (event) => [
            "Check your {side_name}. Your shin should look mostly {orientation_name} in the camera (foot flat on the floor)."
          ],
      FeedbackType.setupSupineThighPositionIncorrect: (event) => [
            "Check your {side_name}. It should be angled up from your hip, as seen in the camera."
          ],
      FeedbackType.setupSupineAdjustGeneral: (event) => [
            "Adjust your {side_name}. Make sure your foot is flat on the floor and your knee is comfortably bent."
          ],
      FeedbackType.setupSupineHoldPosition: (event) => [
            "Looking good! Stay still on your back with your knees bent for a moment."
          ],
      FeedbackType.setupSuccess: (event) =>
          ["Perfect! Position looks great. Ready for your Glute Bridge!"],
      FeedbackType.exerciseLowerHipsShortHold: (event) {
        final repsCount = event.args?['reps_count'];
        final durationS = event.args?['duration_s'];
        final minHoldS = event.args?['min_hold_s'];

        if (repsCount != null && durationS != null) {
          return [
            "Rep {reps_count}! Good one ({duration_s}). Now, hips down.",
            "That's rep {reps_count} with a {duration_s} hold. Lower with control."
          ];
        } else if (minHoldS != null) {
          return [
            "Hips down. Next time, aim for at least {min_hold_s} in the 'up' position.",
            "Okay, come down. Try for {min_hold_s} at the top next time."
          ];
        }
        return [
          "Lower your hips. Aim for a longer hold next time.",
          "Controlled descent. A bit longer at the top if you can."
        ];
      },
      FeedbackType.exerciseTooFastTransition: (event) =>
          ["Hold that pose steady!", "A bit quick! Control the movement."],
      FeedbackType.gluteBridgeSqueezeGlutes: (event) => [
            "Remember to squeeze your glutes at the top!",
            "Squeeze more at the top for max effect!"
          ],
    };

    return {...gluteBridgeSpecificMessages, ...?externalCustomMessages};
  }

  static Map<FeedbackType, ExerciseFeedbackColor> _getMergedCustomColors(
      Map<FeedbackType, ExerciseFeedbackColor>? externalCustomColors) {
    final Map<FeedbackType, ExerciseFeedbackColor> gluteBridgeSpecificColors = {
      FeedbackType.errorNoPersonDetected:
          ExerciseFeedbackColor(const Color(0xFFFF9800)),
      FeedbackType.setupVisibilityBad:
          ExerciseFeedbackColor(const Color(0xFFFF9800)),
      FeedbackType.setupVisibilityPartial:
          ExerciseFeedbackColor(const Color(0xFFFF9800)),
      FeedbackType.setupSupineCheckIncompleteLandmarks:
          ExerciseFeedbackColor(const Color(0xFFFF9800)),
      FeedbackType.setupSuccess: ExerciseFeedbackColor(const Color(0xFF00ACC1)),
      FeedbackType.exerciseHoldingUpGoodDuration:
          ExerciseFeedbackColor(const Color(0xFF4CAF50)),
      FeedbackType.exerciseLowerHipsGoodRep:
          ExerciseFeedbackColor(const Color(0xFF4CAF50)),
      FeedbackType.exerciseLowerHipsShortHold:
          ExerciseFeedbackColor(const Color(0xFFFFC107)),
      FeedbackType.exerciseFormUnclearAdjust:
          ExerciseFeedbackColor(const Color(0xFFFFC107)),
      FeedbackType.exerciseFormUnclearWasUp:
          ExerciseFeedbackColor(const Color(0xFFFFC107)),
      FeedbackType.exerciseFormUnclearWasDown:
          ExerciseFeedbackColor(const Color(0xFFFFC107)),
      FeedbackType.exerciseTooFastTransition:
          ExerciseFeedbackColor(const Color(0xFFFFC107)),
      FeedbackType.goalRepMilestone:
          ExerciseFeedbackColor(const Color(0xFF2196F3)),
      FeedbackType.gluteBridgeSqueezeGlutes:
          ExerciseFeedbackColor(const Color(0xFF2196F3)),
    };

    return {...gluteBridgeSpecificColors, ...?externalCustomColors};
  }
}
