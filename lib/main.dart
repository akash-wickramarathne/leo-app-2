import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leo_final/pages/wallet/wallet_screen.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

import 'package:leo_final/pages/home%20page/bloc/home_page_bloc.dart';
import 'package:leo_final/pages/welcome%20page/welcome_page.dart';
import 'package:leo_final/zego%20files/initial.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

import 'pages/home page/home_page.dart';

///final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ZIMKit().init(
    appID: Initial.id,
    appSign: Initial.signIn,
  );
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

  ZegoUIKit().initLog().then((value) {
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
      [ZegoUIKitSignalingPlugin()],
    );

    runApp(MyApp(navigatorKey: navigatorKey));
  });
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({Key? key, required this.navigatorKey}) : super(key: key);

  Future<Map<String, dynamic>?> _checkUserLoggedIn() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/user.json');
    if (await file.exists()) {
      final userJson = await file.readAsString();
      final userData = jsonDecode(userJson) as Map<String, dynamic>;
      return userData;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _checkUserLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          final userData = snapshot.data!;
          final userId = userData['id'].toString();
          final name = userData['name'] ?? 'Unknown';
          final about = userData['about'] ?? 'Unknown';
          return BlocProvider(
            create: (context) => HomePageBloc(),
            child: ScreenUtilInit(
              builder: (context, child) => MaterialApp(
                navigatorKey: navigatorKey,
                debugShowCheckedModeBanner: false,
                title: 'Flutter Demo',
                theme: ThemeData.light().copyWith(
                  primaryColor: Colors.blue,
                ),
                home: MyHomePage(userId: userId, about: about, name: name),
                routes: {
                  '/wallet': (context) => const WalletScreen(),
                },
              ),
            ),
          );
        } else {
          return BlocProvider(
            create: (context) => HomePageBloc(),
            child: ScreenUtilInit(
              builder: (context, child) => MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Flutter Demo',
                theme: ThemeData.light().copyWith(
                  primaryColor: Colors.blue,
                ),
                home: const WelcomePage(),
              ),
            ),
          );
        }
      },
    );
  }
}
