import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leo_final/pages/home%20page/home_page.dart';
import 'package:leo_final/pages/user%20profile%20setup/UserProfileSetupScreen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen(
      {super.key,
      required this.otpCode,
      required this.userId,
      required this.mobileNumber});

  final String otpCode;
  final String userId;
  final String mobileNumber;

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  String sixDigitOtpCode = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff059FDA),
        title: const Text(
          'Verify Phone Number',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the 6-digit code',
              style: TextStyle(
                fontSize: 19,
                height: 1.9.h,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.w),
                      borderSide: const BorderSide(color: Colors.black26)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.w),
                      borderSide: const BorderSide(color: Colors.grey)),
                  hintText: '6987',
                  labelText: 'OTP',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h)),
              maxLength: 6,
              onChanged: (otpCode) {
                sixDigitOtpCode = otpCode;
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff059FDA),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.w),
                    )),
                onPressed: verifyOtp,
                child: const Text(
                  'Verify',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> verifyOtp() async {
    Map<String, String> requestData = {
      "mobileNumber": widget.mobileNumber,
      "otp": sixDigitOtpCode,
    };

    //  var jsonData = json.encode(requestData);

    // Uri url = Uri.parse('http://45.126.125.172:8080/api/v1/verifyOtp');
    // final response = await http.post(url,
    //     headers: {"Content-Type": "application/json"}, body: jsonData);

    if (widget.otpCode == sixDigitOtpCode) {
      final user = {
        "mobileNumber": widget.mobileNumber,
        "user_id": widget.userId
      };
      await saveUserData(user);
      // showAlertDialog(
      //   context: context,
      //   message: "Verification successfully",
      // );
    } else {
      showAlertDialog(
        context: context,
        message: "Failed to verify OTP. Please try again.",
      );
    }
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/user.json');
    final res = await file.writeAsString(json.encode(userData));
    print(res);
    print(userData);

    String fileContent = await file.readAsString();
    Map<String, dynamic> existingUserData = json.decode(fileContent);

    Uri url =
        Uri.parse('http://45.126.125.172:8080/api/v1/user/${widget.userId}');
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> userData = json.decode(response.body);
      String name = userData['name'];
      String about = userData['about'];
      String profilePicUrl = userData["profilePicUrl"];
      if (name == null ||
          name.isEmpty ||
          about == null ||
          about.isEmpty ||
          profilePicUrl.isEmpty) {
        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //       builder: (_) => UserProfileSetupScreen(userId: widget.userId)),
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) =>
                  MyHomePage(userId: widget.userId, about: about, name: name)),
        );
      } else {
        existingUserData['name'] = userData['name'];
        existingUserData['about'] = userData['about'];
        existingUserData['profileImage'] = userData['profilePicUrl'];
        await file.writeAsString(json.encode(existingUserData));
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) =>
                  MyHomePage(userId: widget.userId, about: about, name: name)),
        );
      }
    }
  }

  void showAlertDialog({
    required BuildContext context,
    required String message,
    String? btnText,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.black38,
              fontSize: 15,
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                btnText ?? "OK",
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
