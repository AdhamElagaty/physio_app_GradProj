import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/font.dart';
import 'package:gradproject/core/utils/styles/icons.dart';
import 'package:gradproject/core/utils/widgets/nav_bar.dart';

class Description extends StatefulWidget {
  Description(
      {super.key,
      this.exerciseName = 'Stretching',
      this.categoryName = 'arm exercise',
      this.description =
          'Raise you hands while leaning in the same direction aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'});
  String exerciseName;
  String categoryName;
  String
      description; //TODO: both attributes should be replaced by exercise object
  @override
  State<Description> createState() => _DescriptionState();
}

class _DescriptionState extends State<Description> {
  @override
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
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 22.h,
          children: [
            SizedBox(height: 0.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // spacing: 20.w,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: AppIcon(
                          AppIcons.arrow_left_bulk,
                          size: 33.33.w,
                        )),
                    Placeholder(
                      fallbackWidth: 275.w,
                      fallbackHeight: 250.h,
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.h,
                ),
                Text(
                  widget.exerciseName,
                  style: AppTextStyles.title,
                ),
                Text(
                  widget.categoryName,
                  style: AppTextStyles.subTitle,
                )
              ],
            ),
            Expanded(
              child: Column(
                spacing: 15.h,
                children: [
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 20.h),
                      decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(25.r)),
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.fast),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 10.h,
                          children: [
                            Text(
                              'Description',
                              style: AppTextStyles.header,
                            ),
                            Text(
                              widget.description,
                              style: AppTextStyles.body,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FilledButton(onPressed: () {}, child: Text('Start'))
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
