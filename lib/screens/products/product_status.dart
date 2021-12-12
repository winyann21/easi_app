// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/controllers/auth_controller.dart';
import 'package:easi/screens/products/product_status_search.dart';
import 'package:easi/services/product_database.dart';
import 'package:easi/services/sales_database.dart';
import 'package:easi/widgets/app_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:intl/intl.dart';

class ProductStatus extends StatefulWidget {
  const ProductStatus({Key? key}) : super(key: key);

  @override
  ProductStatusState createState() => ProductStatusState();
}

class ProductStatusState extends State<ProductStatus> {
  static final _authController = Get.find<AuthController>(); //user data
  final SalesDB sdb = SalesDB();
  final ProductDB db = ProductDB();

  final CollectionReference _productCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(_authController.user!.uid)
      .collection('products');

  var date = DateTime.now().add(Duration(hours: 8));
  late String dateMonth = DateFormat('MMMM').format(date);
  var dayDifference;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
      appBar: AppBar(
        centerTitle: true,
        title: Text('Products Status'),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(context: context, delegate: ProductStatusSearch());
            },
            icon: Icon(Icons.search),
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
        stream: _productCollection
            .orderBy('expiryDate', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Loading(),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No items to be expired yet.'),
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
