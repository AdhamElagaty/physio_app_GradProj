import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/font.dart';
import 'package:gradproject/core/utils/styles/icons.dart';
import 'package:gradproject/core/utils/widgets/nav_bar.dart';
import 'package:gradproject/features/camera_handling/presentation/cubit/camera_cubit.dart';
import 'package:gradproject/features/camera_handling/services/camera_service.dart';
import 'package:gradproject/features/exercise_flow_management/presentation/cubit/exercise_session_cubit.dart';
import 'package:gradproject/features/exercise_flow_management/presentation/screens/exercise_screen.dart';
import 'package:gradproject/features/pose_detection_handling/services/pose_detection_service.dart';
import 'package:gradproject/features/common_exercise/domain/entities/enums/exercise_type.dart'; // <--- Import ExerciseType

class Description extends StatelessWidget {
  final String exerciseName;
  final String? categoryName;
  final String description;

  const Description({
    super.key,
    required this.exerciseName,
    required this.categoryName,
    required this.description,
  });

  // Helper function to convert String exerciseName to ExerciseType
  ExerciseType _getExerciseTypeFromName(String name) {
    switch (name.toLowerCase()) {
      case 'bicep curls':
        return ExerciseType.bicepCurl;
      case 'glute bridges':
        return ExerciseType.gluteBridge;
      case 'plank':
        return ExerciseType.plank;
      // You must add a case for every exercise name you have in your allExercises list
      // and map it to its corresponding ExerciseType.
      // If no match is found, you might want to return a default or throw an error.
      // For now, let's default to bicepCurl for unknown types to prevent immediate crashes.
      // case 'push-ups': // Assuming 'push-ups' should map to 'plank' for now, or create new enum
      //   return ExerciseType.plank;
      // case 'squats': // Assuming 'squats' should map to 'gluteBridge' for now, or create new enum
      //   return ExerciseType.gluteBridge;
      default:
        // Handle cases where an exerciseName doesn't have a direct ExerciseType mapping
        // You might want to log this or show an error to the user.
        debugPrint('Warning: Unknown exercise name: $name.');
        return ExerciseType.bicepCurl;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the ExerciseType based on the exerciseName
    final ExerciseType typeToPass = _getExerciseTypeFromName(exerciseName);

    List<String> navIcons = [
      AppIcons.home,
      AppIcons.tick_square,
      AppIcons.chat,
      AppIcons.notification,
      AppIcons.setting,
    ];

    return Scaffold(
      bottomNavigationBar: NavBar(
        selectedIndex: 0,
        color: AppColors.teal,
        navItems: List.generate(5, (index) {
          return NavItem(
            icon: AppIcon(navIcons[index].replaceAll('Bold', 'Bulk')),
            selectedIcon: AppIcon(
              navIcons[index],
              color: AppColors.teal,
              size: 31.68.w,
            ),
          );
        }),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(22.w, 30.h, 22.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 34.h,),
            // Header & Image
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: AppIcon(AppIcons.arrow_left_bulk, size: 33.33.w),
                ),
                const Spacer(),
                Placeholder(
                  fallbackWidth: 275.w,
                  fallbackHeight: 250.h,
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(exerciseName, style: AppTextStyles.title),
            if (categoryName != null)
              Text(categoryName!, style: AppTextStyles.subTitle),

            SizedBox(height: 22.h),

            // Description Container
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
                            Text(description, style: AppTextStyles.body),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h,),
                  // Start Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FilledButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExerciseScreen(
                                // Pass the converted ExerciseType
                                selectedExerciseType: typeToPass,
                              ),
                            ),
                          );
                        },
                        child: const Text('Start'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
