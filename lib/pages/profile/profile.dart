import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:leo_final/pages/edit%20profile/main_profile.dart';
import 'package:path_provider/path_provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic> userData = {};

  Future<void> readUserData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/user.json');
      final contents = await file.readAsString();
      final data = json.decode(contents);

      setState(() {
        userData = data;
      });
      print(data);
    } catch (e) {
      // Handle any errors here
      print("Error reading user data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    readUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Account',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold, // Make the text bold
            ),
          ),
          centerTitle: false, // Align title to the left
        ),
        // body: Center(
        //   child: userData.isNotEmpty
        //       ? Column(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             Text('User ID: ${userData['user_id']}'),
        //             Text('Mobile Number: ${userData['mobileNumber']}'),
        //             Text('Name: ${userData['name']}'),
        //             Text('About: ${userData['about']}'),
        //           ],
        //         )
        //       : const CircularProgressIndicator(), // Show a loading indicator while data is being loaded
        // ),
        body: Center(
          child: userData.isNotEmpty
              ? Container(
                  margin: const EdgeInsets.all(8),
                  child: ListView(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              10), // Set desired radius here
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 16,
                            bottom: 16,
                            left: 8,
                            right: 8,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: userData['profilePicUrl'] != null
                                  ? NetworkImage(userData['profilePicUrl'])
                                  : const NetworkImage(
                                      'https://img.freepik.com/free-vector/blue-circle-with-white-user_78370-4707.jpg'),
                              radius: 24,
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${userData['name']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MainProfile(
                                          name: userData['name'],
                                          userId: userData['id'],
                                          profileImgUrl:
                                              userData['profilePicUrl'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Edit',
                                    style: TextStyle(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildListItem(context, Icons.account_balance_wallet,
                          'Wallet', '/wallet'),
                      _buildListItem(context, Icons.group_add, 'Invite Friends',
                          '/invite'),
                      _buildListItem(
                          context, Icons.emoji_events, 'Medal', '/medal'),
                      _buildListItem(context, Icons.star, 'Level', '/level'),
                      _buildListItem(context, Icons.show_chart, 'CP', '/cp'),
                      _buildListItem(context, Icons.store, 'Store', '/store'),
                      _buildListItem(
                          context, Icons.list_alt, 'My Items', '/items'),
                      const SizedBox(height: 16),
                      _buildListItem(
                          context, Icons.language, 'Language', '/language'),
                    ],
                  ),
                )
              : const CircularProgressIndicator(),
        ));
  }

  Widget _buildListItem(
      BuildContext context, IconData icon, String title, String routeName) {
    return Card(
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Set desired radius here
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: 8,
          right: 8,
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: Colors.blue[600],
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            Navigator.pushNamed(
                context, routeName); // Navigate to the specified route
          },
        ),
      ),
    );
  }
}
