import 'package:flutter/material.dart';
import 'package:get/get.dart';

//*LOAD LOADING
showLoadingLogin() {
  Get.defaultDialog(
    title: "Signing in...",
    content: const CircularProgressIndicator(
      color: Colors.orange,
    ),
    barrierDismissible: false,
  );
}

showLoadingRegister() {
  Get.defaultDialog(
    title: "Creating account...",
    content: const CircularProgressIndicator(
      color: Colors.orange,
    ),
    barrierDismissible: false,
  );
}

showLoading() {
  Get.defaultDialog(
    title: "Loading...",
    content: const CircularProgressIndicator(
      color: Colors.orange,
    ),
    barrierDismissible: false,
  );
}

showLoadingProducts() {
  Get.defaultDialog(
    title: "Loading items...",
    content: const CircularProgressIndicator(
      color: Colors.orange,
    ),
    barrierDismissible: false,
  );
}

//*UNLOAD LOADING
dismissLoading() {
  Get.back();
}
