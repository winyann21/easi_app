// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:easi/controllers/auth_controller.dart';
import 'package:easi/widgets/app_elevatedbutton.dart';
import 'package:easi/widgets/app_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _authController = Get.find<AuthController>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  String pw = '';

  @override
  void initState() {
    isPasswordVisible = false;
    isConfirmPasswordVisible = false;
    _emailController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Form(
      key: _registerFormKey,
      child: Column(
        children: [
          RoundRectTextFormField(
            labelText: 'Name',
            hintText: 'Enter your name',
            controller: _nameController,
            prefixIcon: Icons.account_circle_sharp,
            validator: (value) {
              if (value.isEmpty || value.trim().isEmpty) {
                return 'Name is required!';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: size.height * 0.01),
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
            suffixIcon: _emailController.text.isNotEmpty ? Icons.send : null,
            suffixIconOnPressed: () {
              String email = _emailController.text;
              _authController.sendOTPToEmail(email: email);
            },
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: size.height * 0.01),
          RoundRectTextFormField(
            labelText: 'OTP',
            hintText: 'Enter OTP Code',
            controller: _otpController,
            prefixIcon: Icons.password_sharp,
            validator: (value) {
              if (value.isEmpty || value.trim().isEmpty) {
                return 'OTP is required, send a verification code to your email';
              }
              return null;
            },
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: size.height * 0.01),
          RoundRectTextFormField(
            labelText: 'Password',
            hintText: 'Enter your password',
            controller: _passwordController,
            prefixIcon: Icons.vpn_key_outlined,
            obscureText: !isPasswordVisible,
            suffixIcon:
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            suffixIconOnPressed: () {
              setState(() {
                isPasswordVisible = !isPasswordVisible;
              });
            },
            validator: (value) {
              pw = value;
              if (value.isEmpty || value.trim().isEmpty) {
                return 'Password is required!';
              }
              if (value.toString().length < 6) {
                return 'Password should be longer or equal to 6 characters.';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: size.height * 0.01),
          RoundRectTextFormField(
            labelText: 'Confirm Password',
            hintText: 'Re-type password',
            controller: _confirmPasswordController,
            prefixIcon: Icons.vpn_key,
            obscureText: !isConfirmPasswordVisible,
            suffixIcon: isConfirmPasswordVisible
                ? Icons.visibility
                : Icons.visibility_off,
            suffixIconOnPressed: () {
              setState(() {
                isConfirmPasswordVisible = !isConfirmPasswordVisible;
              });
            },
            validator: (value) {
              if (value.isEmpty || value.trim().isEmpty) {
                return 'Confirm Password is required!';
              }
              if (value != pw) {
                return 'Password does not match';
              }
              return null;
            },
            textInputAction: TextInputAction.done,
          ),
          SizedBox(height: size.height * 0.03),
          RoundRectElevatedButton(
            width: double.infinity,
            height: 40.0,
            title: 'Register',
            onPressed: () {
              String name = _nameController.text;
              String email = _emailController.text;
              String password = _passwordController.text;
              String photoUrl = "https://i.ibb.co/wgM0fd7/Png-Item-1468843.png";
              String otp = _otpController.text;

              if (_registerFormKey.currentState!.validate()) {
                _authController.signUp(
                  name: name,
                  email: email,
                  password: password,
                  photoUrl: photoUrl,
                  otp: otp,
                );
              }
            },
          ),
          TextButton(
            child: Text('Login'),
            onPressed: () {
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}
