import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:gradproject/core/cahce/share_prefs.dart';
import 'package:gradproject/core/utils/config/routes.dart';
import 'package:gradproject/core/utils/styles/colors.dart';
import 'package:gradproject/core/utils/styles/font.dart';
import 'package:gradproject/core/utils/styles/icons.dart';
import 'package:gradproject/core/utils/styles/widget_themes/buttons.dart';
import 'package:gradproject/features/auth/data/model/user_model.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage(
      {super.key, this.name = 'Ziad Hegazy', this.username = '@ZiadHegazy'});
  final String name;
  final String username;

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Logout Confirmation",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Are you sure you want to log out?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            // "Cancel" button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),

            FilledButton(
              onPressed: () async {
                //  Remove tokens from cache
                await CacheHelper.removeData('token');
                await CacheHelper.removeData('refreshToken');

                Navigator.of(context).pop();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.login,
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
              ),
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Reset color index for this page's categories

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 90.h),

          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Settings', style: AppTextStyles.title),
                  Text('Configure your preferences', style: AppTextStyles.subTitle),
                ],
              ),
            ],
          ),

          SizedBox(height: 50.h),

          // Exercise Category List
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                padding: EdgeInsets.all(7.w),
                decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(23.r)),
                child: Column(
                  spacing: 7.h,
                  children: [
                    Container(
                      decoration: ShapeDecoration(
                        color: Color.alphaBlend(
                          AppColors.teal.withAlpha(38),
                          AppColors.grey,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16.r)),
                        ),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Container(
                        // width: 333.w,
                        // height: 161.h,
                        decoration: ShapeDecoration(
                          gradient: LinearGradient(
                              colors: [
                                AppColors.grey.withAlpha(0),
                                AppColors.grey,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(16.r)),
                          ),
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: Svg('assets/images/Pattern.svg'),
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.fromLTRB(15.w, 10.h, 15.w, 15.h),
                          // width: 333.w,
                          // height: 161.h,
                          decoration: ShapeDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  AppColors.grey.withAlpha(0),
                                  AppColors.grey,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16.r)),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 20.w,
                            children: [
                              Container(
                                width: 70.w,
                                height: 70.h,
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                    color: AppColors.grey,
                                    border: Border.all(
                                        color: AppColors.white,
                                        width: 4.w,
                                        strokeAlign:
                                            BorderSide.strokeAlignCenter),
                                    borderRadius: BorderRadius.circular(100.r)),
                                child: AppIcon(
                                  AppIcons.profile,
                                  color: AppColors.black50,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: AppTextStyles.header.copyWith(
                                      color: AppColors.teal,
                                    ),
                                  ),
                                  Text(username, style: AppTextStyles.body),
                                ],
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  spacing: 0,
                                  children: [
                                    IconButton(
                                      onPressed: () {},
                                      style:
                                          AppButtonThemes.iconButtonSmall.style,
                                      icon: AppIcon(
                                        AppIcons.setting,
                                        size: 24.w,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {},
                            style: AppButtonThemes.filterButton.style,
                            icon: Text(
                              'Logout',
                              style: AppTextStyles.secondaryTextButton
                                  .copyWith(color: AppColors.red),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
