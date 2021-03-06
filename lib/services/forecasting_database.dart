// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/controllers/auth_controller.dart';
import 'package:get/get.dart';

class ForecastDB {
  final _authController = Get.find<AuthController>(); //user data
  late CollectionReference forecastCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(_authController.user!.uid)
      .collection('forecastedItem');

  //*CREATE PRODUCTS
  Future<void> addForecastedItem({
    required int uniqueID,
    required String prodId,
    required String name,
    required int numOfItemSold,
    required String month,
    required double price,
    required String photoUrl,
    required int quantityLeft,
  }) async {
    try {
      await forecastCollection.doc(month).collection('products').doc(prodId).set({
        'month': month,
        'uniqueID': uniqueID,
        'photoUrl': photoUrl,
        'name': name.toLowerCase(),
        'numOfItemSold': numOfItemSold,
        'price': price,
        'dateForecasted': FieldValue.serverTimestamp(),
        'quantityLeft': quantityLeft,
      });
    } catch (e) {
      print(e);
    }
  }
}
