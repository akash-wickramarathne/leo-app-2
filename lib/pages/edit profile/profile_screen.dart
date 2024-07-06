import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:leo_final/constants.dart';
import 'package:leo_final/theme.dart';
import 'package:leo_final/widgets/body_container.dart';
import 'package:leo_final/widgets/primary_button.dart';
import 'package:leo_final/widgets/voice_room_item.dart';

import '../../widgets/gift_item.dart';
import '../../widgets/outline_button.dart';
import '../../widgets/profile_info.dart';
import '../../widgets/stats_box.dart';

class ProfileScreen extends StatelessWidget {
  final String userId;
  final String name;
  final String profileImgUrl;
  const ProfileScreen({super.key, required this.name, required this.userId,required this.profileImgUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        width: double.infinity,
        color: darkModeEnabled ? kDarkBoxColor : kLightBlueColor,
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: OutlineButton(
                onTap: () {},
                text: 'Share',
              ),
            ),
            SizedBox(
              width: 10.w,
            ),
            Expanded(
              child: PrimaryButton(
                onTap: () {
                  Navigator.pushNamed(context, 'edit-profile');
                },
                text: 'Edit',
              ),
            )
          ],
        ),
      ),
      body: BodyContainer(
        enableScroll: true,
        padding: const EdgeInsets.all(0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/coverpic.png',
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileInfo(name: name, userId: userId,profileImgUrl:profileImgUrl,),
                  SizedBox(
                    height: 20.w,
                  ),
                  Text(
                    'Online Enterprenur | Youtuber | Blockchain Developer | Astrophotographer | Game Developer',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: darkModeEnabled ? kDarkTextColor : kAltTextColor,
                    ),
                  ),
                  SizedBox(
                    height: 20.w,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: darkModeEnabled ? kDarkBoxColor : kLightBlueColor,
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        StatsBox(
                          text: 'Followers',
                          value: 11,
                        ),
                        StatsBox(
                          text: 'Fans',
                          value: 11,
                        ),
                        StatsBox(
                          text: 'Visitors',
                          value: 11,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.w,
                  ),
                  Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing. Lorem ipsum dolor sit amet, consectetur adipiscing. Lorem ipsum dolor sit amet, consectetur adipiscing.  Lorem ipsum dolor sit amet, consectetur adipiscing.  Lorem ipsum dolor sit amet, consectetur adipiscing.',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: darkModeEnabled ? kDarkTextColor : kAltTextColor,
                    ),
                  ),
                  SizedBox(
                    height: 20.w,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Gifts',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, 'gifts');
                        },
                        icon: SvgPicture.asset(
                          'assets/icons/ic-arrow-right.svg',
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10.w,
                  ),
                  SizedBox(
                    height: 75.w,
                    width: double.infinity,
                    child: ListView.separated(
                      itemCount: 5,
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          width: 20.w,
                        );
                      },
                      itemBuilder: (context, index) {
                        return const GiftItem(
                          icon: 'assets/icons/ic-gifticon.svg',
                          text: 'x263',
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20.w,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Badges',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, 'badges');
                        },
                        icon: SvgPicture.asset(
                          'assets/icons/ic-arrow-right.svg',
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10.w,
                  ),
                  SizedBox(
                    height: 75.w,
                    width: double.infinity,
                    child: ListView.separated(
                      itemCount: 5,
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          width: 20.w,
                        );
                      },
                      itemBuilder: (context, index) {
                        return const GiftItem(
                          icon: 'assets/icons/ic-gifticon.svg',
                          text: 'x263',
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10.w,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Voice Rooms',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, 'rooms');
                        },
                        icon: SvgPicture.asset(
                          'assets/icons/ic-arrow-right.svg',
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 106.w,
                    width: double.infinity,
                    child: ListView.separated(
                      itemCount: 5,
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          width: 20.w,
                        );
                      },
                      itemBuilder: (context, index) {
                        return const VoiceRoomItem(
                          image: 'assets/images/room.png',
                          text: 'My Voice Room',
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
