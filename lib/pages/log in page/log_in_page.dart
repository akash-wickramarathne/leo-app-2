import 'dart:convert';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leo_final/pages/otp%20verification%20page/OTPVerificationScreen.dart';
import 'custom_textfield.dart';
import 'package:http/http.dart' as http;

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late TextEditingController countryNameController;
  late TextEditingController countryCodeController;
  late TextEditingController phoneNumberController;

  sendCode() async {
    final phoneNumber = phoneNumberController.text;
    final countryName = countryNameController.text;
    final countryCode = countryCodeController.text;

    if (phoneNumber.isEmpty) {
      return showAlertDialog(
        context: context,
        message: "Please enter your phone number",
      );
    } else if (phoneNumber.length < 7) {
      return showAlertDialog(
        context: context,
        message:
            'The phone number you entered is too short for the country: $countryName\n\nInclude your area code if you haven\'t',
      );
    } else if (phoneNumber.length > 12) {
      return showAlertDialog(
        context: context,
        message:
            "The phone number you entered is too long for the country: $countryName",
      );
    }

    //final phoneNumberWithCountryCode = '+$countryCode$phoneNumber';
    final phoneNumberWithCountryCode = phoneNumber;
    Map<String, String> requestBodyData = {
      "mobileNumber": phoneNumberWithCountryCode,
    };

    print(phoneNumberWithCountryCode);

    var jsonData = json.encode(requestBodyData);

    Uri url = Uri.parse('http://45.126.125.172:8080/api/v1/getOtp');
    final response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: jsonData);

    if (response.statusCode == 200) {
      //Map<dynamic, dynamic> jsonResponse = json.decode(response.body);
      // print(jsonResponse);
      // String otp = jsonResponse['otp'];
      //  int userId = jsonResponse['userId'];
      //  print('OTP: $otp, User ID: $userId');
      print('response login: ${response.body}');
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse.containsKey('otp') &&
          jsonResponse.containsKey('userId')) {
        int otp = jsonResponse['otp'];
        int userId = jsonResponse['userId'];
        // OTP and userId exist in the response, show success popup
        print('OTP: $otp, User ID: $userId');
        showSuccessPopup(otp, userId, phoneNumberWithCountryCode);
      } else {
        // OTP or userId is missing, show error
        showError("Invalid OTP response. Please try again.");
      }

      // Navigator.of(context).push(MaterialPageRoute(
      //   builder: (_) =>
      //       OTPVerificationScreen(phoneNumber: phoneNumberWithCountryCode),
      //));
    } else {
      showAlertDialog(
        // ignore: use_build_context_synchronously
        context: context,
        message: "Failed to send code. Please try again.",
      );
    }
  }

  showCountryPickerBottomSheet() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      favorite: ['ET'],
      countryListTheme: CountryListThemeData(
        bottomSheetHeight: 600,
        // backgroundColor: Theme.of(context).backgroundColor,
        flagSize: 22,
        borderRadius: BorderRadius.circular(20),
        textStyle: const TextStyle(
          color: Colors.grey,
        ),
        inputDecoration: InputDecoration(
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(
            Icons.language,
            color: Colors.blue,
          ),
          hintText: 'Search country by code or name',
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(.2),
            ),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.green,
            ),
          ),
        ),
      ),
      onSelect: (country) {
        countryNameController.text = country.name;
        countryCodeController.text = country.phoneCode;
      },
    );
  }

  @override
  void initState() {
    countryNameController = TextEditingController(text: 'Sri Lanka');
    countryCodeController = TextEditingController(text: '94');
    phoneNumberController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    countryNameController.dispose();
    countryCodeController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  void showSuccessPopup(otp, userId, phoneNumber) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Success"),
          content: const Text("OTP send successful!"),
          actions: [
            TextButton(
              onPressed: () {
                // Navigate to the home page
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (_) => OTPVerificationScreen(
                            otpCode: otp.toString(),
                            userId: userId.toString(),
                            mobileNumber: phoneNumber.toString(),
                          )),
                  (route) => false,
                );
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          'Enter your phone number',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                text: 'Leo Chat will need to verify your number. ',
                style: TextStyle(
                  color: Colors.grey,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: "What's my number?",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: CustomTextField(
              onTap: showCountryPickerBottomSheet,
              controller: countryNameController,
              readOnly: true,
              suffixIcon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.blue,
                size: 22,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: CustomTextField(
                    onTap: showCountryPickerBottomSheet,
                    controller: countryCodeController,
                    prefixText: '+',
                    readOnly: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomTextField(
                    controller: phoneNumberController,
                    hintText: 'phone number',
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Carrier charges may apply',
            style: TextStyle(
              color: Colors.grey.withOpacity(0.9),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton(
        onPressed: sendCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 36, 160, 237),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.w)),
        ),
        child: const Text(
          'NEXT',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

showAlertDialog({
  required BuildContext context,
  required String message,
  String? btnText,
}) {
  return showDialog(
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
