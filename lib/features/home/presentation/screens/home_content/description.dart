import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/font.dart';
import 'package:gradproject/core/utils/styles/icons.dart';
import 'package:gradproject/core/utils/widgets/nav_bar.dart';
import 'package:gradproject/features/camera_handling/presentation/cubit/camera_cubit.dart';
import 'package:gradproject/features/camera_handling/presentation/cubit/camera_state.dart';
import 'package:gradproject/features/camera_handling/services/camera_service.dart';
import 'package:gradproject/features/exercise_flow_management/presentation/cubit/exercise_session_cubit.dart';
import 'package:gradproject/features/exercise_flow_management/presentation/cubit/exercise_session_state.dart';
import 'package:gradproject/features/exercise_flow_management/presentation/screens/exercise_screen.dart';
import 'package:gradproject/features/common_exercise/domain/entities/enums/exercise_type.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/font.dart';
import 'package:gradproject/core/utils/styles/icons.dart';
import 'package:gradproject/core/utils/widgets/nav_bar.dart';
import 'package:gradproject/features/camera_handling/presentation/cubit/camera_cubit.dart';
import 'package:gradproject/features/camera_handling/presentation/cubit/camera_state.dart';
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

  @override
  void initState() {
    super.initState();
    typeToPass = _getExerciseTypeFromName(widget.exerciseName);
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

  @override
  Widget build(BuildContext context) {
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
            SizedBox(height: 34.h),
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

// class Description extends StatelessWidget {
//   final String exerciseName;
//   final String? categoryName;
//   final String description;

//   const Description({
//     super.key,
//     required this.exerciseName,
//     required this.categoryName,
//     required this.description,
//   });

//   ExerciseType _getExerciseTypeFromName(String name) {
//     switch (name.toLowerCase()) {
//       case 'bicep curls':
//         return ExerciseType.bicepCurl;
//       case 'glute bridges':
//         return ExerciseType.gluteBridge;
//       case 'plank':
//         return ExerciseType.plank;
//       default:
//         debugPrint('Warning: Unknown exercise name: $name.');
//         return ExerciseType.bicepCurl;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final ExerciseType typeToPass = _getExerciseTypeFromName(exerciseName);

//     List<String> navIcons = [
//       AppIcons.home,
//       AppIcons.tick_square,
//       AppIcons.chat,
//       AppIcons.notification,
//       AppIcons.setting,
//     ];

//     return Scaffold(
//       bottomNavigationBar: NavBar(
//         selectedIndex: 0,
//         color: AppColors.teal,
//         navItems: List.generate(5, (index) {
//           return NavItem(
//             icon: AppIcon(navIcons[index].replaceAll('Bold', 'Bulk')),
//             selectedIcon: AppIcon(
//               navIcons[index],
//               color: AppColors.teal,
//               size: 31.68.w,
//             ),
//           );
//         }),
//       ),
//       body: Padding(
//         padding: EdgeInsets.fromLTRB(22.w, 30.h, 22.w, 0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 34.h),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 IconButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   icon: AppIcon(AppIcons.arrow_left_bulk, size: 33.33.w),
//                 ),
//                 const Spacer(),
//                 Placeholder(
//                   fallbackWidth: 275.w,
//                   fallbackHeight: 250.h,
//                 ),
//               ],
//             ),
//             SizedBox(height: 10.h),
//             Text(exerciseName, style: AppTextStyles.title),
//             if (categoryName != null)
//               Text(categoryName!, style: AppTextStyles.subTitle),
//             SizedBox(height: 22.h),
//             Expanded(
//               child: Column(
//                 children: [
//                   Flexible(
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                           horizontal: 20.w, vertical: 20.h),
//                       decoration: BoxDecoration(
//                         color: AppColors.white,
//                         borderRadius: BorderRadius.circular(25.r),
//                       ),
//                       child: SingleChildScrollView(
//                         physics: const BouncingScrollPhysics(),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Description', style: AppTextStyles.header),
//                             SizedBox(height: 10.h),
//                             Text(description, style: AppTextStyles.body),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 20.h),
//                   // Start Button with state check
//                   BlocBuilder<CameraCubit, CameraState>(
//                     builder: (context, cameraState) {
//                       bool isCameraReady = cameraState is CameraReady;

//                       if (isCameraReady) {
//                         BlocProvider.of<ExerciseSessionCubit>(context)
//                             .startExercise();
//                       }

//                       return Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           FilledButton(
//                             onPressed: (isCameraReady)
//                                 ? () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => ExerciseScreen(
//                                           selectedExerciseType: typeToPass,
//                                         ),
//                                       ),
//                                     );
//                                   }
//                                 : null,
//                             child: const Text('Start'),
//                           ),
//                         ],
//                       );
//                     },
//                   )
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
