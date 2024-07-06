import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:leo_final/pages/games/games.dart';
import 'package:leo_final/pages/group/group.dart';
import 'package:leo_final/pages/profile/profile.dart';
import 'package:leo_final/widgets/call_invitation.dart';
import 'package:lottie/lottie.dart';
import 'package:uuid/uuid.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:zego_zimkit/zego_zimkit.dart';
import 'package:http/http.dart' as http;
import '../../zego files/initial.dart';
import '../voice-calls/voiceCall.dart';

Widget buildBottomTabs(int index, String userId, String name) {
  List<Widget> tabs = [
    tabBarView(userId, name),
    Group(
      userId: userId,
      userName: name,
    ),
    const Games(),
    const Profile(),
  ];

  return tabs[index];
}

List<ValueNotifier<ZIMKitConversation>> filterConversationsByType(
  List<ValueNotifier<ZIMKitConversation>> conversations,
  ZIMConversationType type,
) {
  return conversations
      .where((conversation) => conversation.value.type == type)
      .toList();
}

String generateRandomCallId() {
  var uuid = Uuid();
  return uuid.v4();
}

Future<String> _getOrGenerateCallID(String senderID, String receiverID) async {
  final response = await http.get(Uri.parse(
      'http://45.126.125.172:8080/api/v1/getCallerId?senderID=$senderID&receiverId=$receiverID'));
  if (response.statusCode == 200) {
    print(response.body);
    final data = json.decode(response.body);
    if (data['exists'] && data['details']['callerId'] != null) {
      return data['details']['callerId'].toString();
    } else {
      var uuid = const Uuid();
      String callID = uuid.v4();
      const String url = 'http://45.126.125.172:8080/api/v1/addOrUpdateCall';
      final Map<String, String> queryParams = {
        'senderID': senderID,
        'callerId': callID,
        'receiverId': receiverID,
      };
      final Uri uri = Uri.parse(url).replace(queryParameters: queryParams);
      print(uri);
      final saveResponse = await http.post(uri);
      print(saveResponse.statusCode.toString());
      print(saveResponse.body);
      if (saveResponse.statusCode == 200) {
        return callID;
      } else {
        throw Exception('Failed to save call ID');
      }
    }
  } else {
    throw Exception('Failed to fetch call ID');
  }
}

Widget tabBarView(String userId, String name) {
  return TabBarView(
    children: [
      ZIMKitConversationListView(
        filter: (context, conversations) =>
            filterConversationsByType(conversations, ZIMConversationType.peer),
        onPressed: (context, conversation, defaultAction) {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return ZIMKitMessageListPage(
                conversationID: conversation.id,
                conversationType: conversation.type,
                appBarActions: [
                  IconButton(
                    onPressed: () async {
                      final callID =
                          await _getOrGenerateCallID(userId, conversation.id);
                      ZegoUIKitPrebuiltCallInvitationService().init(
                          appID: Initial.id /*input your AppID*/,
                          appSign: Initial.signIn /*input your AppSign*/,
                          userID: userId,
                          userName: name,
                          plugins: [ZegoUIKitSignalingPlugin()]);

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CallInvitationWidget(
                                    userId: conversation.id,
                                    username: 'l',
                                    callID: callID,
                                  )));
                    },
                    icon: const Icon(Icons.call),
                  ),
                  IconButton(
                    onPressed: () async {
                      var uuid = const Uuid();
                      String callID = uuid.v4();
                      await Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return CallPage(
                            callID: callID,
                            userID: userId,
                            userName: name,
                          );
                        },
                      ));
                    },
                    icon: const Icon(Icons.video_call),
                  ),
                ],
              );
            },
          ));
        },
      ),
      Center(
        child: Lottie.asset('assets/SVIP1AvatarFrame.json'),
      ),
      const Center(child: Text('Call feature is coming soon')),
    ],
  );
}
