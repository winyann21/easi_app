// ignore_for_file: prefer_const_constructors, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RoundRectOutlinedButton extends StatelessWidget {
  const RoundRectOutlinedButton({
    Key? key,
    required this.title,
    required this.onPressed,
    this.width,
    this.height,
    required this.icon,
  }) : super(key: key);

  final String? title;
  final IconData icon;
  final onPressed, width, height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Colors.orange,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          primary: Colors.black,
        ),
        onPressed: onPressed,
        icon: FaIcon(
          icon,
          color: Colors.orange,
          size: 16.0,
        ),
        label: Text(title!),
      ),
    );
  }
}
