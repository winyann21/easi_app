import 'package:easi/controllers/auth_controller.dart';
import 'package:easi/controllers/user_controller.dart';
import 'package:get/get.dart';

class ControllerBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<UserController>(UserController(), permanent: true);
  }
}
