import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import '../styles/font.dart';
import '../styles/icons.dart';

class Category extends StatefulWidget {
  Category({
    super.key,
    required this.color,
    this.backgroundColor = Colors.white,
    this.onTap,
    required this.icon,
  });
  final Color color;
  final Color backgroundColor;
  final void Function()? onTap;
  final String icon;

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color.alphaBlend(
        widget.color.withAlpha(38),
        widget.backgroundColor,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        splashColor: widget.color,
        borderRadius: BorderRadius.all(Radius.circular(25)),
        onTap: () {
          widget.onTap;
          setState(() {});
        },
        child: Container(
          width: 333,
          height: 161,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            image: DecorationImage(
              fit: BoxFit.fill,
              image: Svg('assets/images/Pattern.svg'),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(17.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 15),
                        Text(
                          'Favorites',
                          style: AppTextStyles.header.copyWith(
                            color: widget.color,
                          ),
                        ),
                      ],
                    ),
                    AppIcon(widget.icon, color: widget.color, size: 46.66),
                  ],
                ),
                Text('All your favorite exercises', style: AppTextStyles.body),
                SizedBox(height: 5),
                AppIcon(AppIcons.arrow_right_square,
                    color: widget.color, size: 35),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
