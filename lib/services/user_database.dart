// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/models/user.dart';

class UserDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //create user and set data to firestore
  Future<bool> createNewUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set({
        'name': user.name,
        'email': user.email,
        'isVerified': user.isVerified,
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  //get user data(uid)
  Future<UserModel> getUser(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      return UserModel.fromDocumentSnapshot(doc);
    } catch (e) {
      print(e);

      rethrow;
    }
  }
}
