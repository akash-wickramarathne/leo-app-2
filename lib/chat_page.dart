import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final String contactName;
  final String contactPhone;

  ChatPage({required this.contactName, required this.contactPhone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with $contactName'),
      ),
      body: Center(
        child: Text('Chat with $contactName ($contactPhone)'),
      ),
    );
  }
}
