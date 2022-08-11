import 'dart:async';

import 'package:blueshift_flutter_plugin/blueshift.dart';
import 'package:blueshift_flutter_plugin_example/pages/deeplink_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'utils/routes.dart';

Future<void> _handleRemoteMessage(RemoteMessage message) async {
  print("Push Notification recieved on the Flutter");
  Blueshift.handlePushNotification(message.data);
}

Future<void> main() async {
  initialiseFirebase();
  runApp(MyApp());
}

Future<void> initialiseFirebase() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // https://github.com/firebase/flutterfire/issues/6011
  await FirebaseMessaging.instance.getToken();
  // listen for notification while the app is in background or terminated.
  FirebaseMessaging.onBackgroundMessage(_handleRemoteMessage);
  var _messaging = FirebaseMessaging.instance;

  String? token = await _messaging.getToken();
  print("The firebase token is " + (token ?? "NA"));

  String? APNStoken = await _messaging.getAPNSToken();
  print("The APNS token is " + (APNStoken ?? "NA"));

  // For handling the received notifications
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("Firebase push clicked");
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    _handleRemoteMessage(message);
  });

  //iOS config - Show push notification when app is running in foreground
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true, // Required to display a heads up notification
    badge: true,
    sound: true,
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.light,
      theme: ThemeData(primarySwatch: Colors.blue),
      darkTheme:
          ThemeData(brightness: Brightness.dark, primarySwatch: Colors.grey),
      // initialRoute: "/home",
      routes: {
        "/": (context) => const LoginPage(),
        MyRoutes.loginRoute: (context) => const LoginPage(),
        MyRoutes.homeRoute: (context) => const MyHomePage(),
        MyRoutes.deeplinkRoute: (context) => DeeplinkPage(
              deeplink: '',
            ),
      },
    );
  }
}
