// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sized_box_for_whitespace, avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/controllers/auth_controller.dart';
import 'package:easi/screens/purchase/purchase_search.dart';
import 'package:easi/services/product_database.dart';
import 'package:easi/services/purchased_items_database.dart';
import 'package:easi/services/sales_database.dart';
import 'package:easi/widgets/app_loading.dart';
import 'package:easi/widgets/app_textformfield.dart';
import 'package:easi/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PurchasedItems extends StatefulWidget {
  const PurchasedItems({Key? key}) : super(key: key);

  @override
  _PurchasedItemsState createState() => _PurchasedItemsState();
}

class _PurchasedItemsState extends State<PurchasedItems> {
  static final _authController = Get.find<AuthController>(); //user data
  final PurchasedItemsDB pidb = PurchasedItemsDB();
  final ProductDB db = ProductDB();
  final SalesDB sdb = SalesDB();
  final _purchaseItemFormKey = GlobalKey<FormState>();
  final CollectionReference _purchasedItemsCollection = FirebaseFirestore
      .instance
      .collection('users')
      .doc(_authController.user!.uid)
      .collection('purchasedItems');
  final CollectionReference _productCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(_authController.user!.uid)
      .collection('products');
  final TextEditingController _enterCash = TextEditingController();

  double? totalSales;
  var date = DateTime.now().add(Duration(hours: 8));
  late String dateMonth = DateFormat('MMMM').format(date);

  @override
  void dispose() {
    super.dispose();
    _enterCash.dispose();
  }

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
        onPressed: () async {
          String id;
          double sum = 0;
          double totalPrice;

          //TODO:: EXECUTE PURCHASE
          //check if has data
          await _purchasedItemsCollection.get().then((querySnapshot) async {
            if (querySnapshot.docs.isEmpty) {
              showToast(msg: 'No items to confirm purchase');
            } else {
              //*SHOW TOTAL PRICE OF ITEMS
              await _purchasedItemsCollection.get().then((snapshot) {
                snapshot.docs.forEach((item) {
                  //get total sum of items
                  totalPrice = item.get('totalPrice');
                  sum += totalPrice;
                });
              });
              //showDialog with Enter cash amount.
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    'Total Price: $sum',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ), //show total price
                  content: Form(
                    key: _purchaseItemFormKey,
                    child: RoundRectTextFormField(
                        prefixIcon: Icons.attach_money_sharp,
                        controller: _enterCash,
                        hintText: 'Enter Cash',
                        labelText: 'Cash',
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Field is required";
                          } else if (double.parse(value) <
                              double.parse(sum.toString())) {
                            return "Not enough cash";
                          } else {
                            return null;
                          }
                        }),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                        _enterCash.clear();
                      },
                      child: Text(
                        'No',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        //*SHOW TOTAL CHANGE OF ITEMS
                        if (_purchaseItemFormKey.currentState!.validate()) {
                          double pTotalPrice;
                          double pSum = 0;
                          double? change, formattedChange;
                          await _purchasedItemsCollection
                              .get()
                              .then((snapshot) {
                            snapshot.docs.forEach((item) {
                              //get total sum of items
                              pTotalPrice = item.get('totalPrice');
                              pSum += pTotalPrice;
                              change = (double.parse(_enterCash.text) -
                                  double.parse(pSum.toString()));
                              formattedChange =
                                  double.parse(change!.toStringAsFixed(2));
                            });
                          });
                          //show change
                          Navigator.pop(context, true);
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                'Confirm Purchase',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: change! <= 0
                                  ? Text('No Change')
                                  : Text('Change: $formattedChange'),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context, true);
                                  },
                                  child: Text(
                                    'No',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    //*UPDATE DATABASES
                                    String? pId;
                                    int? pQuantitySold;
                                    int? quantity;
                                    int? currentItemSold;

                                    await _purchasedItemsCollection
                                        .get()
                                        .then((snapshot) {
                                      snapshot.docs.forEach((item) async {
                                        pId = item.get('id');
                                        quantity = item.get('quantity');
                                        pQuantitySold =
                                            item.get('quantitySold');
                                        currentItemSold =
                                            item.get('currentItemSold');

                                        currentItemSold =
                                            currentItemSold! + pQuantitySold!;
                                        quantity = quantity! - pQuantitySold!;

                                        await db.purchaseProduct(
                                          id: pId!,
                                          quantity: quantity!,
                                          numOfItemSold: currentItemSold!,
                                        );
                                        //AFTER CLEAR ALL DB

                                        item.reference.delete();
                                      });
                                    });

                                    //TODO:: SALES COLLECTION UPDATE

                                    var sales = await sdb.salesCollection
                                        .doc(dateMonth)
                                        .get();
                                    if (!sales.exists) {
                                      sdb.addSales(
                                        totalSales: pSum,
                                        month: dateMonth,
                                      );
                                    }

                                    //*ELSE(UPDATE DOC)
                                    // ignore: await_only_futures
                                    var salesDS = await sdb.salesCollection
                                        .doc(dateMonth);
                                    if (sales.exists) {
                                      salesDS.get().then((doc) async {
                                        totalSales = doc.get('totalSales');
                                        await sdb.updateSales(
                                          month: dateMonth,
                                          totalSales: totalSales! + pSum,
                                        );
                                      });
                                    }

                                    Navigator.pop(context, true);
                                    _enterCash.clear();
                                  },
                                  child: Text(
                                    'Yes',
                                    style: TextStyle(
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Yes',
                        style: TextStyle(
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          });
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
                    child: Text('List empty, click add icon to purchase items'),
                  );
                } else {
                  return ListView(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    children: [
                      ...snapshot.data!.docs
                          .map((QueryDocumentSnapshot<Object?> data) {
                        final String name = data.get('name');
                        final int quantitySold = data.get('quantitySold');
                        final double totalPrice =
                            data.get('totalPrice').toDouble();
                        final double price = data.get('price').toDouble();

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
                                title: Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 20.0,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Item Price: $price'),
                                    Text('Total Purchased: $totalPrice'),
                                  ],
                                ),
                                trailing: Text(
                                  'x $quantitySold',
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
