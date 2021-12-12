// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/controllers/auth_controller.dart';
import 'package:get/get.dart';

class PurchasedItemsDB {
  final _authController = Get.find<AuthController>(); //user data
  late CollectionReference purchasedItemsCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(_authController.user!.uid)
      .collection('purchasedItems');

  //*ADD SALES
  Future<void> addPurchasedItems({
    required String id,
    required String name,
    required String barcode,
    required String expiryDate,
    required String category,
    required Timestamp dateCreated,
    required int quantitySold,
    required int quantity,
    required int currentItemSold,
    required double price,
    required double totalPrice,
  }) async {
    try {
      await purchasedItemsCollection.doc(id).set({
        'id': id,
        'name': name.toLowerCase(),
        'barcode': barcode,
        'expiryDate': expiryDate,
        'dateCreated': dateCreated,
        'category': category,
        'quantity': quantity,
        'quantitySold': quantitySold,
        'currentItemSold': currentItemSold,
        'price': price,
        'totalPrice': totalPrice,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> updatePurchasedItems({
    required String id,
    required String name,
    required String barcode,
    required String expiryDate,
    required Timestamp dateCreated,
    required String category,
    required int quantitySold,
    required int quantity,
    required int currentItemSold,
    required double price,
    required double totalPrice,
  }) async {
    try {
      await purchasedItemsCollection.doc(id).update({
        'id': id,
        'name': name.toLowerCase(),
        'barcode': barcode,
        'expiryDate': expiryDate,
        'category': category,
        'dateCreated': dateCreated,
        'quantity': quantity,
        'quantitySold': quantitySold,
        'currentItemSold': currentItemSold,
        'price': price,
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
