import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import '../pages/voice-calls/voiceCall.dart'; // Import for generating UUID

class CallInvitationWidget extends StatefulWidget {
  const CallInvitationWidget({
    super.key,
    required this.userId,
    required this.username,
    required this.callID,
  });

  final String userId;
  final String username;
  final String callID;

  @override
  State<CallInvitationWidget> createState() => _CallInvitationWidgetState();
}

class _CallInvitationWidgetState extends State<CallInvitationWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ZegoSendCallInvitationButton(
          isVideoCall: true,
          resourceID: "zegouikit_call",
          invitees: [
            ZegoUIKitUser(
              id: widget.userId,
              name: widget.username,
            ),
          ],
          callID: '6776',
        ),
      ),
    );
  }

  // Function to initiate a call with generated callID and navigate to CallPage
  Future<void> initiateCall() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallPage(
            callID: widget.callID,
            userID: widget.userId,
            userName: widget.username,
          ),
        ));
  }
}
