import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/font.dart';

class Tile extends StatefulWidget {
  const Tile(
      {super.key, required this.icon, required this.title, this.subTitle = ''});
  final Widget icon;
  final String title;
  final String? subTitle;

  @override
  State<Tile> createState() => _TileState();
}

class _TileState extends State<Tile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 20.w,
        children: [
          Container(
            padding: EdgeInsets.all(12.5.w),
            child: widget.icon,
            decoration: BoxDecoration(
                color: AppColors.teal.withAlpha(39),
                borderRadius: BorderRadius.circular(12.r)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 0.h,
            children: [
              Text(
                widget.title,
                style: AppTextStyles.header,
                textHeightBehavior: TextHeightBehavior(
                    applyHeightToLastDescent: false,
                    applyHeightToFirstAscent: true),
              ),
              Text(
                widget.subTitle!,
                style: AppTextStyles.body,
                textHeightBehavior: TextHeightBehavior(
                    applyHeightToLastDescent: true,
                    applyHeightToFirstAscent: false),
              )
            ],
          )
        ],
      ),
    );
  }
}
