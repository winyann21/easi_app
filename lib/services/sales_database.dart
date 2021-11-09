import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/controllers/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SalesDB {
  final _authController = Get.find<AuthController>(); //user data
  late CollectionReference salesCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(_authController.user!.uid)
      .collection('sales');
  String dateMonth = DateFormat('MMMM').format(DateTime.now());
  bool? docuExists;

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
