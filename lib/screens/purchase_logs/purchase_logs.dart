// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/controllers/auth_controller.dart';
import 'package:easi/services/purchase_logs_database.dart';
import 'package:easi/widgets/app_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PurchaseLogs extends StatefulWidget {
  const PurchaseLogs({Key? key}) : super(key: key);

  @override
  _PurchaseLogsState createState() => _PurchaseLogsState();
}

class _PurchaseLogsState extends State<PurchaseLogs> {
  static final _authController = Get.find<AuthController>(); //user data
  final PurchaseLogsDB pldb = PurchaseLogsDB();
  final CollectionReference _purchasedLogsCollection = FirebaseFirestore
      .instance
      .collection('users')
      .doc(_authController.user!.uid)
      .collection('purchaseLogs');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
      appBar: AppBar(
        centerTitle: true,
        title: Text('Purchase History'),
        actions: [
          IconButton(
            onPressed: () {
              //clear history
            },
            icon: Icon(Icons.delete_sweep_sharp),
          ),
        ],
      ),
    );
  }

  Widget getBody() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: StreamBuilder(
        stream: _purchasedLogsCollection
            .orderBy('numOfItemSold', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Loading(),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No purchase history made yet.'),
            );
          } else {
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 15),
                    ListView(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      children: [
                        ...snapshot.data!.docs
                            .map((QueryDocumentSnapshot<Object?> data) {
                          final String? name =
                              toBeginningOfSentenceCase(data.get('name'));
                          final int numOfItemSold = data.get('numOfItemSold');
                          final double totalPrice = data.get('totalPrice');
                          Timestamp time =
                              data.get('datePurchased') ?? Timestamp.now();
                          DateTime date = DateTime.fromMicrosecondsSinceEpoch(
                              time.microsecondsSinceEpoch);
                          final String datePurchased =
                              DateFormat.yMd().add_jm().format(date);

                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: ListTile(
                              leading: Icon(
                                Icons.history_sharp,
                                color: Colors.black38,
                              ),
                              title: Text(name!),
                              subtitle: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total Price: $totalPrice'),
                                  Text('Date Purchased: $datePurchased'),
                                ],
                              ),
                              trailing: Text(
                                'Sold: $numOfItemSold',
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
