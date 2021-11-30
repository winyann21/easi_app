// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SalesDB {
  final _authController = Get.find<AuthController>(); //user data
  late CollectionReference salesCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(_authController.user!.uid)
      .collection('sales');
  var date = DateTime.now().add(Duration(hours: 8));
  late String dateMonth = DateFormat('MMMM').format(date);

  //*ADD SALES
  Future<void> addSales({
    required double totalSales,
    required String month,
  }) async {
    try {
      await salesCollection.doc(month).set({
        'totalSales': totalSales,
        'month': month,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateSales({
    required double totalSales,
    required String month,
  }) async {
    try {
      await salesCollection.doc(month).update({
        'totalSales': totalSales,
      });
    } catch (e) {
      print(e);
    }
  }
}
