// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/controllers/auth_controller.dart';
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
                        stream: _productCollection
                            .doc(productId) //ID OF DOCUMENT
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: Loading(),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Card(
                                margin: const EdgeInsets.all(12.0),
                                child: ListTile(
                                  onTap: () {},
                                  title: Text(
                                    expiryMessage,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            expiryDateStatus,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Row(
                                      //   children: [
                                      //     Text(
                                      //       quantityMessage, //TODO:: IF NOT QUANTITY NOTIF
                                      //       style: TextStyle(
                                      //         fontWeight: FontWeight.bold,
                                      //         color: Colors.black,
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),
                                      // Row(
                                      //   children: [
                                      //     Text(
                                      //       quantityStatus,
                                      //       style: TextStyle(
                                      //         fontWeight: FontWeight.bold,
                                      //         color: Colors.black,
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),
                                    ],
                                  ),
                                  trailing: Icon(
                                    Icons.keyboard_arrow_right_sharp,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
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
