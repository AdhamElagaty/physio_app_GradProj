import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../utils/styles/app_assets.dart';

class PatternAuthLayout extends StatelessWidget {
  final Widget body;
  final Widget footer;

  const PatternAuthLayout({
    super.key,
    required this.body,
    this.footer = const SizedBox(),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag: 'pattern_auth_layout',
                  child: SizedBox(
                    width: double.infinity,
                    height: constraints.maxHeight * 0.3,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          bottom: 0,
                          right: constraints.maxWidth * -0.2,
                          child: SvgPicture.asset(AppAssets.patternAndEffect.roundedPattern),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.1),
                    child: body,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: footer,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
