import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zymo_internship/screens/twilio_login_page.dart';
import 'functions/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Add this line

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');  // Debug print
  } catch (e) {
    print('Error initializing Firebase: $e');  // Debug print
  }

  runApp(const ZymoV2());
}

class ZymoV2 extends StatelessWidget {
  const ZymoV2({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zymo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: twiliologinpage(),
      // Add error handling
      builder: (context, widget) {
        if (widget == null) return const SizedBox.shrink();

        return widget;
      },
    );
  }
}
