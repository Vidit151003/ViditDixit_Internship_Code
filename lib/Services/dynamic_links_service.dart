import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:letzrentnew/providers/home_provider.dart';
import 'package:letzrentnew/Utils/app_data.dart';
import 'package:letzrentnew/Utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_services.dart';
import 'firebase_services.dart';

class DynamicLinksService {
  // Singleton instance
  static final DynamicLinksService _instance = DynamicLinksService._internal();
  factory DynamicLinksService() => _instance;
  DynamicLinksService._internal();

  final FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  // Initialize Dynamic Links
  Future<void> initDynamicLinks(BuildContext context) async {
    // Handle the initial dynamic link when the app is opened
    final PendingDynamicLinkData? data = await dynamicLinks.getDynamicLink(Uri.base);
    if (data?.link != null) {
      _handleDynamicLinkUtil(data!, context);
    }

    // Listen for incoming dynamic links while the app is running
    dynamicLinks.onLink.asBroadcastStream().listen((PendingDynamicLinkData? dynamicLink) {
      if (dynamicLink?.link != null) {
        _handleDynamicLinkUtil(dynamicLink!, context);
      }
    }).onError((error) {
      print('Error handling dynamic link: $error');
    });
  }

  // Handle dynamic link navigation
  void _handleDynamicLinkUtil(PendingDynamicLinkData data, BuildContext context) async {
    final String? uid = Auth().getCurrentUser()?.uid;
    final Uri deepLink = data.link;
    final List<String> referralUid = deepLink.path.split('/');

    if (referralUid.length > 1 && referralUid[1].length == 28 && referralUid[1] != uid) {
      Provider.of<HomeProvider>(context, listen: false).isReferralFunction(true);
      await FirebaseServices().addReferralVouchers(referralUid[1], uid!, referralAmount);
    }

    // Navigate to the screen if needed
    if (deepLink.path.isNotEmpty) {
      Navigator.pushNamed(context, deepLink.path);
    }
  }

  // Create a Dynamic Link (Updated for Deprecation)
  Future<String?> createDynamicLink() async {
    final User? user = Auth().getCurrentUser();
    if (user == null) return null;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? existingLink = prefs.getString(user.uid);

    if (existingLink != null && existingLink.isNotEmpty) {
      return existingLink;
    }

    try {
      final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: 'https://letzrentnew.page.link',
        link: Uri.parse('https://letzrent.com/${user.uid}'),
        androidParameters: const AndroidParameters(
          packageName: 'com.letzrent.letzrentnew',
        ),
        iosParameters: const IOSParameters(
          bundleId: 'com.letzrent.letzrent',
          appStoreId: appStoreId,
        ),
        socialMetaTagParameters: const SocialMetaTagParameters(
          title: 'Zymo Referral Link',
          description: 'Refer Zymo app to your friends and get ₹100 off for you and your friend.',
        ),
      );

      final Uri dynamicUrl = await dynamicLinks.buildLink(parameters);

      // Save generated link in SharedPreferences
      await prefs.setString(user.uid, dynamicUrl.toString());
      return dynamicUrl.toString();
    } catch (e) {
      print('Error creating dynamic link: $e');
      return null;
    }
  }

}
