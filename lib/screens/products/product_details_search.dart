// ignore_for_file: prefer_const_constructors, prefer_typing_uninitialized_variables, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/services/product_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';

class ProductDetailsSearch extends SearchDelegate {
  ProductDetailsSearch({
    String hintText = "Scan or Search Item",
  }) : super(
          searchFieldLabel: hintText,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
        );

  final ProductDB db = ProductDB();
  final CollectionReference _productCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('products');

  String barcode = '';
  //*BARCODE SCAN
  Future _scanBarcode(BuildContext context) async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      "#ff6666",
      "Cancel",
      true,
      ScanMode.BARCODE,
    );
    query = barcodeScanRes;
    if (query == '-1') {
      query = '';
    }
  }

  @override
  String get searchFieldLabel => 'Scan or Search Item';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        onPressed: () {
          _scanBarcode(context);
        },
        icon: Icon(Icons.camera),
      ),
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    var dayDifference;
    return StreamBuilder<QuerySnapshot>(
      stream: _productCollection
          .orderBy('expiryDate', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('List is currently empty, try adding items'),
          );
        } else {
          if (snapshot.data!.docs
              .where((QueryDocumentSnapshot<Object?> element) => element['name']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
              .isEmpty) {
            return Center(child: Text('No item found'));
          } else {
            //*FETCH DATA HERE
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
                            .where((QueryDocumentSnapshot<Object?> element) =>
                                element['name']
                                    .toString()
                                    .toLowerCase()
                                    .contains(query.toLowerCase()))
                            .map((QueryDocumentSnapshot<Object?> data) {
                          final String name = data.get('name');
                          final String photoURL = data.get('photoURL');
                          final int numOfItemSold = data.get('numOfItemSold');
                          final int quantity = data.get('quantity');
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
                              title: Text(name),
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
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    var dayDifference;
    return StreamBuilder<QuerySnapshot>(
      stream: _productCollection
          .orderBy('expiryDate', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('List is currently empty, try adding items'),
          );
        } else {
          if (snapshot.data!.docs
              .where((QueryDocumentSnapshot<Object?> element) =>
                  element['barcode']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()))
              .isEmpty) {
            return Center(child: Text('Press Search key to search item'));
          } else {
            //*FETCH DATA HERE
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
                            .where((QueryDocumentSnapshot<Object?> element) =>
                                element['barcode']
                                    .toString()
                                    .toLowerCase()
                                    .contains(query.toLowerCase()))
                            .map((QueryDocumentSnapshot<Object?> data) {
                          final String name = data.get('name');
                          final String photoURL = data.get('photoURL');
                          final int numOfItemSold = data.get('numOfItemSold');
                          final int quantity = data.get('quantity');
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
                              title: Text(name),
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
        }
      },
    );
  }
}
