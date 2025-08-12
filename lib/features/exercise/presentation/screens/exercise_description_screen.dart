import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/presentation/cubit/app_cubit/app_manager_cubit.dart';
import '../../../../core/presentation/widget/app_icon.dart';
import '../../../../core/presentation/widget/cached_network_image.dart';
import '../../../../core/presentation/widget/title_bar_widget.dart';
import '../../../../core/services/camera_service/camera_service.dart';
import '../../../../core/services/pose_detection_service/pose_detection_service.dart';
import '../../../../core/utils/styles/app_colors.dart';
import '../../../../core/utils/styles/font.dart';
import '../../../../core/utils/styles/app_assets.dart';
import '../../domain/entities/exercise.dart';
import '../cubit/camera_cubit/camera_cubit.dart';
import '../cubit/exercise_filter/exercise_filter_cubit.dart';
import '../cubit/exercise_session_cubit/exercise_session_cubit.dart';
import 'exercise_camera_screen.dart';

class ExerciseDescriptionScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDescriptionScreen({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(22.w, 30.h, 22.w, 0),
        child: BlocBuilder<ExerciseFilterCubit, ExerciseFilterState>(
          builder: (context, state) {
            final currentExercise = state.exercises.firstWhere(
              (e) => e.id == exercise.id,
              orElse: () => exercise,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<AppManagerCubit, AppManagerState>(
                  builder: (appManagerContext, appManagerState) {
                    return TitleBarWidget(
                      removeBottomSpace: true,
                      isReturnButtonEnabled: true,
                      isHeroEnabled: true,
                      heroTag: appManagerState.connectivityStatus ==
                              ConnectivityStatus.online
                          ? 'exercise_title_bar'
                          : "no_internet_title_bar",
                    );
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    DynamicCachedImage(
                      cacheKey:
                          '${currentExercise.id}::${currentExercise.modelKey}::image::GIF',
                      imageUrl: currentExercise.imageUrl,
                      fallbackAssetPath:
                          currentExercise.localFallbackImageAsset,
                      width: 275.w,
                      height: 250.h,
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(currentExercise.title, style: AppTextStyles.title),
                Text(currentExercise.categoryTitle,
                    style: AppTextStyles.subTitle),
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
                                Text('Description',
                                    style: AppTextStyles.header),
                                SizedBox(height: 10.h),
                                Text(currentExercise.description,
                                    style: AppTextStyles.body),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          // ++ ADDED ++: Favorite button, which is aware of the offline state.
                          if (!state.isOffline)
                            IconButton(
                              onPressed: () => context
                                  .read<ExerciseFilterCubit>()
                                  .toggleFavorite(currentExercise.id),
                              icon: currentExercise.isFavorite
                                  ? AppIcon(AppAssets.iconly.bold.heart,
                                      color: AppColors.red, size: 33.w)
                                  : AppIcon(AppAssets.iconly.stroke.heart,
                                      color: AppColors.black50, size: 33.w),
                            ),
                          const Spacer(),
                          // This check prevents a crash if an exercise is not trackable.
                          if (currentExercise.exerciseTrainerType != null)
                            FilledButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MultiBlocProvider(
                                      providers: [
                                        BlocProvider(
                                          create: (_) =>
                                              CameraCubit(CameraService())
                                                ..initializeCamera(),
                                        ),
                                        BlocProvider(
                                          create: (_) => ExerciseSessionCubit(
                                              PoseDetectionService()),
                                        ),
                                      ],
                                      child: ExerciseCameraScreen(
                                        selectedExerciseType: currentExercise
                                            .exerciseTrainerType!,
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
            );
          },
        ),
      ),
    );
  }
}
