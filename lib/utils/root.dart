// ignore_for_file: prefer_const_constructors

import 'package:easi/controllers/auth_controller.dart';
import 'package:easi/screens/authentication/sign_in/sign_in.dart';
import 'package:easi/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Root extends GetWidget<AuthController> {
  const Root({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _authController = Get.find<AuthController>();

    return Obx(() {
      return (_authController.user?.uid != null) ? Home() : SignIn();
    });
  }
}
