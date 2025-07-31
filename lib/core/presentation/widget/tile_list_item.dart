import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'tile.dart';

class TileListItem extends StatelessWidget {
  const TileListItem({
    super.key,
    required this.index,
    required this.length,
    required this.title,
    this.subTitle,
    required this.onTap,
    this.trailing,
    required this.icon,
    this.isFirst = false,
    this.isEnd = false,
  });

  final int index;
  final int length;
  final String title;
  final String? subTitle;
  final Widget? trailing;
  final Widget icon;
  final bool isFirst;
  final bool isEnd;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topRight: index == 0 ? Radius.circular(25.r) : Radius.zero,
            topLeft: index == 0 ? Radius.circular(25.r) : Radius.zero,
            bottomRight:
                index == length - 1 ? Radius.circular(25.r) : Radius.zero,
            bottomLeft:
                index == length - 1 ? Radius.circular(25.r) : Radius.zero),
      ),
      child: Tile(
        icon: icon,
        title: title,
        onTap: onTap,
        trailing: trailing,
        subTitle: subTitle,
        isFirst: isFirst,
        isEnd: isEnd,
      ),
    );
  }
}
