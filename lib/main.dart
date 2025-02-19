import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:letzrentnew/Utils/constants.dart';
import 'package:letzrentnew/Utils/app_data.dart';
import 'package:letzrentnew/Utils/functions.dart';
import 'package:letzrentnew/Utils/routes.dart';
import 'package:letzrentnew/providers/home_provider.dart';
import 'package:provider/provider.dart';

import './screens/tabs_screen.dart';
import 'Screens/auth_screens/login_screen.dart';
import 'providers/car_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    await Firebase.initializeApp();
    await CommonFunctions.updateFCMtoken();
    await initMixpanel();
    await initCrashlytics();

    runApp(MyApp());
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}

Future<void> initCrashlytics() async {
  final FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;
  FlutterError.onError = crashlytics.recordFlutterError;

  if (currentEnv == Environment.Prod && kReleaseMode) {
    await crashlytics.setCrashlyticsCollectionEnabled(true);
  } else {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
    };
    await crashlytics.setCrashlyticsCollectionEnabled(false);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (context, child) => MultiProvider(
        providers: [
          ChangeNotifierProvider<CarProvider>(
              create: (context) => CarProvider()),
          ChangeNotifierProvider<HomeProvider>(
              create: (context) => HomeProvider()),
          ChangeNotifierProvider<ThemeProvider>(
            create: (context) => ThemeProvider(),
          )
        ],
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) => MaterialApp(
            locale: const Locale('en', 'US'),
            debugShowCheckedModeBanner: false,
            title: appName,
            theme: themeProvider.isDark ? darkTheme : lightTheme,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
              child: child!,
            ),
            home: AuthStreamHandler(),
            routes: PageRoutes.routes,
            onUnknownRoute: (settings) {
              return MaterialPageRoute(builder: (ctx) => TabScreen());
            },
          ),
        ),
      ),
    );
  }
}

/// **New Class to Handle Authentication State**
class AuthStreamHandler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return spinkit; // Show loading indicator while checking auth state
        }

        if (snapshot.hasData) {
          return TabScreen(); // User is authenticated
        }

        return LoginScreen();
        // User is logged out
      },
    );
  }
}
