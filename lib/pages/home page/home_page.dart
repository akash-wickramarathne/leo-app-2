import 'dart:convert';
import 'dart:io';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leo_final/pages/contacts/contact_screen.dart';
import 'package:leo_final/pages/home%20page/bloc/home_page_bloc.dart';
import 'package:leo_final/pages/home%20page/bloc/home_page_event.dart';
import 'package:leo_final/pages/home%20page/bottom_tabs.dart';
import 'package:leo_final/zego%20files/initial.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_zimkit/zego_zimkit.dart';
import '../group/GroupMembers.dart';
import '../log in page/log_in_page.dart';
import 'bloc/home_page_state.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  final String userId;
  final String name;
  const MyHomePage(
      {super.key,
      required this.userId,
      required this.name,
      required String about});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  List<Map<String, String>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeZIMKitAndLoadChats();
    _fetchMyDetails();
    _fetchContacts();
  }

  Future<void> _initializeZIMKitAndLoadChats() async {
    await _initializeZIMKit();
    await _loadChats();
  }

  Future<void> _initializeZIMKit() async {
    await ZIMKit().init(
      appID: Initial.id,
      appSign: Initial.signIn,
    );
    await ZIMKit().connectUser(
      id: widget.userId,
      name: widget.userId, // Replace with an appropriate user name
    );
  }

  Future<void> _loadChats() async {
    // Fetch chats or any necessary data
    //  await ZIMKit().getConversation();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _logout(BuildContext context) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/user.json');
      if (await file.exists()) {
        await file.delete();
        // Ensure ZIMKit cleanup if necessary
        // Use appropriate method if available
        await ZIMKit()
            .disconnectUser(); // Replace with actual method if different
        print('User data deleted.');
      } else {
        print('No user data found to delete.');
      }
    } catch (e) {
      print('Error deleting user data: $e');
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<void> _fetchUsers() async {
    try {
      // Simulating an API call with a delay
      await Future.delayed(const Duration(seconds: 2));
      // List<dynamic> fetchedUsers = await ApiService.fetchUsers();
      setState(() {
        // users = fetchedUsers.cast<String>();
        isLoading = false;
        for (var user in users) {
          print('User: $user');
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        print(e.toString());
      });
    }
  }

  Future<void> _fetchMyDetails() async {
    try {
      // Define the API URL
      var url =
          Uri.parse('http://45.126.125.172:8080/api/v1/user/${widget.userId}');

      // Send the GET request to the API
      var response = await http.get(url);

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Parse the response body as JSON
        var userData = jsonDecode(response.body);
        if (userData['id'] != null) {
          userData['id'] = userData['id'].toString();
        }

        // Get the application documents directory
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/user.json');

        // Clear the existing user.json file if it exists
        if (await file.exists()) {
          await file.delete();
        }

        // Save the new user details to user.json
        await file.writeAsString(jsonEncode(userData));

        print('User details fetched and saved successfully');
      } else {
        print('Failed to fetch user details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  void saveGroupInDB(groupName) async {
    Map<String, String> requestBodyData = {
      "groupName": groupName,
      "groupAdminId": widget.userId,
    };

    var jsonData = json.encode(requestBodyData);

    Uri url = Uri.parse('http://45.126.125.172:8080/api/v1/groups/create');
    final response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: jsonData);

    if (response.statusCode == 200) {
      print('response : ${response.body}');
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse.containsKey('groupId') &&
          jsonResponse.containsKey('groupName') &&
          jsonResponse.containsKey('groupAdminId') &&
          jsonResponse.containsKey('status')) {
        String groupName = jsonResponse['groupName'];
        String groupId = jsonResponse['groupId'];
        String groupAdminId = jsonResponse['groupAdminId'];
        String status = jsonResponse['status'];
        // OTP and userId exist in the response, show success popup
        print(
            'Group Name: $groupName, Group ID: $groupId, Admin Id: $groupAdminId, status: $status');
        // showSuccessPopup(otp, userId, phoneNumberWithCountryCode);
      } else {
        // OTP or userId is missing, show error
        showError("Invalid Group Response. Please try again.");
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

  Future<void> _fetchContacts() async {
    if (await Permission.contacts.request().isGranted) {
      Iterable<Contact> contacts = await ContactsService.getContacts();
      List<Map<String, String>> formattedContacts = contacts.map((contact) {
        String mobileNumber = contact.phones?.isNotEmpty ?? false
            ? contact.phones!.first.value ?? ''
            : '';
        if (mobileNumber.isNotEmpty) {
          mobileNumber = mobileNumber.substring(1);
        }
        return {
          'mobileNumber': mobileNumber,
          'contactName': contact.displayName ?? '',
        };
      }).toList();

      final url = Uri.parse('http://45.126.125.172:8080/api/v1/checkContacts');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(formattedContacts),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData =
            jsonDecode(response.body) as List<dynamic>;

        final List<Map<String, String>> contactsResponse = responseData
            .where((e) => e['userId'].toString() != widget.userId)
            .map<Map<String, String>>((e) => {
                  'userId': e['userId'].toString(),
                  'contactName': e['contactName'].toString(),
                })
            .toList();

        setState(() {
          users = contactsResponse;
        });
        print('Contacts fetched successfully: $users');
      } else {
        print('Failed to fetch contacts: ${response.statusCode}');
      }
    } else {
      setState(() {
        //_isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission denied. Unable to access contacts.'),
        ),
      );
    }
  }

  Future<void> _createGroup(
      List<String> ids, String groupName, String groupType) async {
    setState(() {
      isLoading = true;
    });

    try {
      int? groupAdminId = int.tryParse(widget.userId);
      Map<String, dynamic> requestBodyData = {
        "groupName": groupName,
        "groupAdminId": groupAdminId,
      };
      Uri url;
      if (groupType == 'private') {
        url = Uri.parse('http://45.126.125.172:8080/api/v1/groups/create');
      } else if (groupType == 'public') {
        url =
            Uri.parse('http://45.126.125.172:8080/api/v1/publicgroups/create');
      } else {
        throw Exception('Invalid group type');
      }

      var jsonData = json.encode(requestBodyData);
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonData,
      );

      print(response.body);
      if (response.statusCode == 200) {
        print('response : ${response.body}');
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.containsKey('groupId') &&
            jsonResponse.containsKey('groupName') &&
            jsonResponse.containsKey('groupAdminId') &&
            jsonResponse.containsKey('status')) {
          String groupName = jsonResponse['groupName'];
          String groupId =
              jsonResponse['groupId'].toString(); // Convert to String
          String groupAdminId =
              jsonResponse['groupAdminId'].toString(); // Convert to String
          String status = jsonResponse['status'];

          print(
              'Group Name: $groupName, Group ID: $groupId, Admin Id: $groupAdminId, status: $status');

          if (groupType == 'public') {
            // Uri usersUrl = Uri.parse(
            //     'http://45.126.125.172:8080/api/v1/publicgroups/$groupId/users');
            // var usersResponse = await http.post(
            //   usersUrl,
            //   headers: {"Content-Type": "application/json"},
            //   body: {"insert": ids},
            // );
            //String jsonBodyUser = jsonEncode(ids);
            // Map<String, int> requestUserData = {
            //   "insert": ids,
            // };

            List<int> usersIds = ids.map((id) => int.parse(id)).toList();
            Map<String, dynamic> requestUserData = {
              "insert": usersIds,
            };
            Uri usersUrl = Uri.parse(
                'http://45.126.125.172:8080/api/v1/publicgroups/$groupId/users');
            var usersResponse = await http.post(usersUrl,
                headers: {"Content-Type": "application/json"},
                body: jsonEncode(requestUserData));
            print(ids);
            print({jsonEncode(requestUserData)});
            print(usersResponse.body);
            if (usersResponse.statusCode == 200) {
              print('Users added to group successfully');
            } else {
              print(
                  'Failed to add users to group: ${usersResponse.statusCode}');
            }
          }

          await ZIMKit().createGroup(groupName, ids, id: groupId);
          print(groupId);
          print(ids);

          setState(() {
            isLoading = false;
          });

          if (groupId.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return ZIMKitMessageListPage(
                    conversationID: groupId,
                    conversationType: ZIMConversationType.group,
                  );
                },
              ),
            );

            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => GroupMembersPage(groupID: groupId),
            //   ),
            // );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Group created successfully')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to create group')),
            );
          }
        } else {
          showError("Invalid Group Response. Please try again.");
        }
      } else {
        showAlertDialog(
          context: context,
          message: "Failed to create group. Please try again.",
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error creating group: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error creating group')),
      );
    }
  }

  void _showCreateGroupModal(BuildContext context) {
    String groupName = '';
    String groupDescription = '';
    String selectedPrivacy =
        'private'; // Set a default value from the dropdown options

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create Group'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    decoration: const InputDecoration(labelText: 'Group Name'),
                    onChanged: (value) {
                      groupName = value;
                    },
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    onChanged: (value) {
                      groupDescription = value;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedPrivacy, // Initially selected value
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'private',
                        child: Text('Private'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'public',
                        child: Text('Public'),
                      ),
                    ],
                    onChanged: (newValue) {
                      setState(() {
                        selectedPrivacy = newValue!;
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Next'),
                  onPressed: () {
                    if (groupName.isNotEmpty &&
                        groupDescription.isNotEmpty &&
                        (selectedPrivacy == 'private' ||
                            selectedPrivacy == 'public')) {
                      Navigator.of(context).pop();
                      _showSelectUsersScreen(
                        context,
                        users, // Ensure this is defined or passed correctly
                        groupName,
                        groupDescription,
                        selectedPrivacy, // Pass selectedPrivacy to the next screen
                      );
                    } else {
                      // You can show a message or handle the error appropriately
                      print('Please fill all fields correctly');
                    }
                  },
                ),
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSelectUsersScreen(
      BuildContext context,
      List<Map<String, String>> users,
      String groupName,
      String groupDescription,
      String selectedPrivacy) {
    List<String> selectedUsers = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Users'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return CheckboxListTile(
                      title: Text(user['contactName'] ?? ''),
                      subtitle: Text(user['userId'] ?? ''),
                      value: selectedUsers.contains(user['userId']),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value != null && value) {
                            selectedUsers.add(user['userId']!);
                          } else {
                            selectedUsers.remove(user['userId']!);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Create'),
                  onPressed: selectedUsers.isEmpty
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          _createGroup(
                              selectedUsers, groupName, selectedPrivacy);
                        },
                ),
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout Confirmation'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: BlocBuilder<HomePageBloc, HomePageState>(
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            actions: [
              const Icon(Icons.search, color: Colors.white),
              PopupMenuButton(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      child: const Text('New chat'),
                      onTap: () {
                        // ZIMKit().showDefaultNewPeerChatDialog(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContactsScreen(
                              userId: widget.userId,
                              Name: widget.name,
                            ),
                          ),
                        );
                      },
                    ),
                    PopupMenuItem(
                      child: const Text('Logout'),
                      onTap: () {
                        _logout(context);
                      },
                    ),
                    PopupMenuItem(
                        child: const Text('New Group'),
                        onTap: () {
                          _showCreateGroupModal(context);
                        }),
                    // const PopupMenuItem(child: Text('New Broadcast')),
                    const PopupMenuItem(child: Text('Linked Devices')),
                    const PopupMenuItem(child: Text('Starred Messages')),
                    const PopupMenuItem(child: Text('Settings')),
                  ];
                },
              ),
            ],
            backgroundColor: const Color(0xff059FDA),
            title: Text('LEO-CHAT',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  height: 1.9.h,
                )),
            bottom: const TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: Colors.white,
              tabs: [
                Tab(
                  child: Text('CHATS', style: TextStyle(color: Colors.white)),
                ),
                Tab(
                  child: Text('STATUS', style: TextStyle(color: Colors.white)),
                ),
                Tab(
                  child: Text('CALLS', style: TextStyle(color: Colors.white)),
                ),
              ],
              labelColor: Colors.white,
            ),
          ),
          body: buildBottomTabs(_currentIndex, widget.userId, widget.name),
          bottomNavigationBar: BottomNavigationBar(
            fixedColor: Colors.grey,
            elevation: 1,
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            showUnselectedLabels: true,
            showSelectedLabels: true,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
                print(_currentIndex); // Update the current index
              });
            },
            items: [
              BottomNavigationBarItem(
                activeIcon: const Icon(
                  Icons.chat,
                  color: Colors.blue,
                ),
                icon: Icon(
                  Icons.chat,
                  color: Colors.blue.withOpacity(0.8),
                ),
                label: 'chat',
              ),
              BottomNavigationBarItem(
                activeIcon: const Icon(
                  Icons.group,
                  color: Colors.blue,
                ),
                icon: Icon(
                  Icons.group,
                  color: Colors.blue.withOpacity(0.8),
                ),
                label: 'group',
              ),
              BottomNavigationBarItem(
                activeIcon: const Icon(
                  Icons.sports_basketball,
                  color: Colors.blue,
                ),
                icon: Icon(
                  Icons.sports_basketball,
                  color: Colors.blue.withOpacity(0.8),
                ),
                label: 'games',
              ),
              BottomNavigationBarItem(
                activeIcon: const Icon(
                  Icons.person,
                  color: Colors.blue,
                ),
                icon: Icon(
                  Icons.person,
                  color: Colors.blue.withOpacity(0.8),
                ),
                label: 'profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
