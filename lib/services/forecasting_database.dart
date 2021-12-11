// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/controllers/auth_controller.dart';
import 'package:get/get.dart';

class ForecastDB {
  // final currentUser = FirebaseAuth.instance.currentUser!;
  // Users user = Users(uid: FirebaseAuth.instance.currentUser!.uid);

  final _authController = Get.find<AuthController>(); //user data
  late CollectionReference forecastCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(_authController.user!.uid)
      .collection('forecastedItem');

  //*CREATE PRODUCTS
  Future<void> addForecastedItem({
    required int uniqueID,
    required String name,
    required int numOfItemSold,
    required String month,
    required double price,
    required int quantityLeft,
    required String photoUrl,
  }) async {
    try {
      await forecastCollection.doc(month).set({
        'month': month,
        'uniqueID': uniqueID,
        'photoUrl': photoUrl,
        'name': name,
        'numOfItemSold': numOfItemSold,
        'price': price,
        'dateForecasted': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print(e);
    }
  }
}
