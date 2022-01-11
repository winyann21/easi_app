// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:easi/controllers/auth_controller.dart';
import 'package:easi/controllers/user_controller.dart';
import 'package:easi/screens/forecast/forecast.dart';
import 'package:easi/screens/notifications/notifications.dart';
import 'package:easi/screens/products/functions/product_search.dart';
import 'package:easi/screens/products/product_status.dart';
import 'package:easi/screens/purchase/purchased_items.dart';
import 'package:easi/screens/purchase_logs/purchase_logs.dart';
import 'package:easi/services/user_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({Key? key}) : super(key: key);

  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final _authController = Get.find<AuthController>();
    final _userController = Get.find<UserController>();

    return SafeArea(
      child: Drawer(
        child: Material(
          color: Colors.white,
          child: GetX<UserController>(
            initState: (_) async {
              _userController.user =
                  await UserDatabase().getUser(_authController.user!.uid);
            },
            builder: (_) {
              if (_.user.name != null && _.user.email != null) {
                return ListView(
                  children: [
                    Center(
                      child: buildHeader(
                        userImage: currentUser.photoURL,
                        userName: _.user.name,
                        userEmail: _.user.email,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          Divider(color: Colors.grey[850]),
                          buildMenuItem(
                            menuName: 'Forecast',
                            menuIcon: Icons.cloud,
                            onClicked: () {
                              Get.to(() => Forecast());
                            },
                          ),
                          const SizedBox(height: 16),
                          buildMenuItem(
                            menuName: 'Product Details',
                            menuIcon: Icons.details,
                            onClicked: () {
                              Get.to(() => ProductStatus());
                            },
                          ),
                          const SizedBox(height: 16),
                          buildMenuItem(
                            menuName: 'Search Product',
                            menuIcon: Icons.search,
                            onClicked: () {
                              showSearch(
                                  context: context, delegate: ProductSearch());
                            },
                          ),
                          const SizedBox(height: 16),
                          buildMenuItem(
                            menuName: 'Purchase Product',
                            menuIcon: Icons.shopping_basket_sharp,
                            onClicked: () {
                              Get.to(() => PurchasedItems());
                            },
                          ),
                          const SizedBox(height: 16),
                          buildMenuItem(
                            menuName: 'Purchase History',
                            menuIcon: Icons.history,
                            onClicked: () {
                              Get.to(() => PurchaseLogs());
                            },
                          ),
                          const SizedBox(height: 16),
                          buildMenuItem(
                            menuName: 'Notifications',
                            menuIcon: Icons.notifications,
                            onClicked: () {
                              Get.to(() => Notifications());
                            },
                          ),
                          const SizedBox(height: 24),
                          Divider(color: Colors.grey[850]),
                          buildMenuItem(
                            menuName: 'Logout',
                            menuIcon: Icons.logout,
                            onClicked: () async {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    'Logout Account',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Text('Continue?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        _authController.signOut();
                                        Get.back();
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
                                        Get.back();
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
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget buildMenuItem(
      {required String menuName,
      required IconData menuIcon,
      VoidCallback? onClicked}) {
    final color = Colors.black;
    final hoverColor = Colors.white38;

    return ListTile(
      leading: Icon(menuIcon, color: Colors.orange),
      title: Text(
        menuName,
        style: TextStyle(color: color),
      ),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
  }

  Widget buildHeader(
      {required String? userImage,
      required String? userName,
      required String? userEmail}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(userImage!),
          ),
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName!,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userEmail!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
