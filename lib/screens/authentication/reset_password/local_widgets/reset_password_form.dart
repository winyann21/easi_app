// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:easi/controllers/auth_controller.dart';
import 'package:easi/widgets/app_elevatedbutton.dart';
import 'package:easi/widgets/app_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordForm extends StatefulWidget {
  const ResetPasswordForm({Key? key}) : super(key: key);

  @override
  _ResetPasswordFormState createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm> {
  final _authController = Get.find<AuthController>();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _resetPasswordFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Form(
      key: _resetPasswordFormKey,
      child: Column(
        children: [
          RoundRectTextFormField(
            controller: _emailController,
            hintText: 'Enter your e-mail address',
            labelText: 'E-mail Address',
            prefixIcon: Icons.email_sharp,
            suffixIcon: null,
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
          ),
          SizedBox(height: size.height * 0.03),
          RoundRectElevatedButton(
            width: double.infinity,
            height: 40.0,
            title: 'Reset Password',
            onPressed: () {
              String email = _emailController.text;
              if (_resetPasswordFormKey.currentState!.validate()) {
                _authController.resetPassword(email: email);
              }
            },
          ),
        ],
      ),
    );
  }
}
