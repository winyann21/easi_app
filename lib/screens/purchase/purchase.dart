// ignore_for_file: unnecessary_new, prefer_const_constructors, avoid_unnecessary_containers

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/services/local_notification.dart';
//import 'package:easi/services/database/sales_database.dart';
import 'package:easi/services/product_database.dart';
import 'package:easi/services/sales_database.dart';
import 'package:easi/widgets/app_textformfield.dart';
import 'package:easi/widgets/app_toast.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  final _purchaseFormKey = GlobalKey<FormState>();
  final TextEditingController _newQuantity = new TextEditingController();
  final TextEditingController _enterCash = new TextEditingController();
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
  String dateMonth = DateFormat('MMMM').format(DateTime.now());

  @override
  void initState() {
    total ??= 0;

    name = widget.data!.get('name');
    barcode = widget.data!.get('barcode');
    photoUrl = widget.data!.get('photoURL');
    quantity = widget.data!.get('quantity');
    price = widget.data!.get('price');
    itemSold = widget.data!.get('numOfItemSold');

    _newQuantity.addListener(totalPriceListener);
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
                        productQuantity(),
                        SizedBox(height: 10.0),
                        enterCash(),
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

  Widget enterCash() {
    return RoundRectTextFormField(
      controller: _enterCash,
      prefixIcon: Icons.attach_money_sharp,
      hintText: 'Enter Cash',
      labelText: 'Cash',
      suffixIcon: null,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value!.isEmpty) {
          return "Field is required";
        } else if (double.parse(value) < double.parse(total.toString())) {
          return "Not enough cash";
        } else {
          return null;
        }
      },
    );
  }

  Widget purchaseBtn() {
    return FloatingActionButton(
      onPressed: () async {
        if (_purchaseFormKey.currentState!.validate()) {
          String id = widget.data!.id; //*DOCUMENT ID
          int amount =
              int.parse(_newQuantity.text); //*SUBTRACT TO PRODUCT'S QUANTITY
          double change =
              (double.parse(_enterCash.text) - double.parse(total.toString()));

          double newChange = double.parse(
              change.toStringAsFixed(2)); //*formatted to 2 decimal places
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                'Confirm Purchase',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[800],
                ),
              ),
              content: change <= 0
                  ? Text('No Change')
                  : Text('Change: $newChange'), //*CHANGE
              actions: [
                TextButton(
                  onPressed: () async {
                    //*GENERATE RANDOM ID FOR NOTIFICATIONS

                    //*COMPUTATION FOR QUANTITY, TOTAL PRICE AND NUMBER OF ITEM SOLD
                    itemSold = (itemSold! + amount);
                    quantity = (quantity! - amount);
                    totalPriceItemSold = (price! * amount);

                    //*UPDATE PRODUCT PURCHASE
                    await db.purchaseProduct(
                      id: id,
                      quantity: quantity!,
                      numOfItemSold: itemSold!,
                    );

                    //*ADD TO TOTAL SALES THIS MONTH
                    //*CHECK IF MONTH EXISTS(IF NOT CREATE DOC)
                    var sales = await sdb.salesCollection.doc(dateMonth).get();
                    if (!sales.exists) {
                      sdb.addSales(
                        totalSales: totalPriceItemSold!,
                        month: dateMonth,
                      );
                    }
                    
                    //*ELSE(UPDATE DOC)
                    // ignore: await_only_futures
                    var salesDS = await sdb.salesCollection.doc(dateMonth);
                    if (sales.exists) {
                      salesDS.get().then((doc) async {
                        totalSales = doc.get('totalSales');
                        await sdb.updateSales(
                          month: dateMonth,
                          totalSales: totalSales! + totalPriceItemSold!,
                        );
                      });
                    }

                    showToast(msg: "Item Purchased");
                    Navigator.pop(context);
                    Navigator.pop(context);
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
        }
      },
      child: Icon(
        Icons.check_sharp,
        color: Colors.white,
      ),
    );
  }
}
