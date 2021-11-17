// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/controllers/auth_controller.dart';
import 'package:easi/screens/products/functions/product_edit.dart';
import 'package:easi/services/notification_database.dart';
import 'package:easi/widgets/app_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  static final _authController = Get.find<AuthController>(); //user data
  final NotificationDB ndb = NotificationDB();

  final CollectionReference _notificationsCollection = FirebaseFirestore
      .instance
      .collection('users')
      .doc(_authController.user!.uid)
      .collection('notifications');

  final CollectionReference _productCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(_authController.user!.uid)
      .collection('products');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: getBody(),
    );
  }

  Widget getBody() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: StreamBuilder(
        stream: _notificationsCollection.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Loading(),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No notifications yet.'),
            );
          } else {
            return ListView(
              children: [
                ...snapshot.data!.docs
                    .map((QueryDocumentSnapshot<Object?> data) {
                  final String expiryMessage = data.get('expiryMessage');
                  final String expiryDateStatus = data.get('expiryDateStatus');
                  final String quantityMessage = data.get('quantityMessage');
                  final String quantityStatus = data.get('quantityStatus');
                  final String productId = data.get('productId');

                  return Column(
                    children: [
                      StreamBuilder(
                        stream: _productCollection.doc(productId).snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: Loading(),
                            );
                          } else {
                            final String name = snapshot.data!['name'];
                            final String barcode = snapshot.data!['barcode'];
                            final String category = snapshot.data!['category'];
                            final String expiryDate =
                                snapshot.data!['expiryDate'];
                            final String photoUrl = snapshot.data!['photoURL'];
                            final double price = snapshot.data!['price'];
                            final int quantity = snapshot.data!['quantity'];

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                elevation: 4,
                                margin: EdgeInsets.fromLTRB(4, 2, 4, 2),
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: ListTile(
                                    onTap: () {
                                      Get.to(
                                        () => ProductEdit(
                                          productId: productId,
                                          barcode: barcode,
                                          photoUrl: photoUrl,
                                          name: name,
                                          category: category,
                                          price: price,
                                          quantity: quantity,
                                          expiryDate: expiryDate,
                                        ),
                                      );
                                    },
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: photoUrl == ""
                                          ? Image.network(
                                              "https://i.ibb.co/r7pkB30/default-thumbnail-icon.png",
                                              width: 50,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.network(
                                              photoUrl,
                                              width: 50,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        expiryMessage == ""
                                            ? Container()
                                            : Text(
                                                expiryMessage,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                        expiryDateStatus == ""
                                            ? Container()
                                            : Text(
                                                expiryDateStatus,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                        quantityMessage == ""
                                            ? Container()
                                            : Text(
                                                quantityMessage,
                                                style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.black,
                                                ),
                                              ),
                                        quantityStatus == ""
                                            ? Container()
                                            : Text(
                                                quantityStatus,
                                                style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.black,
                                                ),
                                              ),
                                      ],
                                    ),
                                    trailing: Icon(
                                      Icons.keyboard_arrow_right_sharp,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      )
                    ],
                  );
                }),
              ],
            );
          }
        },
      ),
    );
  }
}
