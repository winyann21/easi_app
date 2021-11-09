// ignore_for_file: prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/screens/products/functions/product_edit.dart';
import 'package:easi/services/product_database.dart';
import 'package:easi/widgets/app_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';

class ProductSearch extends SearchDelegate {
  ProductSearch({
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
  List<Widget> buildActions(BuildContext context) {
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
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _productCollection
          .orderBy('dateUpdated', descending: true)
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
            return ListView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              children: [
                ...snapshot.data!.docs
                    .where((QueryDocumentSnapshot<Object?> element) =>
                        element['name']
                            .toString()
                            .toLowerCase()
                            .contains(query.toLowerCase()))
                    .map((QueryDocumentSnapshot<Object?> data) {
                  final String name = data.get('name');
                  final double price = data.get('price');
                  final int quantity = data.get('quantity');
                  final String photoURL = data.get('photoURL');

                  //*GET TIMESTAMP DATE ADDED
                  final Timestamp date = data.get('dateAdded');
                  final DateTime dateAdded = date.toDate();
                  final String dateCreated =
                      DateFormat('MM-dd-yyyy').format(dateAdded);

                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Card(
                      margin: EdgeInsets.fromLTRB(4, 2, 4, 2),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductEdit(
                                  data: data,
                                ),
                              ),
                            );
                          },
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  'Delete Product',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                content: Text(
                                    'Are you sure you want to delete this item?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      db.deleteProduct(id: data.id);
                                      Navigator.pop(context, true);
                                      Navigator.pop(context, true);
                                      showToast(msg: 'Product Deleted');
                                    },
                                    child: Text('Yes'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                    child: Text('No'),
                                  ),
                                ],
                              ),
                            );
                          },
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
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
                          title: Text(
                            name,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            children: [
                              Row(
                                children: [
                                  Text('Available Stock(s): ',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                      )),
                                  Text(
                                    quantity.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text('Price: '),
                                  Text(
                                    price.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text('Created At: '),
                                  Text(
                                    dateCreated.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
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
                }),
              ],
            );
          }
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _productCollection
          .orderBy('dateUpdated', descending: true)
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
            return ListView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              children: [
                ...snapshot.data!.docs
                    .where((QueryDocumentSnapshot<Object?> element) =>
                        element['barcode']
                            .toString()
                            .toLowerCase()
                            .contains(query.toLowerCase()))
                    .map((QueryDocumentSnapshot<Object?> data) {
                  final String name = data.get('name');
                  final double price = data.get('price');
                  final int quantity = data.get('quantity');
                  final String photoURL = data.get('photoURL');

                  //*GET TIMESTAMP DATE ADDED
                  final Timestamp date = data.get('dateAdded');
                  final DateTime dateAdded = date.toDate();
                  final String dateCreated =
                      DateFormat('MM-dd-yyyy').format(dateAdded);

                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Card(
                      margin: EdgeInsets.fromLTRB(4, 2, 4, 2),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductEdit(
                                  data: data,
                                ),
                              ),
                            );
                          },
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  'Delete Product',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                content: Text(
                                    'Are you sure you want to delete this item?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      db.deleteProduct(id: data.id);
                                      Navigator.pop(context, true);
                                      Navigator.pop(context, true);
                                      showToast(msg: 'Product Deleted');
                                    },
                                    child: Text('Yes'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                    child: Text('No'),
                                  ),
                                ],
                              ),
                            );
                          },
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
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
                          title: Text(
                            name,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            children: [
                              Row(
                                children: [
                                  Text('Available Stock(s): ',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                      )),
                                  Text(
                                    quantity.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text('Price: '),
                                  Text(
                                    price.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text('Created At: '),
                                  Text(
                                    dateCreated.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
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
                }),
              ],
            );
          }
          //*FETCH DATA HERE

        }
      },
    );
  }
}
