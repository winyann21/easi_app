import 'package:fluttertoast/fluttertoast.dart';

void showToast({required String msg}) {
  Fluttertoast.showToast(
    msg: msg,
    fontSize: 18,
  );
}
