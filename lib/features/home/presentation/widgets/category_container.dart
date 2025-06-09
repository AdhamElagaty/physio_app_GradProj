import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import '../../../../core/utils/styles/font.dart';
import '../../../../core/utils/styles/icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryContainer extends StatefulWidget {
  CategoryContainer(
      {super.key,
      required this.color,
      this.backgroundColor = Colors.white,
      required this.onTap,
      required this.icon,
      required this.title,
      required this.subtitle});
  final Color color;
  final Color backgroundColor;
  final void Function() onTap;
  final Widget icon;
  final String title;
  final String subtitle;

  @override
  State<CategoryContainer> createState() => _CategoryContainerState();
}

class _CategoryContainerState extends State<CategoryContainer> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color.alphaBlend(
        widget.color.withAlpha(38),
        widget.backgroundColor,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25.r)),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        splashColor: widget.color,
        borderRadius: BorderRadius.all(Radius.circular(25.r)),
        onTap: () {
          setState(() {
            widget.onTap();
          });
        },
        child: Container(
          width: 333.w,
          height: 180.h,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.r)),
            ),
            image: DecorationImage(
              fit: BoxFit.fill,
              image: Svg('assets/images/Pattern.svg'),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(17.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 15.h),
                        Text(
                          widget.title,
                          style: AppTextStyles.header.copyWith(
                            color: widget.color,
                          ),
                        ),
                      ],
                    ),
                    widget.icon,
                  ],
                ),
                Text('${widget.subtitle}', style: AppTextStyles.body),
                SizedBox(height: 5),
                AppIcon(AppIcons.arrow_right_square,
                    color: widget.color, size: 35.w),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
