import 'package:expenses_app/models/HiveService.dart';
import 'package:expenses_app/providers/theme.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  late ThemeData _themeData;

  ThemeProvider() {
    // Initialize from Hive settings with error handling
    try {
      final settings = HiveService.getSettings();
      _themeData = (settings?.isDarkMode ?? false) ? darkMode : lightMode;
    } catch (e) {
      // If Hive is not initialized yet (hot reload), default to light mode
      _themeData = lightMode;
    }
  }

  ThemeData get themeData => _themeData;

  bool isDarkMode() {
    return _themeData == darkMode;
  }

  set setTheme(ThemeData theme) {
    _themeData = theme;
    notifyListeners();
  }

  void toggleTheme() async {
    if (_themeData == darkMode) {
      _themeData = lightMode;
      try {
        await HiveService.updateDarkMode(false);
      } catch (e) {
        print('Error saving dark mode preference: $e');
      }
    } else {
      _themeData = darkMode;
      try {
        await HiveService.updateDarkMode(true);
      } catch (e) {
        print('Error saving dark mode preference: $e');
      }
    }
    notifyListeners();
  }
}
