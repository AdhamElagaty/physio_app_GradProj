import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/styles/app_assets.dart';
import '../../utils/styles/app_colors.dart';
import '../../utils/styles/font.dart';
import 'app_icon.dart';

class TitleBarWidget extends StatelessWidget {
  const TitleBarWidget({
    super.key,
    this.title,
    this.subtitle,
    this.isReturnButtonEnabled = false,
    this.onReturnButtonPressed,
    this.onActionButtonPressed,
    this.actionButtonIconSvgAsset,
    this.isHeroEnabled = false,
    this.heroTag,
    this.removeTopSpace = false,
    this.removeBottomSpace = false,
    this.spaceBetweenTitles = 0,
  });

  final String? title;
  final String? subtitle;
  final bool isReturnButtonEnabled;
  final VoidCallback? onReturnButtonPressed;
  final VoidCallback? onActionButtonPressed;
  final String? actionButtonIconSvgAsset;
  final bool isHeroEnabled;
  final String? heroTag;
  final bool removeTopSpace;
  final bool removeBottomSpace;
  final int spaceBetweenTitles;

  @override
  Widget build(BuildContext context) {
    return _buildWidget(context);
  }

  Column _buildWidget(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        (isHeroEnabled && heroTag != null)
        ? Hero(
            tag: "${heroTag!}Header",
            child: Material(
              type: MaterialType.transparency,
              child: _buildHeader(context),
            ),
          )
        : _buildHeader(context),

        (isHeroEnabled && heroTag != null && title != null)
        ? Hero(
            tag: "${heroTag!}Content",
            flightShuttleBuilder: (
              flightContext,
              animation,
              flightDirection,
              fromHeroContext,
              toHeroContext,
            ) {
              final Hero toHero = toHeroContext.widget as Hero;

              return OverflowBox(
                alignment: Alignment.topLeft,
                maxHeight: double.infinity,
                child: toHero.child,
              );
            },
            child: Material(
              type: MaterialType.transparency,
              child: _buildContent(context),
            ),
          )
        : _buildContent(context)
      ],
    );
  }

  Widget _buildHeader(BuildContext context){
    return Column(
      children: [
        removeTopSpace ? SizedBox.shrink() : SizedBox(height: 34.h),
        Visibility(
          visible: isReturnButtonEnabled,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: IconButton(
            onPressed: onReturnButtonPressed ?? () => Navigator.of(context).pop(),
            icon: AppIcon(AppAssets.iconly.bulk.arrowLeft, size: 33.33.w),
          ),
        ),

        removeTopSpace ? SizedBox.shrink() : SizedBox(height: 10.h),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       (title != null) ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle(
                    style: AppTextStyles.title,
                    child: Text(title!),
                  ),

                  if (subtitle != null) ...[
                    SizedBox(height: spaceBetweenTitles.h),
                    DefaultTextStyle(
                      style: AppTextStyles.subTitle,
                      child: Text(subtitle!),
                    ),
                  ],
                ],
              ),
            ),
            (onActionButtonPressed != null && actionButtonIconSvgAsset != null)
                ? ElevatedButton(
                    onPressed: onActionButtonPressed,
                    child: AppIcon(actionButtonIconSvgAsset!,
                        size: 30.72.w, color: AppColors.black),
                  )
                : const SizedBox.shrink(),
          ],
        ) : const SizedBox.shrink(),
        removeBottomSpace ? SizedBox.shrink() :  SizedBox(height: 15.h),
      ],
    );
  }
}
