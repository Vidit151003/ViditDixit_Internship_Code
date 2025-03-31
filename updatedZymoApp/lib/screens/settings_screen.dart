import 'package:flutter/material.dart';
import 'package:letzrentnew/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
          centerTitle: true,
        ),
        body: ListView(
          children: [
            SwitchListTile(
              value: themeProvider.isDark,
              onChanged: (val) => themeProvider.toggleTheme(),
              title: Text('Dark Mode (Beta)'),
              secondary: Icon(themeProvider.isDark ? Icons.dark_mode : Icons.light_mode),
              controlAffinity: ListTileControlAffinity.leading, // Moves switch to the right
            ),
          ],
        ),
      ),
    );
  }
}
