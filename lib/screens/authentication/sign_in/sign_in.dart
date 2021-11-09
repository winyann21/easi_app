// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:easi/screens/authentication/sign_in/local_widgets/sign_in_form.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
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
                    'Hello There!',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 42.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Image.asset(
                      'assets/icons/EASI_loginIcon.png',
                      height: size.height * 0.1,
                    ),
                  ),
                  Text(
                    'Welcome to EASI - Easy Access Smart Inventory',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                      fontSize: 14.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: size.height * 0.02),
                  SignInForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
