import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letzrentnew/Utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String font = 'Garamond';
ThemeData lightTheme = ThemeData(
  textTheme: GoogleFonts.montserratTextTheme(),
    scaffoldBackgroundColor: greyColor,
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android:
          //CupertinoPageTransitionsBuilder()
          ZoomPageTransitionsBuilder()
    }),
    brightness: Brightness.light,
    iconTheme: IconThemeData(color: appColor),
    appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: appColor,
        iconTheme: IconThemeData(color: whiteColor),
        toolbarTextStyle: TextStyle(
            color: whiteColor, fontSize: 20, fontWeight: FontWeight.w600)),
    primaryColor: whiteColor,
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: appColor)),
    secondaryHeaderColor: Colors.black,
    fontFamily: font,
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            backgroundColor: Colors.black, foregroundColor: whiteColor)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      foregroundColor: whiteColor,
      backgroundColor: Colors.black,
    ),
    colorScheme: const ColorScheme.light(primary: Colors.black)
        .copyWith(secondary: appColor, surface: whiteColor));

ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      foregroundColor: Colors.black,
      backgroundColor: whiteColor,
    ),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            backgroundColor: Colors.black, foregroundColor: whiteColor)),
    fontFamily: font,
    colorScheme: const ColorScheme.dark(primary: whiteColor)
        .copyWith(secondary: whiteColor));

class ThemeProvider with ChangeNotifier {
  late bool _isDark;
  bool get isDark => _isDark;
  final String key = 'theme';
  late SharedPreferences _prefs;
  ThemeProvider() {
    _isDark = false;
    getThemeFromStorage();
  }
  void toggleTheme() {
    _isDark = !_isDark;
    saveThemeToStorage(_isDark);
    notifyListeners();
  }

  Future<void> initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> getThemeFromStorage() async {
    await initPrefs();
    _isDark = _prefs.getBool(key) ?? false;
    notifyListeners();
  }

  Future<void> saveThemeToStorage(bool value) async {
    await initPrefs();
    await _prefs.setBool(key, value);
  }
}
