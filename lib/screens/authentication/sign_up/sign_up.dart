// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:easi/screens/authentication/sign_up/local_widgets/sign_up_form.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
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
                    'Sign up!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 42.0,
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    'Create an account',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                      fontSize: 14.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: size.height * 0.02),
                  SignUpForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
