import 'package:flutter/material.dart';
import 'package:zymo_internship/functions/firebase_fuctions.dart';
 // Ensure this import is correct

class UserLandingScreen extends StatefulWidget {
  const UserLandingScreen({super.key, });
  // Not a Future

  @override
  _UserLandingScreenState createState() => _UserLandingScreenState();
}

class _UserLandingScreenState extends State<UserLandingScreen> {
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator() // Show loader while processing
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("This is the user landing page"), // Display userId if available
          ],
        ),
      ),
    );
  }
}