import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leo_final/widgets/level_tag.dart';

import '../constants.dart';

class ProfileInfo extends StatelessWidget {
  final String userId;
  final String name;
  final String profileImgUrl;
  const ProfileInfo(
      {super.key,
      required this.name,
      required this.userId,
      required this.profileImgUrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(44.w),
          child: Image.network(
            profileImgUrl,
            width: 88.w,
            height: 88.w,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(
          width: 15.w,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: darkModeEnabled ? kDarkTextColor : kTextColor,
              ),
            ),
            SizedBox(
              height: 5.w,
            ),
            Text(
              'ID: $userId',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.normal,
                color: darkModeEnabled ? kDarkTextColor : kTextColor,
              ),
            ),
            SizedBox(
              height: 5.w,
            ),
            Row(
              children: [
                const LevelTag(
                  text: 'Noble',
                ),
                SizedBox(
                  width: 5.w,
                ),
                const LevelTag(
                  text: 'Noble',
                ),
                SizedBox(
                  width: 5.w,
                ),
                const LevelTag(
                  text: 'Noble',
                ),
              ],
            )
          ],
        )
      ],
    );
  }
}
