// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/controllers/auth_controller.dart';
import 'package:easi/services/forecasting_database.dart';
import 'package:easi/widgets/app_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Forecast extends StatefulWidget {
  const Forecast({Key? key}) : super(key: key);

  @override
  _ForecastState createState() => _ForecastState();
}

class _ForecastState extends State<Forecast> {
  static final _authController = Get.find<AuthController>();
  var dateN = DateTime.now();
  var date = DateTime.now().add(Duration(hours: 8));
  late String dateMonth = DateFormat('MMMM').format(date);

  final ForecastDB fdb = ForecastDB();
  final CollectionReference _forecastCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(_authController.user!.uid)
      .collection('forecastedItem');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Today's Forecast"),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.0,
      ),
      backgroundColor: Colors.white,
      body: getBody(),
    );
  }

  Widget getBody() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/morning.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: StreamBuilder(
        stream: _forecastCollection
            .where('dateForecasted',
                isGreaterThanOrEqualTo:
                    DateTime(dateN.year, dateN.month + 1, 0))
            .limit(1)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Loading(),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No item to forecast.'),
            );
          } else {
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 15),
                      ListView(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(
                          parent: NeverScrollableScrollPhysics(),
                        ),
                        children: [
                          ...snapshot.data!.docs
                              .map((QueryDocumentSnapshot<Object?> data) {
                            final String name = data.get('name');
                            final String photoUrl = data.get('photoUrl');
                            final int numOfItemSold = data.get('numOfItemSold');
                            final double price = data.get('price').toDouble();
                            final String month = data.get('month');

                            final double totRev = price * numOfItemSold;

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Column(
                                children: [
                                  Text(
                                    month,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 32,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Most in-demand product of $month:',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        Text(
                                          name,
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 15),
                                        Center(
                                          child: Container(
                                            child: CircleAvatar(
                                              backgroundImage: photoUrl == ""
                                                  ? AssetImage(
                                                      'assets/images/default_thumbnail_icon.png')
                                                  : NetworkImage(photoUrl)
                                                      as ImageProvider,
                                              radius: 70,
                                              foregroundColor: Colors.white,
                                              backgroundColor: Colors.white,
                                            ),
                                            padding: const EdgeInsets.all(
                                                1.5), // borde width
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.black, // border color
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 15),
                                        Text.rich(
                                          TextSpan(
                                            text: 'Sold ',
                                            style:
                                                TextStyle(color: Colors.black),
                                            children: <InlineSpan>[
                                              TextSpan(
                                                text: '$numOfItemSold ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                              TextSpan(
                                                text: 'items.',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Text.rich(
                                          TextSpan(
                                            text: 'With a total revenue of ',
                                            style:
                                                TextStyle(color: Colors.black),
                                            children: <InlineSpan>[
                                              TextSpan(
                                                text: '$totRev',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      children: [
                                        SizedBox(height: 15),
                                        Card(
                                          semanticContainer: true,
                                          clipBehavior:
                                              Clip.antiAliasWithSaveLayer,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          elevation: 4,
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Reminders:',
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                    '\u{1F4E6} Restock item to get ready for the upcoming month.'),
                                                Text(
                                                    '\u{1F516} Check expiration date of the item, for replacement or removal.'),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
