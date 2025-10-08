import 'package:expenses_app/models/HiveService.dart';
import 'package:expenses_app/pages/home.dart';
import 'package:expenses_app/providers/bottom_navbar_manager.dart';
import 'package:expenses_app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await HiveService.init();
  } catch (e) {
    print('Hive initialization error: $e');
    // You might want to show an error dialog or use a fallback storage method
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expenses App',
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: Home(),
    );
  }
}
