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
        'icon': AppIcons.heart,
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
            SizedBox(height: 55.h),

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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal.withOpacity(0.1),
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(12),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Search(autoSearch: true),
                      ),
                    );
                  },
                  child: AppIcon(
                    AppIcons.search_bulk,
                    size: 30.72.w,
                    color: AppColors.teal,
                  ),
                ),
              ],
            ),

            SizedBox(height: 45.h),

            // Exercise Category List
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: categories.map((category) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 34.h),
                      child: CategoryContainer(
                        color: category['color'],
                        title: category['title'],
                        subtitle: category['subtitle'],
                        icon: AppIcon(
                          category['icon'],
                          size: 46.66.w,
                          color: category['color'],
                        ),
                        onTap: () {
                          Future.delayed(const Duration(milliseconds: 250), () {
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
