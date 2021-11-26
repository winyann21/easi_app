// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sized_box_for_whitespace

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/controllers/auth_controller.dart';
import 'package:easi/screens/purchase/purchase_search.dart';
import 'package:easi/services/purchased_items.dart';
import 'package:easi/widgets/app_loading.dart';
import 'package:easi/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PurchasedItems extends StatefulWidget {
  const PurchasedItems({Key? key}) : super(key: key);

  @override
  _PurchasedItemsState createState() => _PurchasedItemsState();
}

class _PurchasedItemsState extends State<PurchasedItems> {
  static final _authController = Get.find<AuthController>(); //user data
  final PurchasedItemsDB pidb = PurchasedItemsDB();
  final CollectionReference _purchasedItemsCollection = FirebaseFirestore
      .instance
      .collection('users')
      .doc(_authController.user!.uid)
      .collection('purchasedItems');
  final TextEditingController _enterCash = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Purchased Items'),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(context: context, delegate: PurchaseSearch());
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: getBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //TODO:: EXECUTE PURCHASE
          //showDialog with Enter cash amount.
          //confirm purchase
          //show change
        },
        child: Icon(
          Icons.check,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget getBody() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _purchasedItemsCollection
                  .orderBy('name', descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Loading(),
                  );
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child:
                        Text('No purchased items yet, try making a purchase'),
                  );
                } else {
                  return ListView(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    children: [
                      ...snapshot.data!.docs
                          .map((QueryDocumentSnapshot<Object?> data) {
                        final String id = data.get('id');
                        final String name = data.get('name');
                        final int quantity = data.get('quantity');
                        final double totalPrice =
                            data.get('totalPrice').toDouble();

                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Card(
                            margin: EdgeInsets.fromLTRB(4, 2, 4, 2),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                onLongPress: () async {
                                  //TODO::delete item from the list
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(
                                        'Remove Item',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey[800],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: Text(
                                          'Are you sure you want to remove item?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () async {
                                            pidb.deletePurchasedItems(
                                                id: data.id);
                                            Navigator.pop(context, true);
                                            showToast(msg: 'Item Removed');
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
                                title: Text(name),
                                subtitle: Text('Total: $totalPrice'),
                                trailing: Text(
                                  'x $quantity',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
