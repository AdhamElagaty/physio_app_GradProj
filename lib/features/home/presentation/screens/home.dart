import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/font.dart';
import 'package:gradproject/core/utils/styles/icons.dart';
import 'package:gradproject/core/utils/widgets/nav_bar.dart';
import 'package:gradproject/features/home/presentation/widgets/category_container.dart';
import 'package:gradproject/features/search/presentation/screens/search.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
      AppColors.red,
      AppColors.purple,
      AppColors.yellow,
      AppColors.magenta
    ];
    final List<Map<String, dynamic>> categories = [
      {
        'title': 'Favourites',
        'subtitle': 'All your favorite exercises',
        'color': AppColors.red,
        'icon': AppIcons.heart,
      },
      {
        'title': 'Arms',
        'subtitle': 'Boost your arm strength',
        'color': AppColors.green,
        'icon': AppIcons.hide_bulk,
      },
      {
        'title': 'Lower Body',
        'subtitle': 'Tone your lower body',
        'color': AppColors.purple,
        'icon': AppIcons.heart,
      },
      {
        'title': 'Core Strength',
        'subtitle': 'Strengthen your core',
        'color': AppColors.yellow,
        'icon': AppIcons.heart,
      },
    ];

    final List<String> navIcons = [
      AppIcons.home,
      AppIcons.tick_square,
      AppIcons.chat,
      AppIcons.notification,
      AppIcons.setting
    ];
    int colorIndex = 0;
    return Scaffold(
      bottomNavigationBar: NavBar(
        selectedIndex: 0,
        color: AppColors.teal,
        navItems: List.generate(navIcons.length, (index) {
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
        padding: EdgeInsets.symmetric(horizontal: 35.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 90.h),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Exercises', style: AppTextStyles.title),
                    Text('Choose category', style: AppTextStyles.subTitle),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Search(autoSearch: true),
                        ),
                      );
                    });
                  },
                  child: AppIcon(
                    AppIcons.search_bulk,
                    size: 30.72.w,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),

            SizedBox(height: 15.h),

            // Exercise Category List
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: categories.map((category) {
                    if (colorIndex >= colors.length) colorIndex = 1;
                    return Padding(
                      padding: EdgeInsets.only(top: 30.h),
                      child: CategoryContainer(
                        color: colors[colorIndex],
                        title: category['title'],
                        subtitle: category['subtitle'],
                        icon: AppIcon(
                          category['icon'],
                          size: 46.66.w,
                          color: colors[colorIndex++],
                        ),
                        onTap: () {
                          Future.delayed(const Duration(milliseconds: 300), () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => Search(
                                  selectedCategory: category['title']
                                      .toString()
                                      .toLowerCase(),
                                ),
                              ),
                            );
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
