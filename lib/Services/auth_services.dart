import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:letzrentnew/Screens/auth_screens/otp_screen.dart';
import 'package:letzrentnew/Services/firebase_services.dart';
import 'package:letzrentnew/Utils/constants.dart';
import 'package:letzrentnew/Utils/functions.dart';
import 'package:letzrentnew/providers/home_provider.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class Auth {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<void> signInWithEmail(String email, String password) async {
    UserCredential authResult = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await FirebaseServices().setUserDetails(
        authResult.user!.uid,
        authResult.user!.displayName.toString(),
        authResult.user!.email.toString(),
        phone: '');
  }

  Future<void> signInFunction(
      AuthCredential credential, BuildContext context) async {
    final UserCredential authResult =
        await firebaseAuth.signInWithCredential(credential);
    final User? user = authResult.user;

    assert(!user!.isAnonymous);
    assert(await user?.getIdToken() != null);

    final User? currentUser = firebaseAuth.currentUser;
    assert(user?.uid == currentUser?.uid);
    await postCreation(authResult, context);
  }

  static Future<void> postCreation(
      UserCredential authResult, BuildContext context) async {
    bool? isNewUser = authResult.additionalUserInfo?.isNewUser;
    if (isNewUser ?? true) {
      final HomeProvider provider =
          Provider.of<HomeProvider>(context, listen: false);
      provider.isNewUserFunction(true);
      final amount = await FirebaseServices().getVoucherAmount();
      await FirebaseServices().addNewVoucher(
        amount?['newUserAmount'] ?? 50,
        context,
        validTillDateTime: DateTime.now().add(Duration(days: 15)),
        validFromDateTime: DateTime.now(),
      );
      await FirebaseServices().setUserDetails(authResult.user!.uid,
          authResult.user?.displayName ?? '', authResult.user?.email ?? '',
          phone: authResult.user!.phoneNumber.toString());
      mixpanel.identify(authResult.user!.uid.toString());
    }
  }

  Future<bool> signUpWithEmail(
      BuildContext context, String email, String password, String name) async {
    UserCredential authResult =
        await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    Provider.of<HomeProvider>(context, listen: false).isNewUserFunction(true);
    final amount = await FirebaseServices().getVoucherAmount();
    await FirebaseServices().addNewVoucher(
        amount?['newUserAmount'] ?? 50, context,
        validTillDateTime: DateTime.now().add(Duration(days: 15)),
        validFromDateTime: DateTime.now());
    await firebaseAuth.currentUser?.updateDisplayName(name ?? 'user');
    await FirebaseServices().setUserDetails(
        authResult.user!.uid, name, authResult.user!.email.toString(),
        phone: '');
    return true;
  }

  Future<bool> forgotPassword(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
    return true;
  }

  User? getCurrentUser() {
    final User? user = firebaseAuth.currentUser;
    return user;
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
    // await googleSignIn.signOut();
  }

  Future<bool> signInWithOTP(
      String verificationId, BuildContext context, String otp) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      await signInFunction(credential, context);
      return true;
    } catch (e) {
      mixpanel.track('OTP error', properties: {'error': e});
      if (e.hashCode.toString() == 'invalid-verification-code') {
        warningPopUp(context, oops, 'Invalid OTP');
      } else {
        warningPopUp(context, oops, 'Something went wrong. $e');
      }
      return false;
    }
  }

  Future<void> sendOTP(
      String phone, BuildContext context, bool isResend) async {
    final PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential credential) async {
      await firebaseAuth.signInWithCredential(credential);
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException e) {
      String errorMessage = 'OTP verification failed';
      if (e.code == 'invalid-phone-number') {
        errorMessage = 'The phone number is invalid.';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Too many requests. Please try again later.';
      } else if (e.code == 'quota-exceeded') {
        errorMessage = 'Quota exceeded. Please try again later.';
      } else {
        errorMessage = 'OTP verification failed: ${e.message}';
      }
      CommonFunctions.showSnackbar(context, errorMessage);
    };

    final provider = Provider.of<HomeProvider>(context, listen: false);

    final void Function(String verificationId, int? resendToken) smsOtpSend =
        (String verificationId, int? resendToken) {
      provider.otpInitTimer(30, resendToken!);

      if (isResend) {
        CommonFunctions.showSnackbar(context, 'OTP sent');
      } else {
        // This part of the function is still async, but we'll handle it inside.
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (context) => Otp(
              verificationId: verificationId,
              phoneNumber: phone,
            ),
          ),
        )
            .then((value) {
          if (value != null) {
            Navigator.pop(context, value);
          } else {
            CommonFunctions.showSnackbar(context, 'OTP verification failed');
          }
        });
      }
    };

    try {
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: smsOtpSend,
        forceResendingToken: provider.resendToken,
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      mixpanel.track('otp_fail', properties: {'error': e.toString()});
      CommonFunctions.showSnackbar(context, 'Something went wrong: $e');
      print(e);
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      final currentUser2 = firebaseAuth.currentUser;
      if (currentUser2 != null) {
        await currentUser2.delete();
        CommonFunctions.showSnackbar(context, 'Account deleted successfully');
      } else {
        CommonFunctions.showSnackbar(context, 'No user is currently logged in');
      }
    } catch (e) {
      print(e);
      CommonFunctions.showSnackbar(context, 'Failed to delete account: $e');
    }
  }
}
