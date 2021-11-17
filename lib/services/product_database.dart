// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/controllers/auth_controller.dart';
import 'package:get/get.dart';

class ProductDB {
  // final currentUser = FirebaseAuth.instance.currentUser!;
  // Users user = Users(uid: FirebaseAuth.instance.currentUser!.uid);

  final _authController = Get.find<AuthController>(); //user data
  late CollectionReference productCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(_authController.user!.uid)
      .collection('products');

  //*CREATE PRODUCTS
  Future<void> addProduct({
    required int uniqueID,
    required String barcode,
    required String name,
    required String category,
    required int quantity,
    required double price,
    required String expiryDate,
    required String photoURL,
    required int numOfItemSold,
  }) async {
    try {
      await productCollection.add({
        'uniqueID': uniqueID,
        'photoURL': photoURL,
        'barcode': barcode,
        'name': name,
        'category': category,
        'quantity': quantity,
        'price': price,
        'numOfItemSold': numOfItemSold,
        'expiryDate': expiryDate,
        'dateAdded': FieldValue.serverTimestamp(),
        'dateUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print(e);
    }
  }

  //*UPDATE PRODUCTS
  Future<void> updateProduct({
    required String id,
    required String barcode,
    required String name,
    required String category,
    required int quantity,
    required double price,
    required String expiryDate,
    required String photoURL,
  }) async {
    try {
      await productCollection.doc(id).update({
        'photoURL': photoURL,
        'barcode': barcode,
        'name': name,
        'category': category,
        'quantity': quantity,
        'price': price,
        'expiryDate': expiryDate,
        'dateUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print(e);
    }
  }

  //*DELETE PRODUCTS
  void deleteProduct({required String id}) async {
    try {
      await productCollection.doc(id).delete();
    } catch (e) {
      print(e);
    }
  }

  //*PURCHASE PRODUCTS
  Future<void> purchaseProduct({
    required String id,
    required int quantity,
    required int numOfItemSold,
  }) async {
    try {
      await productCollection.doc(id).update({
        'quantity': quantity,
        'numOfItemSold': numOfItemSold,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> resetItemSold(
      {required int numOfItemSold, required String id}) async {
    try {
      await productCollection.doc(id).update({
        'numOfItemSold': numOfItemSold,
      });
    } catch (e) {
      print(e);
    }
  }
}
