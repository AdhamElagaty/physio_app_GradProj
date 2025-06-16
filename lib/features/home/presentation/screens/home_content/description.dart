import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/core/common_widgets/excerices.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/font.dart';
import 'package:gradproject/core/utils/styles/icons.dart';
import 'package:gradproject/core/utils/widgets/nav_bar.dart';
import 'package:gradproject/features/camera_handling/presentation/cubit/camera_cubit.dart';
import 'package:gradproject/features/camera_handling/services/camera_service.dart';
import 'package:gradproject/features/exercise_flow_management/presentation/cubit/exercise_session_cubit.dart';
import 'package:gradproject/features/exercise_flow_management/presentation/screens/exercise_screen.dart';
import 'package:gradproject/features/common_exercise/domain/entities/enums/exercise_type.dart';
import 'package:gradproject/features/pose_detection_handling/services/pose_detection_service.dart';

class Description extends StatefulWidget {
  final String exerciseName;
  final String? categoryName;
  final String description;

  const Description({
    super.key,
    required this.exerciseName,
    required this.categoryName,
    required this.description,
  });

  @override
  State<Description> createState() => _DescriptionState();
}

class _DescriptionState extends State<Description> {
  late ExerciseType typeToPass;
  late String _imagePath;

  @override
  void initState() {
    super.initState();
    typeToPass = _getExerciseTypeFromName(widget.exerciseName);
    _imagePath = _getImagePathForExercise(widget.exerciseName);
  }

  ExerciseType _getExerciseTypeFromName(String name) {
    switch (name.toLowerCase()) {
      case 'bicep curls':
        return ExerciseType.bicepCurl;
      case 'glute bridges':
        return ExerciseType.gluteBridge;
      case 'plank':
        return ExerciseType.plank;
      default:
        debugPrint('Warning: Unknown exercise name: $name.');
        return ExerciseType.bicepCurl;
    }
  }

  String _getImagePathForExercise(String name) {
    try {
      final exercise = allExercises
          .firstWhere((ex) => ex.name.toLowerCase() == name.toLowerCase());
      return exercise.gifPath;
    } catch (e) {
      debugPrint(
          'Error: Exercise not found for name: $name. Using a placeholder.');

      return 'assets/placeholder.gif';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(22.w, 30.h, 22.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 34.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: AppIcon(AppIcons.arrow_left_bulk, size: 33.33.w),
                ),
                const Spacer(),
                Image.asset(
                  _imagePath,
                  width: 275.w,
                  height: 250.h,
                  // fallbackWidth: 275.w,
                  // fallbackHeight: 250.h,
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(widget.exerciseName, style: AppTextStyles.title),
            if (widget.categoryName != null)
              Text(widget.categoryName!, style: AppTextStyles.subTitle),
            SizedBox(height: 22.h),
            Expanded(
              child: Column(
                children: [
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 20.h),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Description', style: AppTextStyles.header),
                            SizedBox(height: 10.h),
                            Text(widget.description, style: AppTextStyles.body),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FilledButton(
                        onPressed: () {
                          if (!mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MultiBlocProvider(
                                providers: [
                                  BlocProvider(
                                    create: (_) => CameraCubit(CameraService())
                                      ..initializeCamera(),
                                  ),
                                  BlocProvider(
                                    create: (_) => ExerciseSessionCubit(
                                        PoseDetectionService()),
                                  ),
                                ],
                                child: ExerciseScreen(
                                  selectedExerciseType: typeToPass,
                                ),
                              ),
                            ),
                          );
                        },
                        child: const Text('Start'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
