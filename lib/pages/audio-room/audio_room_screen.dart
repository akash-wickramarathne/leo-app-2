import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/zego_uikit_prebuilt_live_audio_room.dart';
import 'package:iconsax/iconsax.dart';
import '../../zego files/initial.dart';

class LivePage extends StatelessWidget {
  final String roomID;
  final bool isHost;
  final String userId;
  final String user_name;

  const LivePage(
      {Key? key,
      required this.roomID,
      this.isHost = false,
      required this.userId,
      required this.user_name})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Stack(
      // Use Stack widget to position icons on top of the ZegoUIKitPrebuiltLiveAudioRoom
      children: [
        ZegoUIKitPrebuiltLiveAudioRoom(
          appID: Initial.id,
          appSign: Initial.signIn,
          userID: userId,
          userName: user_name,
          roomID: roomID,
          config: (isHost
              ? (ZegoUIKitPrebuiltLiveAudioRoomConfig.host()
                ..seat.takeIndexWhenJoining = 0
                ..background = background(
                    imagePath: 'assets/images/voice-room-background.jpg'))
              : ZegoUIKitPrebuiltLiveAudioRoomConfig.audience()
            ..background = background(
                imagePath: 'assets/images/voice-room-background.jpg'))
            ..seat.layout.rowConfigs = [
              ZegoLiveAudioRoomLayoutRowConfig(
                  count: 1, alignment: ZegoLiveAudioRoomLayoutAlignment.center),
              ZegoLiveAudioRoomLayoutRowConfig(
                  count: 4,
                  alignment: ZegoLiveAudioRoomLayoutAlignment.spaceAround),
            ],
        ),
        // Position the game icon
        const Positioned(
          bottom: 100.0, // Adjust position as needed
          right: 25.0,
          child: Image(
            image: AssetImage('assets/icons/pikachu.png'),
            width: 32.0,
            height: 32.0,
          ),
        ),
        // Position the rocket icon
        const Positioned(
          bottom: 60.0, // Adjust position as needed
          right: 25.0,
          child: Image(
            image: AssetImage('assets/icons/gift-box.png'),
            width: 32.0,
            height: 32.0,
          ),
        ),
      ],
    ));
  }

  Widget background({required String imagePath}) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath), // Set the image path
          fit: BoxFit
              .cover, // Adjust how the image fills the container (optional)
        ),
      ),
    );
  }
}
