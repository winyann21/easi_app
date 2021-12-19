// ignore_for_file: prefer_final_fields, prefer_const_constructors, avoid_print, unnecessary_new

import 'package:easi/controllers/user_controller.dart';
import 'package:easi/models/user.dart';
import 'package:easi/services/user_database.dart';
import 'package:easi/utils/show_loading.dart';
import 'package:easi/widgets/app_toast.dart';
import 'package:email_auth/email_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/state_manager.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  EmailAuth emailAuth =
      new EmailAuth(sessionName: "EASI - Easy Access Smart Inventory");
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );
  FirebaseAuth _auth = FirebaseAuth.instance; //instance of FirebaseAuth
  Rxn<User> _firebaseUser =
      Rxn<User>(); //user instance Rxn(observable and nullable)

  User? get user => _firebaseUser.value;

  @override
  void onInit() {
    _firebaseUser.bindStream(_auth.authStateChanges());
    super.onInit();
  }

  //google login
  void signInWithGoogle() async {
    try {
      GoogleSignInAccount? _googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication _googleAuth =
          await _googleUser!.authentication;

      //!PROMPT DIALOG WITH OTP TO PROCEED

      final AuthCredential _authCredential = GoogleAuthProvider.credential(
        accessToken: _googleAuth.accessToken,
        idToken: _googleAuth.idToken,
      );
      UserCredential _userCredential =
          await _auth.signInWithCredential(_authCredential);

      if (_userCredential.additionalUserInfo!.isNewUser) {
        UserModel _user = UserModel(
          id: _userCredential.user!.uid,
          email: _userCredential.user!.email,
          name: _userCredential.user!.displayName,
          isVerified: true,
        );

        if (await UserDatabase().createNewUser(_user)) {
          //user created successfully
          Get.find<UserController>().user = _user;
          Get.back();
        }
      }
    } on FirebaseAuthException catch (e) {
      String title = e.code.replaceAll(RegExp('-'), ' ').capitalize!;
      String errorMessage = '';
      if (e.code == 'user-not-found') {
        errorMessage = 'User not found, please try again.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password, please try again.';
      } else {
        errorMessage = "An error has occured!";
      }

      Get.snackbar(
        title,
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
    } catch (e) {
      showToast(msg: 'Login cancelled');
    }
  }

  //create user
  void signUp({
    required String name,
    required String email,
    required String password,
    required String photoUrl,
    required String otp,
  }) async {
    try {
      var response = emailAuth.validateOtp(
        recipientMail: email,
        userOtp: otp,
      );

      if (response) {
        showLoadingRegister();
        UserCredential credential = await _auth
            .createUserWithEmailAndPassword(
              email: email.trim(),
              password: password,
            )
            .whenComplete(() => dismissLoading());

        credential.user!.updateDisplayName(name);
        credential.user!.updatePhotoURL(photoUrl);

        //create user in user collection(firestore)
        UserModel _user = UserModel(
          id: credential.user!.uid,
          name: name,
          email: credential.user!.email,
          isVerified: true,
        );

        if (await UserDatabase().createNewUser(_user)) {
          //user created successfully
          Get.find<UserController>().user = _user;
          Get.back();
        }
      } else {
        Get.snackbar(
          'Verify OTP',
          'Invalid OTP, please enter correct code.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
        );
      }
    } on FirebaseAuthException catch (e) {
      String title = e.code.replaceAll(RegExp('-'), ' ').capitalize!;
      String errorMessage = '';
      if (e.code == 'weak-password') {
        errorMessage = 'Password is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage =
            'E-mail already exists, please provide a new email address.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid e-mail address, please try again.';
      } else {
        errorMessage = "An error has occured!";
      }

      Get.snackbar(
        title,
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "An error has occured!",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  //log in user
  void signIn({
    required String email,
    required String password,
  }) async {
    try {
      showLoadingLogin();
      UserCredential credential = await _auth
          .signInWithEmailAndPassword(
            email: email,
            password: password,
          )
          .whenComplete(() => dismissLoading());
      //confirm user
      Get.find<UserController>().user =
          await UserDatabase().getUser(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      String title = e.code.replaceAll(RegExp('-'), ' ').capitalize!;
      String errorMessage = '';
      if (e.code == 'wrong-password') {
        errorMessage = 'Invalid password, please try again.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid e-mail address, please try again.';
      } else if (e.code == 'user-not-found') {
        errorMessage =
            'User does not exist on $email. Create an account to get registered.';
      } else {
        errorMessage = "An error has occured!";
      }

      Get.snackbar(
        title,
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "An error has occured!",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  //log out user
  void signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();
      Get.find<UserController>()
          .clear(); //!CAN BE CHANGE IF USER DATA IS DELETED WHEN LOGGING OUT
    } on FirebaseAuthException catch (e) {
      String title = e.code.replaceAll(RegExp('-'), ' ').capitalize!;
      Get.snackbar(
        title,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
    } catch (e) {
      print(e);
    }
  }

  //reset password
  void resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.back();
      Get.snackbar(
        'Reset Password',
        'An email has sent to $email to reset password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[400],
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      String title = e.code.replaceAll(RegExp('-'), ' ').capitalize!;
      String errorMessage = '';
      if (e.code == 'user-not-found') {
        errorMessage = 'Account does not exist for $email';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid e-mail address, please try again.';
      } else {
        errorMessage = "An error has occured!";
      }

      Get.snackbar(
        title,
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "An error has occured!",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  //verify email
  void sendOTPToEmail({required String email}) async {
    try {
      var response = await emailAuth.sendOtp(
        recipientMail: email,
        otpLength: 6,
      );
      if (response) {
        Get.snackbar(
          'Email Verification',
          'A verification code has sent to $email to verify email',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[400],
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Email Verification',
          'OTP could not be sent to $email, please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "An error has occured!",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
