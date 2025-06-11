import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui'; 

import '../entities/enums/feedback_category.dart';
import '../entities/enums/feedback_type.dart';
import '../entities/exercise_feedback.dart';
import '../entities/exercise_feedback_color.dart';
import '../entities/feedback_event.dart';

typedef MessageProvider = List<String> Function(FeedbackEvent event);

abstract class FeedbackProvider {
  static final math.Random _random = math.Random();

  final String exerciseName;
  final Map<FeedbackType, MessageProvider>? _customMessages;
  final Map<FeedbackType, ExerciseFeedbackColor>? _customColors;

  final ExerciseFeedbackColor defaultErrorColor;
  final ExerciseFeedbackColor defaultSetupColor;
  final ExerciseFeedbackColor defaultGoalColor;
  final ExerciseFeedbackColor defaultExerciseColor;
  final ExerciseFeedbackColor defaultInfoColor;
  final ExerciseFeedbackColor defaultNeutralColor;

  String? _lastSelectedMessageTemplate;
  DateTime? _lastStickyMessageChangeTimestamp;
  FeedbackEvent? _eventForLastStickyMessage;

  static const Duration _stickyRefreshInterval = Duration(seconds: 10);

  late final Map<FeedbackType, MessageProvider> _genericDefaultMessages;

  FeedbackProvider({
    required this.exerciseName,
    Map<FeedbackType, MessageProvider>? customMessages,
    Map<FeedbackType, ExerciseFeedbackColor>? customColors,
    ExerciseFeedbackColor? defaultErrorTextColor,
    ExerciseFeedbackColor? defaultSetupTextColor,
    ExerciseFeedbackColor? defaultGoalTextColor,
    ExerciseFeedbackColor? defaultExerciseTextColor,
    ExerciseFeedbackColor? defaultInfoTextColor,
    ExerciseFeedbackColor? defaultNeutralTextColor,
  })  : defaultErrorColor = defaultErrorTextColor ?? ExerciseFeedbackColor(const Color.fromARGB(255, 223, 46, 46)),
        defaultSetupColor = defaultSetupTextColor ?? ExerciseFeedbackColor(const Color(0xFFFFC107)),
        defaultGoalColor = defaultGoalTextColor ?? ExerciseFeedbackColor(const Color(0xFF4CAF50)),
        defaultExerciseColor = defaultExerciseTextColor ?? ExerciseFeedbackColor(const Color(0xFF2196F3)),
        defaultInfoColor = defaultInfoTextColor ?? ExerciseFeedbackColor(const Color(0xFF00ACC1)),
        defaultNeutralColor = defaultNeutralTextColor ?? ExerciseFeedbackColor(const Color(0xFF9E9E9E)),
        _customMessages = customMessages,
        _customColors = customColors {
    _initializeGenericDefaultMessages();
  }

  void _initializeGenericDefaultMessages() {
    _genericDefaultMessages = {
      FeedbackType.neutralProcessing: (event) => [
            "Hang tight, I'm analyzing...",
            "Processing your form...",
            "Just a sec..."
          ],
      FeedbackType.errorModelNotReady: (event) => [
            "The AI is still getting ready. Give it a moment, please.",
            "Almost there! The AI is just warming up.",
            "Hold on, the system is initializing..."
          ],
      FeedbackType.errorPredictionFailed: (event) => [
            "{error}",
            "Whoops! Had a slight issue there. Let's try again.",
            "Hmm, something went a bit sideways with the analysis. Can we retry?",
            "A little hiccup on my end. Let's give that another go."
          ],
      FeedbackType.errorNoPersonDetected: (event) => [
            "I can't seem to see you. Please make sure you're fully in the camera's view.",
            "Are you there? I'm not detecting anyone. Step into the frame!",
            "Make sure you're in the camera view so I can see you."
          ],
      FeedbackType.infoTrackerReset: (event) => [
            "Tracker reset! Let's get you set up for $exerciseName again.",
            "Okay, starting fresh with the tracker for $exerciseName.",
            "Reset complete! Ready to set up for $exerciseName."
          ],
      FeedbackType.setupInitialPrompt: (event) => [
            "Alright, let's get you set up for the $exerciseName. Find your starting position!",
            "Ready to begin? Get into the starting pose for $exerciseName.",
            "Let's do this! Assume the starting position for $exerciseName."
          ],
      FeedbackType.setupVisibilityBad: (event) => [
            "I can't quite see all of you. Could you adjust so your whole body is in view?",
            "Make sure your entire body is visible to the camera, please.",
            "Just a little adjustment – I need to see your full form."
          ],
      FeedbackType.setupVisibilityPartial: (event) => [
            "Need a clearer view, please. Ensure your whole body is well lit and in frame.",
            "I'm having trouble seeing you clearly. Check your lighting and camera angle.",
            "Can you adjust so I get a better look? Your whole body needs to be visible."
          ],
      FeedbackType.setupPhoneOrientationIssue: (event) => [
            "{guidance}",
            "Your phone seems a bit unstable. A steady phone helps me see you better!",
            "Is the camera blocked or wobbly? Try to keep it still for a clear view.",
            "For best results, make sure your phone is stable and the camera isn't covered."
          ],
      FeedbackType.setupPhoneAccelerometerWait: (event) => [
            "Checking phone stability... Hold still for a moment.",
            "Just a sec, verifying your phone's orientation...",
            "Making sure your phone is steady..."
          ],
      FeedbackType.setupSuccess: (event) => [
            "Awesome! Your starting position for $exerciseName looks great. Let's go!",
            "Perfect setup! Ready to start the $exerciseName when you are.",
            "Nailed the starting pose! Let's begin the $exerciseName."
          ],
      FeedbackType.exerciseLiftHips: (event) => [
            "Time to lift! Engage those muscles.",
            "Up you go! Focus on a controlled movement.",
            "Lift! Power through it."
          ],
      FeedbackType.exerciseHoldingUp: (event) => [
            "Keep holding... {duration_s}! You're doing great.",
            "Hold that position! {duration_s}. Stay strong!",
            "Excellent focus! Holding for {duration_s}. Almost there!"
          ],
      FeedbackType.exerciseHoldingUpGoodDuration: (event) => [
            "Fantastic hold for {duration_s}! 💪 That's the way!",
            "Excellent work! You held that for {duration_s}!",
            "Superb! {duration_s} held strong. Keep that intensity!"
          ],
      FeedbackType.exerciseLowerHipsGoodRep: (event) => [
            "Rep {reps_count} complete! Great hold for {duration_s}. Now, lower with control.",
            "Nice one! That's rep {reps_count} with a {duration_s} hold. Gently bring it down.",
            "Solid rep ({reps_count})! Held for {duration_s}. Controlled movement on the way down."
          ],
      FeedbackType.exerciseLowerHipsShortHold: (event) {
        final r = event.args?['reps_count'];
        final durSec = event.args?['duration_s'];
        final minHSec = event.args?['min_hold_s'];

        if (r != null && durSec != null) {
          return [
            "Good rep ({reps_count})! That was {duration_s}. Lower down now.",
            "Rep {reps_count} counted ({duration_s} hold). Controlled descent, please."
          ];
        } else if (minHSec != null) {
          return [
            "Lower down. For the next one, try to hold the top for at least {min_hold_s}.",
            "Okay, come on down. Aim for a {min_hold_s} hold next time."
          ];
        }
        return [
          "Controlled descent. Try for a longer hold at the top next rep.",
          "Ease it down. A little longer at the top next time if you can."
        ];
      },
      FeedbackType.exerciseDownPositionReady: (event) {
          final bool? isFirstTime = event.args?['is_first_time'];

          if (isFirstTime == null) return ["Alright, let's go!"];

          if (isFirstTime){
            return [
              "Welcome! Get ready for your very first try!",
              "This is it – the beginning! Prepare to engage.",
              "Alright, first time's a charm! Let's get started!"
            ];
          }else{
            return [
              "Back to the start. Get ready for the next one!",
              "You're in the starting position. Let's go again!",
              "Ready for another? Prepare to engage."
            ];
          }
      },
      FeedbackType.exerciseFormUnclearAdjust: (event) => [
            "Hmm, your form isn't quite clear. Try to get back into the correct $exerciseName position.",
            "I've lost track of your form. Can you readjust to the $exerciseName starting or active pose?",
            "Let's reset that form. Please adjust back into the $exerciseName position."
          ],
      FeedbackType.exerciseFormUnclearWasUp: (event) => [
            "You were just in the 'up' position! I've lost your form a bit. Please readjust.",
            "Looked good up there! Now your form is a bit unclear. Get back into a clear position, please.",
            "Hold on, you were up. Now I can't quite see your form. Adjust and let's continue."
          ],
      FeedbackType.exerciseFormUnclearWasDown: (event) => [
            "You were just in the 'down' position. Now it's a bit unclear. Readjust into the $exerciseName form.",
            "Okay, you were down. Now I'm not sure about your pose. Please get back into position.",
            "Form check! You were in the starting/down pose, but now it's unclear. Adjust please."
          ],
      FeedbackType.exerciseTooFastTransition: (event) => [
            "Easy does it! Control the movement.",
            "A bit too quick there! Focus on a steady pace.",
            "Slow it down a little. Quality over speed!"
          ],
      FeedbackType.exerciseStartFromDownPosition: (event) => [
            "Please start from the down position first.",
            "Let's begin from the starting (down) position.",
            "Make sure you're in the down position to start the rep."
          ],
      FeedbackType.goalRepTargetMet: (event) => [
            "Rep Goal: {reps_goal} reps! You hit it! Fantastic! 🎉",
            "That's {reps_goal} reps! Goal achieved! Awesome work!",
            "Yes! {reps_goal} reps completed. You nailed your goal!"
          ],
      FeedbackType.goalRepTargetMetNewGoal: (event) => [
            "Goal of {reps_achieved} reps met! 🎉 Great job! New target: {new_reps_goal} reps. Let's go!",
            "You crushed {reps_achieved} reps! Amazing! Now aiming for {new_reps_goal}. You've got this!",
            "{reps_achieved} reps done! Excellent! Let's push for {new_reps_goal} reps next!"
          ],
      FeedbackType.goalRepExceeded: (event) => [
            "Wow, {reps_over_count} reps over your goal! You're on fire! 🔥",
            "Amazing! {reps_over_count} extra reps! You're really pushing it!",
            "Unstoppable! That's {reps_over_count} reps beyond your target!"
          ],
      FeedbackType.goalRepMilestone: (event) => [
            "That's {reps_milestone} reps! Great milestone. Keep that momentum!",
            "{reps_milestone} reps! Fantastic progress. Keep it up!",
            "Solid work hitting {reps_milestone} reps! Let's see how many more you can do!"
          ],
      FeedbackType.goalHoldTimeMet: (event) => [
            "Hold Goal: {target_hold_s}! You did it, holding for {actual_hold_s}! 💪 Great job!",
            "Target hold of {target_hold_s} met! You held for {actual_hold_s}! Excellent!",
            "Fantastic! You achieved the {target_hold_s} hold goal, actual {actual_hold_s}!"
          ],
      FeedbackType.goalHoldTimeMetNewGoal: (event) => [
            "{target_hold_s} hold goal achieved (held {actual_hold_s})! 💪 Awesome! New target: {new_target_hold_s}. Challenge accepted?",
            "You nailed the {target_hold_s} hold (actual {actual_hold_s})! Ready for more? New goal: {new_target_hold_s}!",
            "Great work hitting the {target_hold_s} hold (you did {actual_hold_s})! Let's aim for {new_target_hold_s} next!"
          ],
    };
  }

  void resetStickyState() {
    _lastSelectedMessageTemplate = null;
    _lastStickyMessageChangeTimestamp = null;
    _eventForLastStickyMessage = null;
  }

  ExerciseFeedback getFeedback(FeedbackEvent event) {
    String finalMessageText;
    ExerciseFeedbackColor currentExerciseColor;

    final eventCategory = event.type.category;
    switch (eventCategory) {
      case FeedbackCategory.error:
        currentExerciseColor = defaultErrorColor;
        break;
      case FeedbackCategory.setup:
        currentExerciseColor = defaultSetupColor;
        break;
      case FeedbackCategory.goal:
        currentExerciseColor = defaultGoalColor;
        break;
      case FeedbackCategory.execution:
        currentExerciseColor = defaultExerciseColor;
        break;
      case FeedbackCategory.info:
        currentExerciseColor = defaultInfoColor;
        break;
      case FeedbackCategory.processing:
        currentExerciseColor = defaultNeutralColor;
        break;
    }

    // Create ExerciseColor object
    ExerciseFeedbackColor feedbackColor = currentExerciseColor;

    // Override with custom color if available
    if (_customColors?.containsKey(event.type) ?? false) {
      feedbackColor = _customColors![event.type]!;
    }

    final now = DateTime.now();
    bool isContinuingStickySeries = _eventForLastStickyMessage != null &&
                                    _eventForLastStickyMessage!.type == event.type;

    MessageProvider? messageListProvider;
    if (_customMessages?.containsKey(event.type) ?? false) {
      messageListProvider = _customMessages![event.type]!;
    } else if (_genericDefaultMessages.containsKey(event.type)) {
      messageListProvider = _genericDefaultMessages[event.type]!;
    }

    String selectedRawTemplate;

    if (messageListProvider != null) {
      final options = messageListProvider(event);

      if (options.isEmpty) {
        selectedRawTemplate = "";
        _lastSelectedMessageTemplate = null;
        _eventForLastStickyMessage = null;
        _lastStickyMessageChangeTimestamp = null;
      } else if (options.length == 1) {
        selectedRawTemplate = options.first;
        if (_lastSelectedMessageTemplate != selectedRawTemplate || !isContinuingStickySeries) {
          _lastStickyMessageChangeTimestamp = now;
        }
        _lastSelectedMessageTemplate = selectedRawTemplate;
        _eventForLastStickyMessage = event;
      } else {
        bool stickWithCurrent = isContinuingStickySeries &&
            _lastSelectedMessageTemplate != null &&
            options.contains(_lastSelectedMessageTemplate!) &&
            _lastStickyMessageChangeTimestamp != null &&
            now.difference(_lastStickyMessageChangeTimestamp!) <= _stickyRefreshInterval;

        if (stickWithCurrent) {
          selectedRawTemplate = _lastSelectedMessageTemplate!;
        } else {
          if (isContinuingStickySeries &&
              _lastSelectedMessageTemplate != null &&
              _lastStickyMessageChangeTimestamp != null &&
              now.difference(_lastStickyMessageChangeTimestamp!) > _stickyRefreshInterval) {
            List<String> eligibleOptions = options.where((o) => o != _lastSelectedMessageTemplate).toList();
            if (eligibleOptions.isNotEmpty) {
              selectedRawTemplate = eligibleOptions[_random.nextInt(eligibleOptions.length)];
            } else {
              selectedRawTemplate = options[_random.nextInt(options.length)];
            }
          } else {
            selectedRawTemplate = options[_random.nextInt(options.length)];
          }
          _lastSelectedMessageTemplate = selectedRawTemplate;
          _lastStickyMessageChangeTimestamp = now;
          _eventForLastStickyMessage = event;
        }
      }
    } else {
      selectedRawTemplate = "Unknown feedback event: {type_name}";
      log("FeedbackProvider: No message provider for ${event.type} in $exerciseName. Using fallback.");
      _lastSelectedMessageTemplate = null;
      _eventForLastStickyMessage = null;
      _lastStickyMessageChangeTimestamp = null;
    }

    finalMessageText = selectedRawTemplate;
    if (selectedRawTemplate == "Unknown feedback event: {type_name}") {
        finalMessageText = finalMessageText.replaceAll('{type_name}', event.type.toString());
    } else if (event.args != null) {
      event.args!.forEach((key, value) {
        finalMessageText = finalMessageText.replaceAll('{$key}', value.toString());
      });
    }
    if (finalMessageText.contains("{error}") && (event.args?['error'] == null && event.type == FeedbackType.errorPredictionFailed)){
        finalMessageText = finalMessageText.replaceAll("{error}", "Whoops! Had a slight issue there. Let's try again.");
    }
    if (finalMessageText.contains("{guidance}") && (event.args?['guidance'] == null && event.type == FeedbackType.setupPhoneOrientationIssue)){
        finalMessageText = finalMessageText.replaceAll("{guidance}", "Your phone seems a bit unstable. A steady phone helps me see you better!");
    }

    return ExerciseFeedback(finalMessageText, feedbackColor, event.type.category);
  }
}