import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../styles/colors.dart';

class NavItem {
  NavItem({
    required this.icon,
    required this.selectedIcon,
    this.label,
    this.onTap,
  });
  String? label;
  Widget icon;
  Widget selectedIcon;
  void Function()? onTap;
}

// ignore: must_be_immutable
class NavBar extends StatelessWidget {
  NavBar({
    super.key,
    this.selectedIndex = 0,
    required this.navItems,
    this.color = AppColors.teal,
  });
  final int selectedIndex;
  final Color color;
  final List<NavItem> navItems;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.grey,
      child: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(
              top: 20.h,
              bottom: 37.h,
            ),
            //constraints: BoxConstraints(minWidth:screenWidth*.188 ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(200.r),
            ),
            padding: EdgeInsets.all(12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 10.w,
              children: List.generate(navItems.length, (index) {
                final isSelected = index == selectedIndex;
                return Material(
                  color: Colors.transparent,
                  shape: CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: navItems[index].onTap,
                    // selectedIndex = index;
                    // widget.navItems[index].onTap;
                    // setState(() {});

                    child: Container(
                      padding: EdgeInsets.all(10.w),
                      width: 51.68.w,
                      height: 51.68.h,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withAlpha(26)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: isSelected
                          ? navItems[index].selectedIcon
                          : navItems[index].icon,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
