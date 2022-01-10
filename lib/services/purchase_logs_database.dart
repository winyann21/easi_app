// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/controllers/auth_controller.dart';
import 'package:get/get.dart';

class PurchaseLogsDB {
  final _authController = Get.find<AuthController>(); //user data
  late CollectionReference purchaseLogs = FirebaseFirestore.instance
      .collection('users')
      .doc(_authController.user!.uid)
      .collection('purchaseLogs');

  Future<void> addToLogs({
    required String id,
    required String name,
    required int numOfItemSold,
    required double totalPrice,
  }) async {
    try {
      await purchaseLogs.add({
        'id': id,
        'name': name.toLowerCase(),
        'numOfItemSold': numOfItemSold,
        'totalPrice': totalPrice,
        'datePurchased': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print(e);
    }
  }
}
