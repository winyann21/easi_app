// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:easi/screens/authentication/reset_password/local_widgets/reset_password_form.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 30.0,
              ),
              child: Column(
                children: [
                  Text(
                    'Reset Password',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 42.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset(
                      'assets/icons/EASI_resetpw.png',
                      height: size.height * 0.2,
                    ),
                  ),

                  Text(
                    'Enter e-mail address to reset password',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                      fontSize: 14.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: size.height * 0.03),
                  ResetPasswordForm(),
                  //reset password form by email
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
