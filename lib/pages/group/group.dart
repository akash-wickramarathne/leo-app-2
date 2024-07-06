import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:zego_zimkit/zego_zimkit.dart';
import '../audio-room/audio_room_screen.dart';

class Group extends StatefulWidget {
  final String userId;
  final String userName;

  const Group({Key? key, required this.userId, required this.userName})
      : super(key: key);

  @override
  _GroupState createState() => _GroupState();
}

class _GroupState extends State<Group> {
  List<int> publicGroupIds = [];
  bool showPublicChats = false; // Default to private chats

  @override
  void initState() {
    super.initState();
    fetchPublicGroups();
  }

  Future<void> fetchPublicGroups() async {
    Uri url =
        Uri.parse('http://45.126.125.172:8080/api/v1/publicgroups/groups');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        List<int> groupIds =
            jsonResponse.map((group) => group['groupId']).cast<int>().toList();
        setState(() {
          publicGroupIds = groupIds;
        });
      } else {
        throw Exception('Failed to load public groups');
      }
    } catch (e) {
      print('Error fetching public groups: $e');
    }
  }

  Future<bool> isUserAdmin(String groupId, String userId) async {
    Uri url =
        Uri.parse('http://45.126.125.172:8080/api/v1/groups/$groupId/admin');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse['adminId'].toString() == userId;
      } else {
        throw Exception('Failed to load admin details');
      }
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  Future<void> saveVoiceRoom(String groupId, String voiceRoomId) async {
    Map<String, dynamic> requestBodyData = {
      'groupId': groupId,
      'voiceRoomId': voiceRoomId,
      'isCreated': true,
    };

    var jsonData = json.encode(requestBodyData);

    Uri url = Uri.parse('http://45.126.125.172:8080/api/v1/voiceroom/save');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonData,
      );
      if (response.statusCode == 200) {
        print('Voice room saved successfully');
      } else {
        print('Failed to save voice room: ${response.statusCode}');
      }
      print(response.body);
    } catch (e) {
      print('Error saving voice room: $e');
    }
  }

  List<ValueNotifier<ZIMKitConversation>> filterConversationsByType(
    List<ValueNotifier<ZIMKitConversation>> conversations,
    ZIMConversationType type,
  ) {
    return conversations.where((conversation) {
      try {
        String conversationId = conversation.value.id;
        bool isPublicGroup = publicGroupIds.contains(int.tryParse(conversationId) ?? -1);
        return conversation.value.type == type && (showPublicChats ? isPublicGroup : !isPublicGroup);
      } catch (e) {
        print('Error parsing conversation ID: $e');
        return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Conversations'),
        actions: [
          IconButton(
            icon: Icon(Icons.public),
            onPressed: () {
              setState(() {
                showPublicChats = true;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.lock),
            onPressed: () {
              setState(() {
                showPublicChats = false;
              });
            },
          ),
        ],
      ),
      body: Center(
        child: ZIMKitConversationListView(
          filter: (context, conversations) => filterConversationsByType(
            conversations,
            ZIMConversationType.group,
          ),
          onPressed: (context, conversation, defaultAction) async {
            bool isAdmin = false;
            if (conversation.type == ZIMConversationType.group) {
              try {
                isAdmin = await isUserAdmin(conversation.id, widget.userId);
              } catch (e) {
                print('Error checking admin status: $e');
              }
            } else {
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return ZIMKitMessageListPage(
                    conversationID: conversation.id,
                    conversationType: conversation.type,
                    appBarActions: conversation.type ==
                                ZIMConversationType.group &&
                            isAdmin
                        ? [
                            ElevatedButton(
                              onPressed: () async {
                                var uuid = const Uuid();
                                String voiceChatID = uuid.v4();
                                print('Conversation Id: $conversation.id');
                                await saveVoiceRoom(
                                    conversation.id, voiceChatID);
                                print('Generated Voice Chat ID: $voiceChatID');
                              },
                              child: const Text('Start Now'),
                            ),
                          ]
                        : [
                            ElevatedButton(
                              onPressed: () {
                                String voiceChatID = '5fo#Dg'; // Placeholder ID
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LivePage(
                                      roomID: voiceChatID,
                                      userId: widget.userId,
                                      user_name: widget.userName,
                                      isHost: false,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Join Now'),
                            ),
                          ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
