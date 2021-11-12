// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/controllers/auth_controller.dart';
import 'package:get/get.dart';

class NotificationDB {
  // final currentUser = FirebaseAuth.instance.currentUser!;
  // Users user = Users(uid: FirebaseAuth.instance.currentUser!.uid);
  final _authController = Get.find<AuthController>(); //user data
  late CollectionReference notificationCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(_authController.user!.uid)
      .collection('notifications');

  //*INSERT NOTIF TO DB
  Future<void> addNotif({
    required String expiryMessage,
    required String expiryDateStatus,
    required String quantityMessage,
    required String quantityStatus,
    required String id,
    required String productId,
  }) async {
    try {
      await notificationCollection.doc(id).set({
        'productId': productId,
        'expiryMessage': expiryMessage,
        'expiryDateStatus': expiryDateStatus,
        'quantityMessage': quantityMessage,
        'quantityStatus': quantityStatus,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteNotif({
    required String id,
  }) async {
    try {
      await notificationCollection.doc(id).delete();
    } catch (e) {
      print(e);
    }
  }
}
