// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:easi/controllers/auth_controller.dart';
import 'package:easi/screens/authentication/reset_password/reset_password.dart';
import 'package:easi/screens/authentication/sign_up/sign_up.dart';
import 'package:easi/widgets/app_elevatedbutton.dart';
import 'package:easi/widgets/app_outlinedbutton.dart';
import 'package:easi/widgets/app_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({Key? key}) : super(key: key);

  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _authController = Get.find<AuthController>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;

  @override
  void initState() {
    isPasswordVisible = false;
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          RoundRectTextFormField(
            labelText: 'E-mail Address',
            hintText: 'Enter your e-mail address',
            controller: _emailController,
            prefixIcon: Icons.email_sharp,
            validator: (value) {
              bool _isEmailValid = RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                  .hasMatch(value!);

              if (value.isEmpty || value.trim().isEmpty) {
                return 'E-mail address is required!';
              }

              if (!_isEmailValid) {
                return 'Invalid email address format.';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: size.height * 0.01),
          RoundRectTextFormField(
            labelText: 'Password',
            hintText: 'Enter your password',
            controller: _passwordController,
            prefixIcon: Icons.password_sharp,
            obscureText: !isPasswordVisible,
            suffixIcon:
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            suffixIconOnPressed: () {
              setState(() {
                isPasswordVisible = !isPasswordVisible;
              });
            },
            validator: (value) {
              if (value.isEmpty || value.trim().isEmpty) {
                return 'Password is required!';
              }
              if (value.toString().length < 6) {
                return 'Password should be longer or equal to 6 characters.';
              }
              return null;
            },
            textInputAction: TextInputAction.done,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              child: Text('Forgot Password'),
              onPressed: () {
                Get.to(() => ResetPassword());
              },
            ),
          ),
          RoundRectElevatedButton(
            width: double.infinity,
            height: 40.0,
            title: 'Login',
            onPressed: () {
              String email = _emailController.text;
              String password = _passwordController.text;

              if (_loginFormKey.currentState!.validate()) {
                _authController.signIn(
                  email: email,
                  password: password,
                );
              }
            },
          ),
          TextButton(
            child: Text('Create an account'),
            onPressed: () {
              Get.to(() => SignUp());
            },
          ),
          Text('- OR -'),
          SizedBox(height: size.height * 0.01),
          RoundRectOutlinedButton(
            width: double.infinity,
            height: 40.0,
            title: 'Sign in with Google',
            onPressed: () {
              _authController.signInWithGoogle();
            },
            icon: FontAwesomeIcons.google,
          ),
        ],
      ),
    );
  }
}
