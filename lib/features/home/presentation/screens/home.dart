import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/font.dart';
import 'package:gradproject/core/utils/styles/icons.dart';
import 'package:gradproject/core/utils/widgets/nav_bar.dart';
import 'package:gradproject/features/home/presentation/widgets/category.dart';
import 'package:gradproject/features/search/presentation/screens/search.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    List<Color> colors = [AppColors.red, AppColors.purple, AppColors.yellow];
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
        padding: EdgeInsets.symmetric(horizontal: 35.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 45.h,
          children: [
            SizedBox(height: 55.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => Search(autoSearch: true,)));
                    setState(() {});
                  },
                  child: AppIcon(
                    AppIcons.search_bulk,
                    size: 30.72.w,
                  ),
                )
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  spacing: 34.h,
                  children: List.generate(4, (index) {
                    if (index == colors.length) {
                      index = 0;
                    }
                    return Category(
                        color: colors[index],
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Search(selectedCategory: 'favorites',)));
                        },
                        icon: AppIcon(
                          AppIcons.heart,
                          size: 46.66.w,
                          color: colors[index++],
                        ));
                  }),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
