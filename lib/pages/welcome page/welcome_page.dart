import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../log in page/log_in_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _OtpGeneratePageState();
}

class _OtpGeneratePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Container(
            padding: EdgeInsets.only(top: 20.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/icons/chat.png',
                  width: 300.w,
                  height: 300.h,
                ),
                SizedBox(
                  height: 30.h,
                ),
                Text(
                  'Welcome to Leo Chat',
                  style: TextStyle(
                    fontSize: 22.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        text: 'Read our ',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 102, 102, 102),
                          height: 1.3.h,
                          fontSize: 13.sp,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Privacy policy.',
                            style: TextStyle(
                                color: Color.fromARGB(255, 52, 159, 255)),
                          ),
                          TextSpan(
                              text:
                                  ' tap , \"Agree and Continue\" to accept the'),
                          TextSpan(
                            text: ' Terms and Conditions.',
                            style: TextStyle(
                                color: Color.fromARGB(255, 52, 159, 255)),
                          )
                        ]),
                  ),
                ),
                SizedBox(
                  height: 32.h,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 100,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 6.h),
                        splashFactory: NoSplash.splashFactory,
                        elevation: 0,
                        backgroundColor: Color.fromARGB(255, 36, 160, 237),
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.w),
                        )),
                    child: const Text(
                      'AGREE AND CONTINUE',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
