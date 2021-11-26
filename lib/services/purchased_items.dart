// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PurchasedItemsDB {
  final _authController = Get.find<AuthController>(); //user data
  late CollectionReference purchasedItemsCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(_authController.user!.uid)
      .collection('purchasedItems');
  String dateMonth = DateFormat('MMMM').format(DateTime.now());

  //*ADD SALES
  Future<void> addPurchasedItems({
    required String id,
    required String name,
    required int quantity,
    required double totalPrice,
  }) async {
    try {
      await purchasedItemsCollection.add({
        'id': id,
        'name': name,
        'quantity': quantity,
        'totalPrice': totalPrice,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> deletePurchasedItems({
    required String id,
  }) async {
    try {
      await purchasedItemsCollection.doc(id).delete();
    } catch (e) {
      print(e);
    }
  }
}
