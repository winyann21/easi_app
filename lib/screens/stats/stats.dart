// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/controllers/auth_controller.dart';
import 'package:easi/services/product_database.dart';
import 'package:easi/services/sales_database.dart';
import 'package:easi/widgets/app_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Stats extends StatefulWidget {
  const Stats({Key? key}) : super(key: key);

  @override
  _StatsState createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  static final _authController = Get.find<AuthController>(); //user data
  final SalesDB sdb = SalesDB();
  final ProductDB db = ProductDB();

  final CollectionReference _salesCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(_authController.user!.uid)
      .collection('sales');

  final CollectionReference _productCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(_authController.user!.uid)
      .collection('products');

  var date = DateTime.now().add(Duration(hours: 8));
  late String dateMonth = DateFormat('MMMM').format(date);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: salesBody(),
    );
  }

  Widget salesBody() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: StreamBuilder(
        stream:
            _salesCollection.where('month', isEqualTo: dateMonth).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Loading(),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No data yet.'),
            );
          } else {
            return ListView(
              children: [
                ...snapshot.data!.docs
                    .map((QueryDocumentSnapshot<Object?> data) {
                  final String month = data.get('month');
                  final double totalSales = data.get('totalSales');

                  return Column(
                    children: [
                      SizedBox(height: 15.0),
                      //*MONTH TITLE
                      Text(
                        month,
                        style: TextStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 15.0),

                      //*TOTAL SALES
                      Text('Total Sales'),
                      totalSales < 0
                          ? Text(
                              '0.00',
                              style: TextStyle(
                                fontSize: 26.0,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : Text(
                              totalSales.toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 26.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                      StreamBuilder(
                        stream: _productCollection
                            .orderBy('numOfItemSold', descending: true)
                            .limit(1)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Text('No data yet'),
                            );
                          } else {
                            return Column(
                              children: [
                                ...snapshot.data!.docs.map(
                                  (QueryDocumentSnapshot<Object?> data) {
                                    final String itemName = data.get('name');
                                    final int numOfItemSold =
                                        data.get('numOfItemSold');
                                    final String photoURL =
                                        data.get('photoURL');
                                    return Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: numOfItemSold == 0
                                          ? Center(
                                              child: Text(
                                                  'No marketable item yet.'),
                                            )
                                          : Card(
                                              margin: EdgeInsets.fromLTRB(
                                                  4, 2, 4, 2),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: ListTile(
                                                  leading: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: photoURL == ""
                                                        ? Image.network(
                                                            "https://i.ibb.co/r7pkB30/default-thumbnail-icon.png",
                                                            width: 70,
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Image.network(
                                                            photoURL,
                                                            width: 70,
                                                            fit: BoxFit.cover,
                                                          ),
                                                  ),
                                                  //*ITEM NAME
                                                  title: Column(
                                                    children: [
                                                      Text(
                                                        'Most sold item:',
                                                        style: TextStyle(
                                                          fontSize: 16.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      Text(
                                                        itemName,
                                                        style: TextStyle(
                                                          fontSize: 16.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  //*Number of Item Sold
                                                  trailing: Text(
                                                    numOfItemSold.toString(),
                                                    style: TextStyle(
                                                      fontSize: 16.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                    );
                                  },
                                ),
                              ],
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
