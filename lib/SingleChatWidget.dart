import 'package:flutter/material.dart';
import 'ChatScreen.dart';

class SingleChatWidget extends StatelessWidget {
  final String chatMessage;
  final String chatTitle;
  final Color seenStatusColor;
  final String imageUrl;

  const SingleChatWidget({
    Key? key,
    required this.chatMessage,
    required this.chatTitle,
    required this.seenStatusColor,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatScreen(chatTitle: chatTitle, imageUrl: imageUrl)));
        // Navigator.pushNamed(
        //   context,
        //   '/chat',
        //   arguments: {
        //     'chatTitle': chatTitle,
        //     'imageUrl': imageUrl,
        //   },
        // );
      },
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(imageUrl),
          ),
          Expanded(
            child: ListTile(
              title: Text(
                chatTitle,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Row(
                children: [
                  Icon(
                    seenStatusColor == Colors.blue ? Icons.done_all : Icons.done,
                    size: 15,
                    color: seenStatusColor,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Text(
                        chatMessage,
                        style: const TextStyle(overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ),
                ],
              ),
              trailing: const Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text('Yesterday'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
