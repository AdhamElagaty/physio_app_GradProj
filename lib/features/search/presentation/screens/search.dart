import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/font.dart';
import 'package:gradproject/core/utils/styles/icons.dart';
import 'package:gradproject/core/utils/styles/widget_themes/buttons.dart';
import 'package:gradproject/core/utils/widgets/nav_bar.dart';
import 'package:gradproject/core/utils/widgets/tile.dart';
import 'package:gradproject/features/description/presentation/screens/description.dart';

class Search extends StatefulWidget {
  Search({super.key, this.autoSearch = false, this.selectedCategory});
  final List<String> categories = [
    'favorites',
    'stretching',
  ]; //TODO: change to categories type
  final List<Color> colors = [
    AppColors.red,
    AppColors.purple,
    AppColors.yellow
  ]; //TODO: might remove after adding categories
  List<String> filters = List.empty(growable: true);
  String? selectedCategory;
  bool autoSearch;
  TextEditingController searchController = TextEditingController();
  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  // ignore: must_call_super
  initState() {
    widget.selectedCategory != null
        ? widget.filters.add(widget.selectedCategory!)
        : {};
  }

  Widget build(BuildContext context) {
    List<String> navIcons = [
      AppIcons.home,
      AppIcons.tick_square,
      AppIcons.chat,
      AppIcons.notification,
      AppIcons.setting
    ];

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
              ));
        }),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(22.w, 30.h, 22.w, 0.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 22.h,
          children: [
            SizedBox(height: 0.h),
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
                        )),
                    SizedBox(
                      height: 10.h,
                    ),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10.h,
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.all(0.w),
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      spacing: 14.w,
                      children: List.generate(widget.filters.length, (index) {
                            return IconButton(
                              onPressed: () {
                                setState(() {
                                  widget.categories.add(widget.filters[index]);
                                  widget.filters.removeAt(index);
                                });
                              },
                              style: AppButtonThemes.filterButton.style,
                              icon: Text(
                                widget.filters[index] + '  ×',
                                style: AppTextStyles.secondaryTextButton
                                    .copyWith(color: AppColors.teal),
                              ),
                            );
                          }) +
                          List.generate(widget.categories.length, (index) {
                            return IconButton(
                                onPressed: () {
                                  setState(() {
                                    widget.filters
                                        .add(widget.categories[index]);
                                    widget.categories.removeAt(index);
                                  });
                                },
                                icon: AppIcon(
                                  AppIcons.heart,
                                  color: widget.colors[index],
                                ));
                          })),
                ),
                SearchBar(
                  autoFocus: widget.autoSearch,
                  leading: AppIcon(
                    AppIcons.search_bulk,
                    size: 30.72,
                  ),
                  hintText: 'Search',
                  controller: widget.searchController,
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(0.w),
                physics: BouncingScrollPhysics(),
                child: Flex(
                  direction: Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 0.w, vertical: 20.h),
                      decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(25.r)),
                      child: Column(
                        spacing: 12.5.h,
                        children: List.generate(10, (index) {
                          return Tile(
                            onTap: () {
                              Future.delayed(Duration(milliseconds: 250), () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => Description(
                                          exerciseName: 'Stretching',
                                          description:
                                              'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
                                        )));
                              });
                            },
                            icon: AppIcon(
                              AppIcons.heart,
                              color: AppColors.teal,
                              size: 25.w,
                            ),
                            title: 'title',
                            subTitle: 'subtitle test text',
                          );
                        }),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
