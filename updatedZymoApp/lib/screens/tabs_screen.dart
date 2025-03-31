import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_review/in_app_review.dart';

import 'package:letzrentnew/Services/dynamic_links_service.dart';
import 'package:letzrentnew/Services/firebase_services.dart';
import 'package:letzrentnew/Utils/constants.dart';
import 'package:letzrentnew/providers/home_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/contact_us.dart';
import 'home_page.dart';
import 'my orders.dart';
import 'Rewards/my_rewards.dart';

class TabScreen extends StatefulWidget {
  static const routeName = '/tabs-screen';

  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  bool value = false;

  @override
  void initState() {
    super.initState();
    //checkForUpdate(context);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle the incoming message here
      print("Received message: ${message.notification?.title}");
    });
  }

  int _selectedPageIndex = 0;

  void _selectPage(int index, HomeProvider value) {
    setState(() {
      _selectedPageIndex = index;
    });
    if (index == 1) {
      if (value.rewardIndicator) {
        value.setRewardIndicator(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    DynamicLinksService().initDynamicLinks(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.purple,
        body: SafeArea(
          child: IndexedStack(
            index: _selectedPageIndex,
            children: [
              HomePage(),
              MyRewards(),
              MyBookings(),
              ContactUs(),
            ],
          ),
        ),
        bottomNavigationBar: Consumer<HomeProvider>(
          builder: (BuildContext context, value, child) {
            return BottomNavigationBar(
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              onTap: (index) => _selectPage(index, value),
              selectedItemColor: Theme.of(context).colorScheme.secondary,
              currentIndex: _selectedPageIndex,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: SizedBox(
                    width: 40,
                    child: Stack(
                      children: [
                        Center(
                          child: Image.asset('assets/icons/HomeIcons/rewards.png'),
                        ),
                        if (value.rewardIndicator)
                          Align(
                            alignment: Alignment.topRight,
                            child: Icon(
                              Icons.circle,
                              size: 10,
                              color: Colors.red,
                            ),
                          ),
                      ],
                    ),
                  ),
                  label: 'Rewards',
                ),
                BottomNavigationBarItem(
                  icon: Image.asset('assets/icons/HomeIcons/bookings.png'),
                  label: 'Bookings',
                ),
                BottomNavigationBarItem(
                  icon: Image.asset('assets/icons/HomeIcons/contact.png'),
                  label: 'Contact Us',
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void checkForUpdate(BuildContext context) async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final List<int> currentVersion = _parseVersion(packageInfo.version);

      final Map<String, dynamic>? updateData = await FirebaseServices().getUpdateInfo();
      final Map<String, dynamic> data = updateData?[Platform.isIOS ? 'iOS' : 'Android'] ?? {};

      final List<int> minVersion = _parseVersion(data['minVersionAllowedProd']?.toString() ?? '0.0.0');
      final List<int> latestVersion = _parseVersion(data['latestVersion']?.toString() ?? '0.0.0');
      contactNumber = data['contactNumber'] ?? 'N/A'; // Provide a default fallback

      if (_isVersionLower(currentVersion, minVersion)) {
        await showUpdateDialog(context, isForced: true);
      } else if (_isVersionLower(currentVersion, latestVersion)) {
        await showUpdateDialog(context);
      }
    } catch (e) {
      print("Error checking for update: $e");
    }
  }

// Helper function to parse version strings into lists of integers
  List<int> _parseVersion(String version) {
    return version.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  }

// Helper function to compare versions
  bool _isVersionLower(List<int> current, List<int> target) {
    for (int i = 0; i < target.length; i++) {
      if (i >= current.length) return true; // Current version is shorter, so it's older
      if (current[i] < target[i]) return true;
      if (current[i] > target[i]) return false;
    }
    return false;
  }


  Future<void> showUpdateDialog(BuildContext context, {bool isForced = false}) async {
    return showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Update Available'),
        content: Text(
            'A new version of $appName is available. Please update the app to get the latest features!$happyEmoji'),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text('Update'),
            onPressed: () async {
              try {
                await InAppReview.instance.openStoreListing(appStoreId: appStoreId);
              } catch (e) {
                print(e);
                await launchUrl(Uri.parse(platformStoreLink));
              }
              SystemNavigator.pop();
            },
          ),
          if (!isForced)
            CupertinoDialogAction(
              child: Text('Next time'),
              onPressed: () => Navigator.pop(context, true), // Dismiss dialog
            ),
        ],
      ),
    );
  }

}
