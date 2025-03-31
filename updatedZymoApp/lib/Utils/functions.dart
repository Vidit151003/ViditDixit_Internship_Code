import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:letzrentnew/Services/auth_services.dart';
import 'package:letzrentnew/Utils/constants.dart';
import 'package:letzrentnew/Utils/extensions.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Screens/auth_screens/login_screen.dart';
import '../Services/firebase_services.dart';

class CommonFunctions {
  static Future<void> navigateTo(BuildContext context, Widget page) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: ((context) => page)));
  }

  static int getRewardVoucherAmountRentPay(int amountPaid) {
    int reward = 100;
    if (amountPaid > 25000) {
      reward = 150;
    }
    return reward;
  }

  static Future navigateToSignIn(BuildContext context) async {
    return await Navigator.pushNamed(
        context, LoginScreen.routeName);
  }

  static Future<bool> callUsFunction() async =>
      await launchUrl(Uri.parse("tel://$ContactNumber"));

  static Future<void> whatsappFunction(String message) async {
    final String url = Platform.isIOS
        ? "https://wa.me/text=$message"
        : "whatsapp://send?text=$message";

    await launchUrl(Uri.parse(url)); // new line
  }
// static Future 
  static Future<void> updateFCMtoken() async {
    try {
      final firebase = FirebaseMessaging.instance;
      firebase.requestPermission();
      final String? fcmToken = await firebase.getToken();
      await FirebaseServices().setUserFCMToken(fcmToken!);
    } catch (e) {}
  }

  static showSnackbar(BuildContext context, String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.blue,
          content: Text(text,
              style: TextStyle(
                color: Colors.white,
              ))));
  static String getCityFromLocation(String pickedLocation) {
    return getLocation(pickedLocation).shortenString(28);
  }

  static String getLocation(String pickedLocation) {
    if (pickedLocation.isTrulyNotEmpty()) {
      try {
        final String location =
            pickedLocation.replaceAll(RegExp(r'\d(?!\d{0,2}$)'), '');
        final List<String> parts = location.split(',');
        if (parts.isNotEmpty) {
          final String city = parts.first;
          final String formattedLocation = city.trim();
          return formattedLocation.isEmpty ? pickedLocation : formattedLocation;
        } else {
          return pickedLocation;
        }
      } catch (e) {
        return 'Select a location';
      }
    } else {
      return 'Select a location';
    }
  }

  static deleteAccount(BuildContext context) {
    return showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Delete Account?'),
        content:
            Text('Deleting your account is irreversible and cannot be undone.'),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text('Yes'),
            textStyle: TextStyle(color: Colors.red),
            onPressed: () {
              Auth().deleteAccount(context)
                  .then((value) => CommonFunctions.navigateToSignIn(context));
            },
          ),
          CupertinoDialogAction(
            child: Text('No'),
            textStyle: TextStyle(color: Colors.blue),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
