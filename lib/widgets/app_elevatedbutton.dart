import 'package:flutter/material.dart';

class RoundRectElevatedButton extends StatelessWidget {
  const RoundRectElevatedButton({
    Key? key,
    required this.title,
    required this.onPressed,
    this.width,
    this.height,
  }) : super(key: key);

  final String? title;
  // ignore: prefer_typing_uninitialized_variables
  final onPressed, width, height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(title!),
        style: ElevatedButton.styleFrom(
          primary: Colors.orange,
          onPrimary: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }
}
