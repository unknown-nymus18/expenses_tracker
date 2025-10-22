import 'package:expenses_app/models/HiveService.dart';
import 'package:expenses_app/pages/auth_gate.dart';
import 'package:expenses_app/pages/home.dart';
import 'package:expenses_app/providers/bottom_navbar_manager.dart';
import 'package:expenses_app/providers/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  try {
    await HiveService.init();
  } catch (e) {
    print('Hive initialization error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => BottomNavbarManager()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Expenses App',
          theme: themeProvider.themeData,
          home: child,
        );
      },
      child: AuthGate(),
    );
  }
}
