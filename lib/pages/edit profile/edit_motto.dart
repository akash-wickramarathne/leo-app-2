import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leo_final/widgets/body_container.dart';
import 'package:leo_final/widgets/primary_button.dart';

import '../../constants.dart';
import '../../widgets/back_button.dart';

class EditMotto extends StatelessWidget {
  const EditMotto({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBarBackButton(),
        centerTitle: true,
        title: Text(
          'Edit Motto',
          style: TextStyle(
            fontSize: 16.sp,
            color: darkModeEnabled ? kDarkTextColor : kTextColor,
          ),
        ),
      ),
      body: BodyContainer(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Motto",
              style: TextStyle(
                fontSize: 16.sp,
                color: darkModeEnabled ? kDarkTextColor : kTextColor,
              ),
            ),
            SizedBox(
              height: 8.h,
            ),
            TextFormField(
              style: TextStyle(
                fontSize: 16.sp,
              ),
              maxLines: 4,
              decoration: InputDecoration(
                border: kInputBorder,
                enabledBorder: kInputEnabledBorder,
                focusedBorder: kInputFocusedBorder,
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            PrimaryButton(
              onTap: () {},
              text: 'Save',
            )
          ],
        ),
      ),
    );
  }
}
