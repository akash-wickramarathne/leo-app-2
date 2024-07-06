import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:zego_zimkit/zego_zimkit.dart';

class ContactsScreen extends StatefulWidget {
  final String userId;
  final String Name;

  ContactsScreen({required this.userId, required this.Name});

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Map<String, dynamic>>? _contactsResponse;
  bool _isLoading = true;

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
        final responseData = jsonDecode(response.body) as List<dynamic>;
        final List<Map<String, dynamic>> contactsResponse = responseData
            .map<Map<String, dynamic>>((e) =>
                e is Map<String, dynamic> ? e.cast<String, dynamic>() : {})
            .toList();
        setState(() {
          _isLoading = false;
          _contactsResponse = contactsResponse;
        });
        print('Contacts sent successfully');
      } else {
        print('Failed to send contacts: ${response.statusCode}');
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission denied. Unable to access contacts.'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  void _startTextChat(String contactUserId, String ContactName) async {
    try {
      // Connect the current user
      await ZIMKit().connectUser(
        id: widget.userId,
        name: widget.Name, // Replace with an appropriate user name
      );

      // Navigate to the chat screen with the selected contact
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ZIMKitMessageListPage(
            conversationID: contactUserId,
            conversationType: ZIMConversationType.peer,
          ),
        ),
      );
    } catch (e) {
      print('Error starting chat: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to start chat. Please try again later.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Contacts'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _contactsResponse?.length ?? 0,
              itemBuilder: (context, index) {
                if (_contactsResponse == null ||
                    _contactsResponse!.length <= index) {
                  return Container();
                }
                var contact = _contactsResponse![index];
                return GestureDetector(
                  onTap: () => _startTextChat(
                      contact['userId'].toString(),
                      contact[
                          'contactName']), // Replace with contact's ZegoCloud user ID
                  child: ListTile(
                    leading: contact['profilePicUrl'] != null
                        ? CircleAvatar(
                            backgroundImage:
                                NetworkImage(contact['profilePicUrl']),
                          )
                        : const Icon(Icons.account_circle),
                    title: Text(contact['contactName']),
                  ),
                );
              },
            ),
    );
  }
}
