// ignore_for_file: prefer_const_constructors, unused_element

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', //*id,
      'High Importance Channel', //*title,
      importance: Importance.high,
      playSound: true //*description,
      );

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      channel.id,
      channel.name,
      color: Colors.orange,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    ),
  );

//*FOR BG NOTIF
  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
  }
}
