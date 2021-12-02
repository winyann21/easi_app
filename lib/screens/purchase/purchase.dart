// ignore_for_file: unnecessary_new, prefer_const_constructors, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, unused_local_variable, await_only_futures, duplicate_ignore

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/screens/purchase/purchased_items.dart';
import 'package:easi/services/local_notification.dart';
//import 'package:easi/services/database/sales_database.dart';
import 'package:easi/services/product_database.dart';
import 'package:easi/services/purchased_items_database.dart';
import 'package:easi/services/sales_database.dart';
import 'package:easi/widgets/app_textformfield.dart';
import 'package:easi/widgets/app_toast.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Purchase extends StatefulWidget {
  final QueryDocumentSnapshot<Object?>? data;
  const Purchase({Key? key, required this.data}) : super(key: key);

  @override
  _PurchaseState createState() => _PurchaseState();
}

class _PurchaseState extends State<Purchase> {
  final ProductDB db = ProductDB();
  final SalesDB sdb = SalesDB();
  final PurchasedItemsDB pidb = PurchasedItemsDB();

  final _purchaseFormKey = GlobalKey<FormState>();
  final TextEditingController _newQuantity = new TextEditingController();
  // final TextEditingController _enterCash = new TextEditingController();
  double? total;
  double totalPrice = 1.0;
  double? totalPriceItemSold;
  String productMonth = '';
  String photoUrl = '';
  String name = '';
  String barcode = '';
  int? quantity;
  double? price;
  int? itemSold;
  double? totalPriceOfItemSold;
  double? totalSales;
  String expiryDate = '';
  Timestamp? dateCreated;
  String category = '';
  String dateMonth = DateFormat('MMMM').format(DateTime.now());

  int? newQS;
  double? totPrice;

  @override
  void initState() {
    total ??= 0;

    name = widget.data!.get('name');
    barcode = widget.data!.get('barcode');
    photoUrl = widget.data!.get('photoURL');
    quantity = widget.data!.get('quantity');
    price = widget.data!.get('price');
    itemSold = widget.data!.get('numOfItemSold');
    expiryDate = widget.data!.get('expiryDate');
    dateCreated = widget.data!.get('dateAdded') ?? Timestamp.now();
    category = widget.data!.get('category');

    //for string conversion
    // DateTime date =
    //     DateTime.fromMicrosecondsSinceEpoch(time!.microsecondsSinceEpoch);
    // dateCreated = DateFormat('MM-dd-yyyy').format(date);

    _newQuantity.addListener(totalPriceListener);
    _newQuantity.text = "1";
    super.initState();
  }

  @override
  void dispose() {
    _newQuantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Purchase Item'),
          // actions: [
          //   IconButton(
          //     onPressed: () {
          //       Get.back();
          //       Get.to(() => PurchasedItems());
          //     },
          //     icon: Icon(
          //       Icons.receipt_sharp,
          //     ),
          //   ),
          // ],
        ),
        floatingActionButton: purchaseBtn(),
        body: Center(
          child: Scrollbar(
            showTrackOnHover: true,
            child: SingleChildScrollView(
              child: Form(
                key: _purchaseFormKey,
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 80.0),
                    child: Column(
                      children: [
                        SizedBox(height: 10.0),
                        Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 32.0,
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Item Price:'),
                            SizedBox(width: 10.0),
                            Text(
                              price.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 32.0,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        productImage(),
                        SizedBox(height: 10.0),
                        Text('Available Stock(s):'),
                        Text(
                          quantity.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 32.0,
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                onPressed: () {
                                  int currentValue =
                                      int.parse(_newQuantity.text);
                                  setState(() {
                                    // ignore: avoid_print
                                    print("Setting state");
                                    currentValue--;
                                    _newQuantity.text =
                                        (currentValue > 0 ? currentValue : 0)
                                            .toString(); // decrementing value
                                  });
                                },
                                child: Icon(Icons.horizontal_rule_sharp,
                                    color: Colors.white),
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(15),
                                  primary: Colors.red, // <-- Button color
                                  onPrimary: Colors.white, // <-- Splash color
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: productQuantity(),
                            ),
                            Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                onPressed: () {
                                  int currentValue =
                                      int.parse(_newQuantity.text);
                                  setState(() {
                                    currentValue++;
                                    _newQuantity.text = (currentValue)
                                        .toString(); // incrementing value
                                  });
                                },
                                child: Icon(Icons.add, color: Colors.white),
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(15),
                                  primary: Colors.green, // <-- Button color
                                  onPrimary: Colors.white, // <-- Splash color
                                ),
                              ),
                            ),
                          ],
                        ),
                        // enterCash(),
                        SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Total Price:'),
                            SizedBox(width: 10.0),
                            Text(
                              total.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 32.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  totalPriceListener() {
    int qty = int.tryParse(_newQuantity.text) ?? 0;
    totalPrice = (price! * qty.toDouble());

    setState(() {
      total = totalPrice;
    });
  }

  Widget productImage() {
    return Center(
      child: Container(
        child: CircleAvatar(
          backgroundImage: photoUrl == ""
              ? AssetImage('assets/images/default_thumbnail_icon.png')
              : NetworkImage(photoUrl) as ImageProvider,
          radius: 70,
          foregroundColor: Colors.white,
          backgroundColor: Colors.white,
        ),
        padding: const EdgeInsets.all(1.5), // borde width
        decoration: new BoxDecoration(
          color: Colors.orange, // border color
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget productQuantity() {
    return RoundRectTextFormField(
      controller: _newQuantity,
      prefixIcon: Icons.workspaces,
      hintText: 'Quantity',
      labelText: 'Quantity',
      suffixIcon: null,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value!.isEmpty) {
          return "Field is required";
        } else if (quantity! == 0 && int.parse(_newQuantity.text) > quantity!) {
          return "No available stocks";
        } else if (int.parse(_newQuantity.text) > quantity!) {
          return "Must be less than item's quantity";
        } else {
          return null;
        }
      },
    );
  }

  // Widget enterCash() {
  //   return RoundRectTextFormField(
  //     controller: _enterCash,
  //     prefixIcon: Icons.attach_money_sharp,
  //     hintText: 'Enter Cash',
  //     labelText: 'Cash',
  //     suffixIcon: null,
  //     keyboardType: TextInputType.number,
  //     textInputAction: TextInputAction.next,
  //     validator: (value) {
  //       if (value!.isEmpty) {
  //         return "Field is required";
  //       } else if (double.parse(value) < double.parse(total.toString())) {
  //         return "Not enough cash";
  //       } else {
  //         return null;
  //       }
  //     },
  //   );
  // }

  Widget purchaseBtn() {
    return FloatingActionButton(
      onPressed: () async {
        if (_purchaseFormKey.currentState!.validate()) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                'Purchase item?',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    //TODO:: DO ADD TO PURCHASED ITEMS SECTION
                    String id = widget.data!.id; //*DOCUMENT ID
                    int amount = int.parse(_newQuantity.text);
                    // itemSold = (itemSold! + amount);
                    // quantity = (quantity! - amount);
                    totalPriceItemSold = (price! * amount);

                    var pItems =
                        await pidb.purchasedItemsCollection.doc(id).get();
                    if (!pItems.exists) {
                      await pidb.addPurchasedItems(
                        dateCreated: dateCreated!,
                        barcode: barcode,
                        id: id,
                        name: name,
                        category: category,
                        currentItemSold: itemSold!,
                        quantitySold: amount,
                        quantity: quantity!,
                        price: price!,
                        totalPrice: totalPriceItemSold!,
                        expiryDate: expiryDate,
                      );
                    }
                    var pItemsDS = await pidb.purchasedItemsCollection.doc(id);
                    if (pItems.exists) {
                      pItemsDS.get().then((doc) async {
                        newQS = doc.get('quantitySold');
                        totPrice = doc.get('totalPrice');

                        await pidb.updatePurchasedItems(
                          id: id,
                          name: name,
                          barcode: barcode,
                          category: category,
                          dateCreated: dateCreated!,
                          currentItemSold: itemSold!,
                          expiryDate: expiryDate,
                          quantitySold: newQS! + amount,
                          quantity: quantity!,
                          price: price!,
                          totalPrice: totPrice! + totalPriceItemSold!,
                        );
                      });
                    }

                    showToast(msg: "Item Added");
                    Navigator.pop(context);

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          'Add more items?',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                              Navigator.pop(context, true);
                            },
                            child: Text(
                              'Yes',
                              style: TextStyle(
                                color: Colors.green,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                              Navigator.pop(context, true);
                              Navigator.pop(context, true);
                            },
                            child: Text(
                              'No',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    'Yes',
                    style: TextStyle(
                      color: Colors.green,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                    Navigator.pop(context, true);
                    Navigator.pop(context, true);
                  },
                  child: Text(
                    'No',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
      child: Icon(
        Icons.check_sharp,
        color: Colors.white,
      ),
    );
  }
}
