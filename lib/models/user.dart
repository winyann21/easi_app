import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? id;
  String? name;
  String? email;
  bool? isVerified;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.isVerified,
  });

  UserModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    id = doc.id;
    name = doc['name'];
    email = doc['email'];
    isVerified = doc['isVerified'];
  }
}
