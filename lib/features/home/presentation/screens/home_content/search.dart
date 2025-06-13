import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/core/common_widgets/excerices.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/font.dart';
import 'package:gradproject/core/utils/styles/icons.dart';
import 'package:gradproject/core/utils/widgets/nav_bar.dart';
import 'package:gradproject/core/utils/widgets/tile.dart';
import 'package:gradproject/features/home/presentation/screens/home_content/description.dart';

class Search extends StatefulWidget {
  Search({super.key, this.autoSearch = false, this.selectedCategory});

  final String? selectedCategory;
  final bool autoSearch;
  final TextEditingController searchController = TextEditingController();

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List<Exercise> _filteredExercises = [];
  Set<String> _activeFilters = {};
  String? _initialCategoryContext;

  @override
  void initState() {
    super.initState();
    if (widget.selectedCategory != null) {
      _initialCategoryContext = widget.selectedCategory!.toLowerCase();

      _activeFilters.add(_initialCategoryContext!);
    }
    // else {
    //   _activeFilters
    //       .addAll(allExercises.map((e) => e.category.toLowerCase()).toSet());
    // }

    _filterExercises();
    _initialCategoryContext = null;
    widget.searchController.addListener(_filterExercises);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_filterExercises);
    widget.searchController.dispose();
    super.dispose();
  }

  void _filterExercises() {
    setState(() {
      _filteredExercises = allExercises.where((exercise) {
        final exerciseCategory = exercise.category.toLowerCase();
        final searchQuery = widget.searchController.text.toLowerCase();

        bool matchesSearchQuery = searchQuery.isEmpty ||
            exercise.name.toLowerCase().contains(searchQuery) ||
            exercise.subtitle.toLowerCase().contains(searchQuery);

        if (_initialCategoryContext != null) {
          if (_activeFilters.contains('favorites') &&
              _activeFilters.contains(_initialCategoryContext!)) {
            return matchesSearchQuery &&
                exerciseCategory == _initialCategoryContext &&
                exercise.isFavorite;
          } else if (_activeFilters.contains(_initialCategoryContext!)) {
            return matchesSearchQuery &&
                exerciseCategory == _initialCategoryContext;
          }

          return matchesSearchQuery &&
              exerciseCategory == _initialCategoryContext;
        } else {
          if (_activeFilters.isEmpty) {
            return matchesSearchQuery;
          }

          bool categoryMatch = false;
          // Check for regular category matches (e.g., 'arms', 'lower body')
          if (_activeFilters.contains(exerciseCategory) &&
              exerciseCategory != 'favorites') {
            categoryMatch = true;
          }

          // Check if 'favorites' filter is active AND the exercise is a favorite
          if (_activeFilters.contains('favorites') && exercise.isFavorite) {
            bool categoryOrFavoriteMatch = false;
            for (String filter in _activeFilters) {
              if (filter == 'favorites') {
                if (exercise.isFavorite) {
                  categoryOrFavoriteMatch = true;
                  break;
                }
              } else if (exerciseCategory == filter) {
                categoryOrFavoriteMatch = true;
                break;
              }
            }
            return matchesSearchQuery && categoryOrFavoriteMatch;
          }
          return matchesSearchQuery && categoryMatch;
        }
      }).toList();
    });
  }

  void _toggleFilter(String category) {
    setState(() {
      final lowerCaseCategory = category.toLowerCase();

      if (_initialCategoryContext != null) {
        if (lowerCaseCategory == _initialCategoryContext) {
          return;
        } else if (lowerCaseCategory == 'favorites') {
          // Toggle 'favorites'
          if (_activeFilters.contains('favorites')) {
            _activeFilters.remove('favorites');
          } else {
            _activeFilters.add('favorites');
          }
        }
      } else {
        if (_activeFilters.contains(lowerCaseCategory)) {
          // if (_activeFilters.length == 1 && lowerCaseCategory != 'favorites') {
          //   return;
          // }
          _activeFilters.remove(lowerCaseCategory);
        } else {
          _activeFilters.add(lowerCaseCategory);
        }
      }

      _filterExercises();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> navIcons = [
      AppIcons.home,
      AppIcons.tick_square,
      AppIcons.chat,
      AppIcons.notification,
      AppIcons.setting
    ];

    List<String> displayCategories = [];
    displayCategories
        .addAll(allExercises.map((e) => e.category.toLowerCase()).toSet());
    displayCategories.add('favorites');
    // if (_initialCategoryContext != null) {
    //   displayCategories.add(_initialCategoryContext!);
    //   displayCategories.add('favorites');
    // } else {
    //   displayCategories
    //       .addAll(allExercises.map((e) => e.category.toLowerCase()).toSet());
    //   displayCategories.add('favorites');
    // }

    displayCategories.sort();
    displayCategories
        .removeWhere((c) => _activeFilters.contains(c.toLowerCase()));
    displayCategories.insertAll(0, _activeFilters);

    return Scaffold(
      bottomNavigationBar: NavBar(
        selectedIndex: 0,
        color: AppColors.teal,
        navItems: List.generate(5, (index) {
          return NavItem(
            icon: AppIcon(
              navIcons[index].replaceAll('Bold', 'Bulk'),
            ),
            selectedIcon: AppIcon(
              navIcons[index],
              color: AppColors.teal,
              size: 31.68.w,
            ),
          );
        }),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(22.w, 30.h, 22.w, 0.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 34.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: AppIcon(
                        AppIcons.arrow_left_bulk,
                        size: 33.33.w,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Exercises',
                      style: AppTextStyles.title,
                    ),
                    Text(
                      'Choose category',
                      style: AppTextStyles.subTitle,
                    )
                  ],
                ),
              ],
            ),
            SizedBox(height: 22.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 14.w,
                    children: displayCategories.map((category) {
                      bool isActive =
                          _activeFilters.contains(category.toLowerCase());
                      bool isLockedDisplayCategory = (_initialCategoryContext !=
                              null &&
                          category.toLowerCase() == _initialCategoryContext);
                      return ChoiceChip(
                        label: Text(
                          category,
                          style: AppTextStyles.secondaryTextButton.copyWith(
                            color: isActive ? AppColors.teal : AppColors.black,
                          ),
                        ),
                        selected: isActive,
                        onSelected: (selected) {
                          if (isLockedDisplayCategory) {
                            _toggleFilter(category);
                            return;
                          }
                          _toggleFilter(category);
                        },
                        selectedColor: AppColors.teal.withAlpha(39),
                        backgroundColor: AppColors.white,
                        checkmarkColor: AppColors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.r),
                        ),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 10.h),
                SearchBar(
                  autoFocus: widget.autoSearch,
                  leading: AppIcon(
                    AppIcons.search_bulk,
                    size: 30.72,
                  ),
                  hintText: 'Search',
                  controller: widget.searchController,
                  onChanged: (query) => _filterExercises(),
                ),
              ],
            ),
            SizedBox(height: 20.h), // Spacing before exercise list
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                physics: BouncingScrollPhysics(),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 0.w, vertical: 20.h),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  child: Column(
                    spacing: 12.5.h,
                    children: _filteredExercises.isEmpty
                        ? [
                            Center(
                              child: Text(
                                'No exercises found.',
                                style: AppTextStyles.subTitle,
                              ),
                            ),
                          ]
                        : _filteredExercises.map((exercise) {
                            return Tile(
                              onTap: () {
                                Future.delayed(Duration(milliseconds: 250), () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => Description(
                                      exerciseName: exercise.name,
                                      categoryName: exercise.category,
                                      description: exercise.description,
                                    ),
                                  ));
                                });
                              },
                              icon: AppIcon(
                                exercise.iconPath,
                                color: AppColors.teal,
                                size: 25.w,
                              ),
                              title: exercise.name,
                              subTitle: exercise.subtitle,
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
