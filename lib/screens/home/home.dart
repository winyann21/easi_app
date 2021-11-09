// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:easi/controllers/auth_controller.dart';
import 'package:easi/controllers/user_controller.dart';
import 'package:easi/screens/products/functions/product_search.dart';
import 'package:easi/screens/products/products.dart';
import 'package:easi/screens/profile_drawer/drawer_screen.dart';
import 'package:easi/screens/purchase/purchase.dart';
import 'package:easi/screens/purchase/purchase_search.dart';
import 'package:easi/screens/stats/stats.dart';
import 'package:easi/services/user_database.dart';
import 'package:easi/widgets/app_elevatedbutton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //initialize controllers
  final _authController = Get.find<AuthController>();
  final _userController = Get.find<UserController>();
  int currentIndex = 0;
  final screens = [
    Products(),
    Stats(),
  ];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: currentIndex == 0
            ? Text(
                "Products",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black),
              )
            : Text(
                "Stats",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black),
              ),
        elevation: 1,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              showSearch(context: context, delegate: ProductSearch());
            },
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications),
          ),
        ],
      ),
      drawer: DrawerScreen(),
      body: screens[currentIndex],
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: Icon(
          Icons.shopping_basket,
          color: Colors.white,
        ),
        onPressed: () {
          showSearch(context: context, delegate: PurchaseSearch());
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavBar() {
    List<IconData> iconItems = [
      Icons.store_sharp,
      Icons.auto_graph_sharp,
    ];

    return AnimatedBottomNavigationBar(
      icons: iconItems,
      activeColor: Colors.orange,
      splashColor: Colors.orange,
      inactiveColor: Colors.grey[700],
      activeIndex: currentIndex,
      gapLocation: GapLocation.center,
      notchSmoothness: NotchSmoothness.softEdge,
      leftCornerRadius: 10,
      iconSize: 25,
      rightCornerRadius: 10,
      onTap: (index) => setState(() => currentIndex = index),
    );
  }
}
