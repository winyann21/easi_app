// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/controllers/auth_controller.dart';
import 'package:easi/screens/products/product_status.dart';
import 'package:easi/services/product_database.dart';
import 'package:easi/services/sales_database.dart';
import 'package:easi/widgets/app_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  var dayDifference;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(flex: 2, child: salesBody()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Divider(
              color: Colors.black,
            ),
          ),
          Expanded(flex: 4, child: expiryItems()),
        ],
      ),
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
                      SizedBox(height: 10.0),
                      //*MONTH TITLE
                      Text(
                        month,
                        style: TextStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      //*TOTAL SALES
                      Text('Total Sales'),
                      totalSales < 0
                          ? Text(
                              '0.00',
                              style: TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : Text(
                              totalSales.toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                      SizedBox(height: 10.0),
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
                                    final String? itemName =
                                        toBeginningOfSentenceCase(
                                            data.get('name'));
                                    final int numOfItemSold =
                                        data.get('numOfItemSold');
                                    final String photoURL =
                                        data.get('photoURL');
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24.0,
                                      ),
                                      child: numOfItemSold == 0
                                          ? Center(
                                              child: Text(
                                                  'No marketable item yet.'),
                                            )
                                          : Card(
                                              elevation: 4,
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
                                                        itemName!,
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

  Widget expiryItems() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: StreamBuilder(
        stream: _productCollection
            .orderBy('expiryDate', descending: true)
            .limit(5)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Loading(),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No items yet.'),
            );
          } else {
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Products Status",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.to(() => ProductStatus());
                            },
                            child: Text('See all >'),
                          ),
                        ],
                      ),
                    ),
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        ...snapshot.data!.docs
                            .map((QueryDocumentSnapshot<Object?> data) {
                          final String? name =
                              toBeginningOfSentenceCase(data.get('name'));
                          final String photoURL = data.get('photoURL');
                          final int quantity = data.get('quantity');
                          final int numOfItemSold = data.get('numOfItemSold');
                          var getDateNow = DateTime.now();
                          String getExpiryDate = data.get('expiryDate');

                          int daysBetween(DateTime from, DateTime to) {
                            from = DateTime(from.year, from.month, from.day);
                            to = DateTime(to.year, to.month, to.day);
                            return (to.difference(from).inDays).round();
                          }

                          final dateNow = DateTime.now();
                          final expDate = DateTime.parse(
                            getExpiryDate == ""
                                ? getDateNow.toString()
                                : getExpiryDate,
                          );
                          dayDifference = daysBetween(dateNow, expDate);

                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: ListTile(
                              leading: Icon(
                                Icons.label,
                                color: Colors.black38,
                              ),
                              title: Text(name!),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //if expiryDate = "" dont show that data
                                  //show expiry date show many days left
                                  //show items left (quantity)

                                  getExpiryDate == ""
                                      ? Container()
                                      : Text.rich(
                                          TextSpan(
                                            text: '$dayDifference ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            children: <InlineSpan>[
                                              TextSpan(
                                                text: 'day/s until expired.',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                  quantity < 10
                                      ? Text.rich(
                                          TextSpan(
                                            text: 'Restock now, Item/s left: ',
                                            children: <InlineSpan>[
                                              TextSpan(
                                                text: '$quantity',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Text.rich(
                                          TextSpan(
                                            text: 'Item/s left: ',
                                            children: <InlineSpan>[
                                              TextSpan(
                                                text: '$quantity',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                  Text.rich(
                                    TextSpan(
                                      text: 'Number of item sold: ',
                                      children: <InlineSpan>[
                                        TextSpan(
                                          text: '$numOfItemSold',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: photoURL == ""
                                    ? Image.network(
                                        "https://i.ibb.co/r7pkB30/default-thumbnail-icon.png",
                                        width: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        photoURL,
                                        width: 50,
                                        fit: BoxFit.cover,
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
