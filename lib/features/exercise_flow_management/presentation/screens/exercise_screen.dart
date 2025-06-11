import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../../../core/common_widgets/loading_indicator.dart';
import '../../../pose_detection_handling/data/exceptions/pose_detection_exception.dart';
import '../../../../core/utils/camera_utils.dart';
import '../widgets/camera_view_widget.dart';
import '../widgets/exercise_controls_widget.dart';
import '../widgets/feedback_display_widget.dart';
import '../../../camera_handling/presentation/cubit/camera_cubit.dart';
import '../../../camera_handling/presentation/cubit/camera_state.dart';
import '../../../common_exercise/domain/entities/enums/exercise_type.dart';
import '../cubit/exercise_session_cubit.dart';
import '../cubit/exercise_session_state.dart';

class ExerciseScreen extends StatefulWidget {
  // We need to keep this parameter to receive the selected exercise type
  final ExerciseType selectedExerciseType;

  const ExerciseScreen({
    super.key,
    required this.selectedExerciseType, // This remains required
  });

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  // _selectedExercise is no longer needed as it will be read directly from widget.selectedExerciseType
  // ExerciseType _selectedExercise = ExerciseType.bicepCurl; // REMOVE THIS LINE
  bool _isProcessingFrame = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use the selectedExerciseType passed from the widget
      context
          .read<ExerciseSessionCubit>()
          .selectExercise(widget.selectedExerciseType);
    });
  }

  void _handleImageProcessing(CameraImage image) async {
    if (_isProcessingFrame) return;
    _isProcessingFrame = true;

    final cameraState = context.read<CameraCubit>().state;
    final exerciseCubit = context.read<ExerciseSessionCubit>();
    final sessionState = exerciseCubit.state;

    if (cameraState is! CameraReady ||
        sessionState is! ExerciseSessionInProgress) {
      _isProcessingFrame = false;
      return;
    }

    final inputImage = _createInputImage(cameraState.controller, image);
    if (inputImage == null) {
      _isProcessingFrame = false;
      return;
    }

    await _processPoseDetection(exerciseCubit, inputImage, cameraState);
    _isProcessingFrame = false;
  }

  InputImage? _createInputImage(
      CameraController controller, CameraImage image) {
    return inputImageFromCameraImage(
      image,
      controller.description,
    );
  }

  Future<void> _processPoseDetection(
    ExerciseSessionCubit exerciseCubit,
    InputImage inputImage,
    CameraReady cameraState,
  ) async {
    try {
      final poses =
          await exerciseCubit.poseDetectionService.processImage(inputImage);
      if (!mounted) return;

      final imageSize = Size(
        inputImage.metadata?.size.width.toDouble() ?? 0,
        inputImage.metadata?.size.height.toDouble() ?? 0,
      );

      exerciseCubit.processFrameData(
        poses: poses,
        imageSize: imageSize,
        imageRotation: context.read<CameraCubit>().getRotation(),
        isFrontCamera: cameraState.isFrontCamera,
      );
    } on PoseDetectionException catch (e) {
      if (!mounted) return;
      exerciseCubit.handleProcessingError(e);
    } catch (e, stackTrace) {
      if (!mounted) return;
      exerciseCubit.handleProcessingError(
        PoseDetectionException(e, stackTrace),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Display the name of the exercise in the AppBar
        title: Text('${_formatExerciseName(widget.selectedExerciseType)}'),
        actions: [_buildCameraSwitchButton()],
      ),
      body: BlocListener<ExerciseSessionCubit, ExerciseSessionState>(
        listener: _handleExerciseError,
        child: Stack(
          children: [
            _buildCameraView(),
            Column(
              children: [
                // _buildExerciseSelector(), // REMOVED THIS WIDGET CALL
                const Spacer(),
                _buildFeedbackSection(),
                _buildExerciseControls(),
                const SizedBox(height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraSwitchButton() {
    return IconButton(
      icon: const Icon(Icons.flip_camera_ios_outlined),
      onPressed: () => _handleCameraSwitch(),
    );
  }

  void _handleCameraSwitch() {
    final exerciseState = context.read<ExerciseSessionCubit>().state;
    if (exerciseState is ExerciseSessionInProgress) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Stop exercise before switching camera.")),
      );
    } else {
      context.read<CameraCubit>().switchCamera();
    }
  }

  Widget _buildCameraView() {
    return BlocBuilder<CameraCubit, CameraState>(
      builder: (context, cameraState) {
        if (cameraState is CameraReady) {
          return BlocBuilder<ExerciseSessionCubit, ExerciseSessionState>(
            builder: (context, exerciseState) {
              return CameraViewWidget(
                cameraController: cameraState.controller,
                painter: _getPainter(exerciseState, cameraState),
              );
            },
          );
        }
        return _handleCameraState(cameraState);
      },
    );
  }

  CustomPainter? _getPainter(
    ExerciseSessionState exerciseState,
    CameraReady cameraState,
  ) {
    if (exerciseState is! ExerciseSessionInProgress) return null;
    if (exerciseState.latestPosesForPainter == null ||
        exerciseState.latestImageSizeForPainter == null) {
      return null;
    }

    return exerciseState.trainer.getPainter(
      exerciseState.latestPosesForPainter!,
      exerciseState.latestImageSizeForPainter!,
      context.read<CameraCubit>().getRotation(),
      cameraState.isFrontCamera,
    );
  }

  Widget _handleCameraState(CameraState state) {
    if (state is CameraLoading) {
      return const CenteredLoadingIndicator(message: "Initializing Camera...");
    }
    if (state is CameraFailure) {
      return Center(
          child: Text("Camera Error: ${state.error}",
              style: const TextStyle(color: Colors.red)));
    }
    return const Center(child: Text("Camera not ready."));
  }

  // _buildExerciseSelector() is REMOVED
  /*
  Widget _buildExerciseSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: DropdownButtonFormField<ExerciseType>(
          decoration: InputDecoration(
            labelText: 'Select Exercise',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.fitness_center,
                color: Theme.of(context).primaryColor),
          ),
          value: _selectedExercise,
          items: ExerciseType.values.map(_buildDropdownItem).toList(),
          onChanged: _handleExerciseChange,
        ),
      ),
    );
  }
  */

  DropdownMenuItem<ExerciseType> _buildDropdownItem(ExerciseType type) {
    return DropdownMenuItem<ExerciseType>(
      value: type,
      child: Text(_formatExerciseName(type)),
    );
  }

  String _formatExerciseName(ExerciseType type) {
    return type
        .toString()
        .split('.')
        .last
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
        .trim();
  }

  // _handleExerciseChange is no longer needed as the dropdown is removed
  /*
  void _handleExerciseChange(ExerciseType? newValue) {
    if (newValue == null) return;

    final exerciseCubit = context.read<ExerciseSessionCubit>();
    if (exerciseCubit.state is ExerciseSessionInProgress) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Stop current exercise before switching.")),
      );
      return;
    }

    setState(() => _selectedExercise = newValue);
    exerciseCubit.selectExercise(newValue);
  }
  */

  Widget _buildFeedbackSection() {
    return BlocBuilder<ExerciseSessionCubit, ExerciseSessionState>(
      builder: (context, state) {
        return FeedbackDisplayWidget(
          exerciseResult:
              state is ExerciseSessionInProgress ? state.lastResult : null,
        );
      },
    );
  }

  Widget _buildExerciseControls() {
    return BlocBuilder<ExerciseSessionCubit, ExerciseSessionState>(
      builder: (context, state) {
        return ExerciseControlsWidget(
          onStartPause: () => _handleExerciseControl(state),
          onReset: () => _handleReset(),
          isExercising: state is ExerciseSessionInProgress,
          canStart: state is ExerciseSessionReady,
        );
      },
    );
  }

  void _handleExerciseControl(ExerciseSessionState state) {
    final exerciseCubit = context.read<ExerciseSessionCubit>();
    final cameraCubit = context.read<CameraCubit>();

    if (state is ExerciseSessionInProgress) {
      cameraCubit.stopImageStream();
      exerciseCubit.stopExercise();
    } else if (state is ExerciseSessionReady) {
      exerciseCubit.startExercise();
      cameraCubit.startImageStream(_handleImageProcessing);
    }
  }

  void _handleReset() {
    context.read<ExerciseSessionCubit>().resetExercise();
    if (context.read<ExerciseSessionCubit>().state
        is! ExerciseSessionInProgress) {
      context.read<CameraCubit>().stopImageStream();
    }
  }

  void _handleExerciseError(BuildContext context, ExerciseSessionState state) {
    if (state is ExerciseSessionError) {
      final errorMessage = state.errorDetails != null
          ? '${state.message}\nDetails: ${state.errorDetails}'
          : state.message;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );

      // Stop processing if there's a critical error
      if (state.errorDetails?.contains('disposed') ?? false) {
        context.read<CameraCubit>().stopImageStream();
      }
    }
  }
}
