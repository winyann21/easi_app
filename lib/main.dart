// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_new

import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:easi/controller_bindings.dart';
import 'package:easi/utils/root.dart';
import 'package:easi/utils/show_loading.dart';
import 'package:easi/widgets/app_loading.dart';
import 'package:easi/widgets/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', //*id,
    'High Importance Channel', //*title,
    importance: Importance.high,
    playSound: true //*description,

    );

final FlutterLocalNotificationsPlugin _notificationsPlugin =
    FlutterLocalNotificationsPlugin();

final notificationDetails = NotificationDetails(
  android: AndroidNotificationDetails(
    channel.id,
    channel.name,
    color: Colors.orange,
    playSound: true,
    icon: 'app_icon',
  ),
);

// *FOR BG NOTIF
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //*FOR BG NOTIF
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await _notificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isConnected = false;
  // ignore: cancel_subscriptions
  late StreamSubscription<ConnectivityResult> sub;

  @override
  void initState() {
    super.initState();
    sub = Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        isConnected = (result != ConnectivityResult.none);
      });
    });

    var androidInitialize =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        new InitializationSettings(android: androidInitialize);
    _notificationsPlugin.initialize(initializationSettings);

    //*APP IS TERMINATED
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        RemoteNotification notification = message.notification!;
        AndroidNotification? android = message.notification?.android;
        // ignore: unnecessary_null_comparison
        if (notification != null && android != null) {
          _notificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            notificationDetails,
          );
        }
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification!;
      AndroidNotification? android = message.notification?.android;

      // ignore: unnecessary_null_comparison
      if (notification != null && android != null) {
        _notificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          notificationDetails,
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification!;
      AndroidNotification? android = message.notification?.android;

      // ignore: unnecessary_null_comparison
      if (notification != null && android != null) {
        _notificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          notificationDetails,
        );
      }
    });
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: ControllerBindings(),
      theme: appTheme(),
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      getPages: [
        GetPage(name: "/", page: () => Root()),
      ],
      home: isConnected
          ? Root()
          : Scaffold(
              body: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Loading(),
                      SizedBox(height: 10),
                      Text('Waiting for internet connection...'),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
