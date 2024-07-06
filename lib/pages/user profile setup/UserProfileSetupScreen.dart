import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

import '../home page/home_page.dart';

class UserProfileSetupScreen extends StatefulWidget {
  final String userId;
  const UserProfileSetupScreen({super.key, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _UserProfileSetupScreenState createState() => _UserProfileSetupScreenState();
}

class _UserProfileSetupScreenState extends State<UserProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Future<void> _saveProfile() async {
    // Prepare the request body

    if (_nameController.text.isEmpty || _aboutController.text.isEmpty) {
      _showErrorDialog('Name and About fields cannot be empty');
      return;
    }
    try {
      var uri = Uri.parse('http://45.126.125.172:8080/api/v1/updateProfile');
      var request = http.MultipartRequest('POST', uri);

      request.fields['userId'] = widget.userId;
      request.fields['name'] = _nameController.text;
      request.fields['about'] = _aboutController.text;

      if (_imageFile != null) {
        File imageFile = File(_imageFile!.path);
        request.files
            .add(await http.MultipartFile.fromPath('file', imageFile.path));
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var responseData = jsonDecode(responseBody);

        // Read existing userData from file
        Map<String, dynamic> userData = await _readUserData();

        // Update name and about in userData
        userData['name'] = _nameController.text;
        userData['about'] = _aboutController.text;

        // Save updated userData to file
        await _saveUserData(userData);

        // Navigate to home page with updated data
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => MyHomePage(
              userId: widget.userId,
              name: _nameController.text,
              about: _aboutController.text,
            ),
          ),
          (route) => false,
        );

        print('Profile updated successfully');
      } else {
        print('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to update profile: $e');
    }
  }

  Future<Map<String, dynamic>> _readUserData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/user.json');
      if (await file.exists()) {
        // Read file and decode JSON
        String contents = await file.readAsString();
        return jsonDecode(contents);
      }
      return {}; // Return an empty map if file doesn't exist
    } catch (e) {
      print('Failed to read user data: $e');
      return {}; // Return an empty map on error
    }
  }

  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/user.json');
      await file.writeAsString(jsonEncode(userData));
    } catch (e) {
      print('Failed to save user data: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
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
        backgroundColor: const Color(0xff059FDA),
        title: const Center(
          child: Text(
            'Profile Setup',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Set up your profile',
                  style: TextStyle(
                    fontSize: 19,
                    color: Colors.black,
                    height: 1.8,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageFile != null
                        ? FileImage(File(_imageFile!.path))
                        : const AssetImage('assets/placeholder.png')
                            as ImageProvider,
                    child: _imageFile == null
                        ? Icon(
                            Icons.camera_alt,
                            size: 50,
                            color: Colors.blue.withOpacity(0.5),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.w),
                      borderSide: const BorderSide(color: Colors.black26)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.w),
                      borderSide: const BorderSide(color: Colors.grey)),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 2.h, horizontal: 8.w),
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _aboutController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.w),
                      borderSide: const BorderSide(color: Colors.black26)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.w),
                      borderSide: const BorderSide(color: Colors.grey)),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  labelText: 'About',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff059FDA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                  ),
                  onPressed: _saveProfile,
                  child: const Text(
                    'Save',
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
      ),
    );
  }
}
