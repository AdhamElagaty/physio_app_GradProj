import 'feedback_category.dart';

enum FeedbackType {
  // --- Generic ---
  neutralProcessing,
  errorModelNotReady,
  errorPredictionFailed,
  errorNoPersonDetected,
  infoTrackerReset,

  // --- Setup Phase ---
  setupInitialPrompt,
  setupVisibilityBad,
  setupVisibilityPartial,
  setupPhoneOrientationIssue,
  setupPhoneAccelerometerWait,
  setupPersonNotHorizontal,
  setupHoldHorizontalOrientation,
  setupSupineCheckIncompleteLandmarks,
  setupSupineKneesNotBentEnough,
  setupSupineKneesTooStraight,
  setupSupineShinPositionIncorrect,
  setupSupineThighPositionIncorrect,
  setupSupineAdjustGeneral,
  setupSupineHoldPosition,
  setupSuccess,

  // --- Exercise Execution ---
  exerciseLiftHips,
  exerciseHoldingUp,
  exerciseHoldingUpGoodDuration,
  exerciseLowerHipsGoodRep,
  exerciseLowerHipsShortHold,
  exerciseDownPositionReady,
  exerciseFormUnclearAdjust,
  exerciseFormUnclearWasUp,
  exerciseFormUnclearWasDown,
  exerciseTooFastTransition,
  exerciseStartFromDownPosition, // Added

  // --- Trainer Goals & Milestones ---
  goalRepTargetMet,
  goalRepTargetMetNewGoal,
  goalRepExceeded,
  goalRepMilestone,
  goalHoldTimeMet,
  goalHoldTimeMetNewGoal,

  // --- Specific Glute Bridge Cues (can be expanded) ---
  gluteBridgeSqueezeGlutes,
  gluteBridgeAvoidArchingBack,

  // --- Bicep Curl Specific ---
  bicepCurlSetupInitialPrompt,
  bicepCurlSetupPersonNotVertical,
  bicepCurlSetupHoldVerticalOrientation,
  bicepCurlSetupVisibilityBad,
  bicepCurlSetupSuccess,
  bicepCurlErrorNoPersonDetected,

  bicepCurlLeftArmRepCounted,
  bicepCurlRightArmRepCounted,
  bicepCurlLeftArmSlowDown,
  bicepCurlRightArmSlowDown,
  bicepCurlLeftArmBeMoreFluid,
  bicepCurlRightArmBeMoreFluid,
  bicepCurlLeftArmFocusOnForm,
  bicepCurlRightArmFocusOnForm,
  bicepCurlLeftArmGoodRep,
  bicepCurlRightArmGoodRep,
  bicepCurlLeftArmKeepShoulderStill,
  bicepCurlRightArmKeepShoulderStill,
  bicepCurlLeftArmKeepBackStraight,
  bicepCurlRightArmKeepBackStraight,
  bicepCurlLeftArmExtendFully,
  bicepCurlRightArmExtendFully,
  bicepCurlLeftArmCurlHigher,
  bicepCurlRightArmCurlHigher,
  bicepCurlLeftArmGoodForm,
  bicepCurlRightArmGoodForm,
  bicepCurlLeftArmMoveInView,
  bicepCurlRightArmMoveInView,
  bicepCurlFormIssueResettingState,
  bicepCurlEncourage,

  bicepCurlGoalRepTargetMet,
  bicepCurlGoalRepTargetMetNewGoal,
  bicepCurlGoalRepExceeded,
  bicepCurlGoalRepMilestone,
  bicepCurlInfoTrackerReset,
  bicepCurlProcessingPosition,
  bicepCurlMoveIntoView,
  bicepCurlPleaseStepIntoFrame,

// --- Plank Specific ---
  plankSetupInitialPrompt,
  plankSetupSuccess,
  plankSetupIncompleteLandmarks,
  plankSetupHipsTooHigh,
  plankSetupHipsTooLow,
  plankSetupHoldStraightPosition,
  plankSetupFaceUp,
  plankSetupFaceNotVisible,

  plankCorrectForm,
  plankHighHips,
  plankLowHips,
  plankMaintainStraightLine,
  plankEngageCore,
  plankFormIssueGeneric,
  plankHoldingCorrectly,
  plankAdjustingForm,
  plankTooFast,
}

extension FeedbackTypeExtension on FeedbackType {
  FeedbackCategory get category {
    switch (this) {
      // --- Generic ---
      case FeedbackType.neutralProcessing:
        return FeedbackCategory.processing;
      case FeedbackType.errorModelNotReady:
      case FeedbackType.errorPredictionFailed:
      case FeedbackType.errorNoPersonDetected:
        return FeedbackCategory.error;
      case FeedbackType.infoTrackerReset:
        return FeedbackCategory.info;

      // --- Setup Phase ---
      case FeedbackType.setupInitialPrompt:
      case FeedbackType.setupVisibilityBad:
      case FeedbackType.setupVisibilityPartial:
      case FeedbackType.setupPhoneOrientationIssue:
      case FeedbackType.setupPhoneAccelerometerWait:
      case FeedbackType.setupPersonNotHorizontal:
      case FeedbackType.setupHoldHorizontalOrientation:
      case FeedbackType.setupSupineCheckIncompleteLandmarks:
      case FeedbackType.setupSupineKneesNotBentEnough:
      case FeedbackType.setupSupineKneesTooStraight:
      case FeedbackType.setupSupineShinPositionIncorrect:
      case FeedbackType.setupSupineThighPositionIncorrect:
      case FeedbackType.setupSupineAdjustGeneral:
      case FeedbackType.setupSupineHoldPosition:
      case FeedbackType.setupSuccess:
        return FeedbackCategory.setup;

      // --- Exercise Execution ---
      case FeedbackType.exerciseLiftHips:
      case FeedbackType.exerciseHoldingUp:
      case FeedbackType.exerciseHoldingUpGoodDuration:
      case FeedbackType.exerciseLowerHipsGoodRep:
      case FeedbackType.exerciseLowerHipsShortHold:
      case FeedbackType.exerciseDownPositionReady:
      case FeedbackType.exerciseFormUnclearAdjust:
      case FeedbackType.exerciseFormUnclearWasUp:
      case FeedbackType.exerciseFormUnclearWasDown:
      case FeedbackType.exerciseTooFastTransition:
      case FeedbackType.exerciseStartFromDownPosition: // Added
        return FeedbackCategory.execution;

      // --- Trainer Goals & Milestones ---
      case FeedbackType.goalRepTargetMet:
      case FeedbackType.goalRepTargetMetNewGoal:
      case FeedbackType.goalRepExceeded:
      case FeedbackType.goalRepMilestone:
      case FeedbackType.goalHoldTimeMet:
      case FeedbackType.goalHoldTimeMetNewGoal:
        return FeedbackCategory.goal;

      // --- Specific Glute Bridge ---
      case FeedbackType.gluteBridgeSqueezeGlutes:
      case FeedbackType.gluteBridgeAvoidArchingBack:
        return FeedbackCategory.execution; 

      // --- Bicep Curl Specific ---
      case FeedbackType.bicepCurlSetupInitialPrompt:
      case FeedbackType.bicepCurlSetupPersonNotVertical:
      case FeedbackType.bicepCurlSetupHoldVerticalOrientation:
      case FeedbackType.bicepCurlSetupVisibilityBad:
      case FeedbackType.bicepCurlSetupSuccess:
        return FeedbackCategory.setup;

      case FeedbackType.bicepCurlErrorNoPersonDetected:
        return FeedbackCategory.error;

      case FeedbackType.bicepCurlLeftArmRepCounted:
      case FeedbackType.bicepCurlRightArmRepCounted:
      case FeedbackType.bicepCurlLeftArmSlowDown:
      case FeedbackType.bicepCurlRightArmSlowDown:
      case FeedbackType.bicepCurlLeftArmBeMoreFluid:
      case FeedbackType.bicepCurlRightArmBeMoreFluid:
      case FeedbackType.bicepCurlLeftArmFocusOnForm:
      case FeedbackType.bicepCurlRightArmFocusOnForm:
      case FeedbackType.bicepCurlLeftArmGoodRep:
      case FeedbackType.bicepCurlRightArmGoodRep:
      case FeedbackType.bicepCurlLeftArmKeepShoulderStill:
      case FeedbackType.bicepCurlRightArmKeepShoulderStill:
      case FeedbackType.bicepCurlLeftArmKeepBackStraight:
      case FeedbackType.bicepCurlRightArmKeepBackStraight:
      case FeedbackType.bicepCurlLeftArmExtendFully:
      case FeedbackType.bicepCurlRightArmExtendFully:
      case FeedbackType.bicepCurlLeftArmCurlHigher:
      case FeedbackType.bicepCurlRightArmCurlHigher:
      case FeedbackType.bicepCurlLeftArmGoodForm:
      case FeedbackType.bicepCurlRightArmGoodForm:
      case FeedbackType.bicepCurlFormIssueResettingState:
      case FeedbackType.bicepCurlEncourage:
        return FeedbackCategory.execution;

      case FeedbackType.bicepCurlLeftArmMoveInView:
      case FeedbackType.bicepCurlRightArmMoveInView:
      case FeedbackType.bicepCurlMoveIntoView:
      case FeedbackType.bicepCurlPleaseStepIntoFrame:
        return FeedbackCategory.info;

      case FeedbackType.bicepCurlGoalRepTargetMet:
      case FeedbackType.bicepCurlGoalRepTargetMetNewGoal:
      case FeedbackType.bicepCurlGoalRepExceeded:
      case FeedbackType.bicepCurlGoalRepMilestone:
        return FeedbackCategory.goal;

      case FeedbackType.bicepCurlInfoTrackerReset:
        return FeedbackCategory.info;
      case FeedbackType.bicepCurlProcessingPosition:
        return FeedbackCategory.processing;

      // --- Plank Specific Setup ---
      case FeedbackType.plankSetupInitialPrompt:
      case FeedbackType.plankSetupSuccess:
      case FeedbackType.plankSetupIncompleteLandmarks:
      case FeedbackType.plankSetupHipsTooHigh:
      case FeedbackType.plankSetupHipsTooLow:
      case FeedbackType.plankSetupHoldStraightPosition:
      case FeedbackType.plankSetupFaceUp:
      case FeedbackType.plankSetupFaceNotVisible:
        return FeedbackCategory.setup;

      // --- Plank Exercise Execution ---
      case FeedbackType.plankCorrectForm:
      case FeedbackType.plankHighHips:
      case FeedbackType.plankLowHips:
      case FeedbackType.plankMaintainStraightLine:
      case FeedbackType.plankEngageCore:
      case FeedbackType.plankFormIssueGeneric:
      case FeedbackType.plankHoldingCorrectly:
      case FeedbackType.plankAdjustingForm:
      case FeedbackType.plankTooFast:
        return FeedbackCategory.execution;
    }
  }
}