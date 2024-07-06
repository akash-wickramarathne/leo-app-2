import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String chatTitle;
  final String imageUrl;

  const ChatScreen({Key? key, required this.chatTitle, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff059FDA),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(imageUrl),
            ),
            const SizedBox(width: 10),
            Text(chatTitle),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () {
              // Handle video call action
            },
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              // Handle voice call action
            },
          ),
        ],
      ),
      body: ListView(
        children: const [
          // Add individual chat messages here
          Text('Chat messages will appear here'),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Wrap(
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.insert_drive_file),
                          title: const Text('Document'),
                          onTap: () {
                            // Handle document attachment
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.photo),
                          title: const Text('Gallery'),
                          onTap: () {
                            // Handle gallery attachment
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.mic),
                          title: const Text('Audio'),
                          onTap: () {
                            // Handle audio attachment
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.mic),
              onPressed: () {
                // Handle voice message action
              },
            ),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Type your message...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                // Handle message send action
              },
            ),
          ],
        ),
      ),
    );
  }
}
