import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/core/common_widgets/excerices.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/font.dart';
import 'package:gradproject/core/utils/styles/icons.dart';
import 'package:gradproject/core/utils/widgets/nav_bar.dart';
import 'package:gradproject/core/utils/widgets/tile.dart';
import 'package:gradproject/features/common_exercise/domain/entities/enums/exercise_type.dart';
import 'package:gradproject/features/home/presentation/screens/home_content/description.dart';

class History extends StatefulWidget {
  History({super.key, this.autoHistory = false, this.selectedCategory});

  final String? selectedCategory;
  final bool autoHistory;
  final TextEditingController SearchController = TextEditingController();

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<Exercise> _filteredExercises = [];
  Set<String> _activeFilters = {};

  @override
  void initState() {
    super.initState();
    if (widget.selectedCategory != null) {
      _activeFilters.add(widget.selectedCategory!.toLowerCase());
    }
    _filterExercises();
    widget.SearchController.addListener(_filterExercises);
  }

  @override
  void dispose() {
    widget.SearchController.removeListener(_filterExercises);
    widget.SearchController.dispose();
    super.dispose();
  }

  void _filterExercises() {
    setState(() {
      _filteredExercises = allExercises.where((exercise) {
        final exerciseCategory = exercise.category.toLowerCase();
        final HistoryQuery = widget.SearchController.text.toLowerCase();
        bool matchesHistoryQuery = HistoryQuery.isEmpty ||
            exercise.name.toLowerCase().contains(HistoryQuery) ||
            exercise.subtitle.toLowerCase().contains(HistoryQuery);

        if (_activeFilters.isEmpty && widget.selectedCategory == null) {
          return matchesHistoryQuery;
        }

        bool categoryMatch = _activeFilters.contains(exerciseCategory);

        if (_activeFilters.contains('favorites') && exercise.isFavorite) {
          if (_activeFilters.length == 1) {
            return matchesHistoryQuery && exercise.isFavorite;
          } else if (_activeFilters.contains(exerciseCategory)) {
            return matchesHistoryQuery && exercise.isFavorite && categoryMatch;
          } else {
            return matchesHistoryQuery && exercise.isFavorite;
          }
        }

        return matchesHistoryQuery && categoryMatch;
      }).toList();
    });
  }

  void _toggleFilter(String category) {
    setState(() {
      final lowerCaseCategory = category.toLowerCase();

      if (widget.selectedCategory != null &&
          lowerCaseCategory == widget.selectedCategory!.toLowerCase() &&
          !_activeFilters.contains(lowerCaseCategory) &&
          _activeFilters.isNotEmpty) {
        _activeFilters.add(lowerCaseCategory);
      } else if (_activeFilters.contains(lowerCaseCategory)) {
        if (widget.selectedCategory != null &&
            lowerCaseCategory == widget.selectedCategory!.toLowerCase() &&
            _activeFilters.length == 1) {
          return;
        } else {
          _activeFilters.remove(lowerCaseCategory);
        }
      } else {
        if (widget.selectedCategory != null &&
            lowerCaseCategory != 'favorites') {
          _activeFilters.clear();
          _activeFilters.add(widget.selectedCategory!.toLowerCase());
          _activeFilters.add(lowerCaseCategory);
        } else {
          _activeFilters.add(lowerCaseCategory);
        }
      }

      if (_activeFilters.isEmpty && widget.selectedCategory != null) {
        _activeFilters.add(widget.selectedCategory!.toLowerCase());
      }
      _filterExercises();
    });
  }

  ExerciseType getExerciseTypeFromName(String name) {
    switch (name.toLowerCase()) {
      case 'plank':
        return ExerciseType.plank;
      case 'bicep curls':
        return ExerciseType.bicepCurl;
      case 'glute bridges':
        return ExerciseType.gluteBridge;
      default:
        throw Exception('Unknown exercise type: $name');
    }
  }

  @override
  Widget build(BuildContext context) {
    int index = 0;
    Set<String> allUniqueCategories =
        allExercises.map((e) => e.category.toLowerCase()).toSet();
    allUniqueCategories.add('favorites');
    List<String> displayCategories = allUniqueCategories.toList()..sort();

    List<String> sortedDisplayCategories = [
      ..._activeFilters.where(displayCategories.contains),
      ...displayCategories.where((c) => !_activeFilters.contains(c)),
    ];

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(22.w, 30.h, 22.w, 0.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 34.h),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: AppIcon(AppIcons.arrow_left_bulk, size: 33.33.w),
            ),
            SizedBox(height: 10.h),
            Text('Exercises', style: AppTextStyles.title),
            Text('Choose category', style: AppTextStyles.subTitle),
            SizedBox(height: 22.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              physics: BouncingScrollPhysics(),
              child: Row(
                children: sortedDisplayCategories.map((category) {
                  bool isActive = _activeFilters.contains(category);
                  bool isInitialCategory = widget.selectedCategory != null &&
                      category == widget.selectedCategory!.toLowerCase();

                  return Padding(
                    padding: EdgeInsets.only(right: 14.w),
                    child: ChoiceChip(
                      label: Text(
                        category,
                        style: AppTextStyles.secondaryTextButton.copyWith(
                          color: isActive ? AppColors.teal : AppColors.black,
                        ),
                      ),
                      selected: isActive,
                      onSelected: (_) {
                        if (isInitialCategory &&
                            isActive &&
                            _activeFilters.length == 1) return;
                        _toggleFilter(category);
                      },
                      selectedColor: AppColors.teal.withAlpha(39),
                      backgroundColor: AppColors.white,
                      checkmarkColor: AppColors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.r),
                      ),
                      side: BorderSide.none,
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 10.h),
            SearchBar(
              autoFocus: widget.autoHistory,
              leading: AppIcon(AppIcons.search_bulk, size: 30.72),
              hintText: 'Search',
              controller: widget.SearchController,
              onChanged: (_) => _filterExercises(),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                physics: BouncingScrollPhysics(),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  child: Column(
                    children: _filteredExercises.isEmpty
                        ? [
                            Center(
                              child: Text(
                                'No exercises found.',
                                style: AppTextStyles.subTitle,
                              ),
                            )
                          ]
                        : _filteredExercises.map((exercise) {
                            return Tile(
                              onTap: () {
                                Future.delayed(Duration(milliseconds: 150), () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => Description(
                                        exerciseName: exercise.name,
                                        categoryName: exercise.category,
                                        description: exercise.description,
                                      ),
                                    ),
                                  );
                                });
                              },
                              icon: AppIcon(exercise.iconPath,
                                  color: AppColors.teal, size: 46.w),
                              title: exercise.name,
                              subTitle: exercise.subtitle,
                              isFirst: index == 0,
                              isEnd: index++ == _filteredExercises.length - 1,
                              trailing: IconButton(
                                onPressed: () {},
                                icon: exercise.isFavorite
                                    ? AppIcon(
                                        AppIcons.heart,
                                        color: AppColors.red,
                                        size: 30.w,
                                      )
                                    : AppIcon(
                                        AppIcons.heart_stroke,
                                        color: AppColors.black50,
                                        size: 30.w,
                                      ),
                              ),
                            );
                          }).toList(),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
