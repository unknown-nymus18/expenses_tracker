import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(primary: Colors.grey.shade400),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Color.fromARGB(255, 230, 230, 250), // Light lavender
    selectedItemColor: Color.fromARGB(255, 0, 0, 0), // Indigo
    unselectedItemColor: Color.fromARGB(255, 128, 128, 128), // Gray
    elevation: 8.0,
  ),
  appBarTheme: AppBarTheme(backgroundColor: Color.fromARGB(255, 230, 230, 250)),
  useMaterial3: true,
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Color.fromARGB(255, 38, 38, 38), // Dark gray
    selectedItemColor: Color.fromARGB(255, 45, 46, 46), // Light blue
    unselectedItemColor: Color.fromARGB(255, 169, 169, 169), // Dark gray
    elevation: 8.0,
  ),
  appBarTheme: AppBarTheme(backgroundColor: Color.fromARGB(255, 0, 0, 0)),
  colorScheme: ColorScheme.dark(
    surface: Color.fromARGB(255, 0, 0, 0),
    primary: Color.fromARGB(255, 38, 38, 38),
    secondary: Color.fromARGB(255, 38, 38, 38),
  ),
  dialogTheme: DialogThemeData(backgroundColor: Colors.grey[800]),
  useMaterial3: true,
);
