// ignore_for_file: prefer_const_constructors, unnecessary_null_comparison, sized_box_for_whitespace, prefer_typing_uninitialized_variables, avoid_function_literals_in_foreach_calls, avoid_print, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/api/pdf_api.dart';
import 'package:easi/api/pdf_invoice_api.dart';
import 'package:easi/controllers/auth_controller.dart';
import 'package:easi/models/invoice.dart';
import 'package:easi/screens/products/functions/product_add.dart';
import 'package:easi/screens/products/functions/product_edit.dart';
import 'package:easi/services/local_notification.dart';
import 'package:easi/services/notification_database.dart';
import 'package:easi/services/product_database.dart';
import 'package:easi/services/sales_database.dart';
import 'package:easi/widgets/app_loading.dart';
import 'package:easi/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Products extends StatefulWidget {
  const Products({Key? key}) : super(key: key);

  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  static final _authController = Get.find<AuthController>(); //user data
  final LocalNotificationService _notificationService =
      LocalNotificationService();
  final ProductDB db = ProductDB();
  final SalesDB sdb = SalesDB();
  final NotificationDB ndb = NotificationDB();

  final CollectionReference _productCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(_authController.user!.uid)
      .collection('products');

  final isDialOpen = ValueNotifier(false);

  String? scanResult;
  String barcode = '';
  String getBarcode = '';
  String dateMonth = DateFormat('MMMM').format(DateTime.now());
  String dateNow = DateFormat('MM-dd-yyyy').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isDialOpen.value) {
          isDialOpen.value = false;
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: getBody(),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          foregroundColor: Colors.white,
          backgroundColor: Colors.orange,
          overlayColor: Colors.black,
          overlayOpacity: 0.4,
          spacing: 12,
          spaceBetweenChildren: 12,
          openCloseDial: isDialOpen,
          children: [
            SpeedDialChild(
              child: Icon(Icons.add, color: Colors.orange[700]),
              label: 'Add Product',
              onTap: () {
                Get.to(() => ProductAdd(
                      getBarcode: '',
                    ));
              },
            ),
            SpeedDialChild(
              child: Icon(Icons.camera_alt_sharp, color: Colors.orange[700]),
              label: 'Scan Barcode to Add Product',
              onTap: scanBarcode,
            ),
            SpeedDialChild(
              child:
                  Icon(Icons.picture_as_pdf_sharp, color: Colors.orange[700]),
              label: 'Generate Monthly Reports',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      'Generate $dateMonth reports',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[800],
                      ),
                    ),
                    content: Text('Continue?'),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          //*PDF GENERATE
                          //*INITIALIZE VARIABLES
                          var invoice;
                          var pdfFile;
                          // ignore: await_only_futures
                          await _productCollection
                              .orderBy('numOfItemSold', descending: true)
                              .get()
                              .then((querySnapshot) {
                            querySnapshot.docs.forEach((doc) async {
                              invoice = Invoice(
                                items: querySnapshot.docs,
                              );

                              pdfFile = await PdfInvoiceApi.generate(invoice);
                              PdfApi.openFile(pdfFile);

                              //!CAN BE CHANGED
                              // //*RESET ITEMSOLD
                              // await db.resetItemSold(
                              //   id: doc.id,
                              //   numOfItemSold: 0,
                              // );

                              // //*RESET TOTAL SALES THIS MONTH
                              // await sdb.updateSales(
                              //   totalSales: 0.00,
                              //   month: dateMonth,
                              // );
                              //*********************!
                            });
                          });

                          Navigator.pop(context, true);
                        },
                        child: Text('Generate'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: Text('Cancel'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget getBody() {
    // final CollectionReference _productCollection = FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(_authController.user!.uid)
    //     .collection('products');

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: StreamBuilder(
        stream: _productCollection
            .orderBy('dateUpdated', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Loading(),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('List is currently empty, try adding items'),
            );
          } else {
            return ListView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              children: [
                ...snapshot.data!.docs.map(
                  ((QueryDocumentSnapshot<Object?> data) {
                    //*GET DATE NOW
                    var getDateNow = DateTime.now();
                    final formatDateNow =
                        DateFormat('MM-dd-yyyy').format(getDateNow);

                    //*GET EXPIRYDATE
                    String getExpiryDate = data.get('expiryDate');

                    //*GET DATAS
                    final String name = data.get('name');
                    final int uniqueID = data.get('uniqueID');
                    final double price = data.get('price').toDouble();
                    final int quantity = data.get('quantity');
                    final String photoURL = data.get('photoURL');
                    final String productId = data.id;

                    //*GET TIMESTAMP DATEADDED FIELD
                    Timestamp time = data.get('dateAdded') ?? Timestamp.now();
                    DateTime date = DateTime.fromMicrosecondsSinceEpoch(
                        time.microsecondsSinceEpoch);
                    final String dateCreated =
                        DateFormat('MM-dd-yyyy').format(date);

                    //*****NOTIFICATIONS****/

                    int daysBetween(DateTime from, DateTime to) {
                      from = DateTime(from.year, from.month, from.day);
                      to = DateTime(to.year, to.month, to.day);
                      return (to.difference(from).inDays).round();
                    }

                    final expDate = DateTime.parse(getExpiryDate);
                    final dateNow = DateTime.now();
                    final dayDifference = daysBetween(dateNow, expDate);

                    var duration = expDate.subtract(Duration(days: 30));

                    //*EXPIRY DATE
                    var expiryMessage = dayDifference <= 0
                        ? '$name has expired'
                        : '$name will be expiring at $getExpiryDate';

                    var expiryDateStatus = dayDifference <= 0
                        ? 'Expiry Date: $getExpiryDate'
                        : '$dayDifference day/s left.';

                    //*QUANTITY
                    var quantityMessage =
                        quantity > 10 ? '' : '$name needs to be restocked.';
                    var quantityStatus =
                        quantity > 10 ? '' : 'Item/s left: $quantity';

                    //TODO::CHECK IF NOTIFICATION DOCUMENT ALREADY EXISTS, TO REDUCE DUPLICATE CALLS

                    Future.delayed(Duration(minutes: 5), () async {
                      _notificationService.notificationsPlugin
                          .schedule(
                        uniqueID,
                        expiryMessage,
                        expiryDateStatus,
                        duration,
                        _notificationService.notificationDetails,
                      )
                          .whenComplete(() async {
                        if (dayDifference < 30) {
                          await ndb.addNotif(
                            productId: productId,
                            expiryMessage: expiryMessage,
                            expiryDateStatus: expiryDateStatus,
                            quantityMessage: quantityMessage,
                            quantityStatus: quantityStatus,
                            id: data.id,
                          );
                        } else {
                          await ndb.deleteNotif(id: data.id);
                        }
                      });
                    });

                    if (quantity <= 10) {
                      _notificationService.notificationsPlugin
                          .show(
                        uniqueID,
                        quantityMessage,
                        quantityStatus,
                        _notificationService.notificationDetails,
                      )
                          .whenComplete(() async {
                        if (quantity <= 10) {
                          await ndb.addNotif(
                            productId: productId,
                            expiryMessage: expiryMessage,
                            expiryDateStatus: expiryDateStatus,
                            quantityMessage: quantityMessage,
                            quantityStatus: quantityStatus,
                            id: data.id,
                          );
                        } else {
                          await ndb.deleteNotif(id: data.id);
                        }
                      });
                    }

                    //*DISPLAY DATA
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Card(
                        margin: EdgeInsets.fromLTRB(4, 2, 4, 2),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductEdit(
                                    data: data,
                                  ),
                                ),
                              );
                            },
                            onLongPress: () async {
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
                                      dateCreated,
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
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Future scanBarcode() async {
    String scanResult;

    try {
      scanResult = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666",
        "Cancel",
        true,
        ScanMode.BARCODE,
      );
    } on PlatformException {
      scanResult = 'Failed to get platform version';
    }

    if (!mounted) return;

    if (scanResult != '-1') {
      setState(() {
        this.scanResult = scanResult;
        getBarcode = scanResult;

        Get.to(() => ProductAdd(getBarcode: getBarcode));
      });
    } else {
      setState(() {
        scanResult = '';
        showToast(msg: 'Scan Cancelled');
      });
    }
  }
}
