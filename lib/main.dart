import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/cart_item.dart';
import 'pages/home_page.dart';
import 'pages/auth_page.dart';

void main() {
  runApp(const KinoshkaApp());
}

List<CartItem> cart = [];
Color customSeedColor = const Color(0xFF1E56E1);
ThemeMode currentThemeMode = ThemeMode.light;

class KinoshkaApp extends StatefulWidget {
  const KinoshkaApp({super.key});

  @override
  State<KinoshkaApp> createState() => _KinoshkaAppState();

  static _KinoshkaAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_KinoshkaAppState>()!;
}

class _KinoshkaAppState extends State<KinoshkaApp> {
  void updateTheme(ThemeMode mode, [Color? seed]) {
    setState(() {
      currentThemeMode = mode;
      if (seed != null) customSeedColor = seed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KinoBox',
      debugShowCheckedModeBanner: false,
      themeMode: currentThemeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: customSeedColor, brightness: Brightness.light),
        textTheme: GoogleFonts.manropeTextTheme(),
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: customSeedColor, brightness: Brightness.dark),
        textTheme: GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme),
      ),
      home: const AuthPage(),
    );
  }
}
