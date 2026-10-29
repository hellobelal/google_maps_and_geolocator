import 'package:flutter/material.dart';
import 'splash_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GeoTrackerApp());
}

class AppColors {
  static const primary = Color(0xFF1A73E8);
  static const deep = Color(0xFF0B3D91);
  static const accent = Color(0xFF00C9A7);
  static const dark = Color(0xFF0A1931);
}

class GeoTrackerApp extends StatelessWidget {
  const GeoTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoTracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      home: const SplashPage(),
    );
  }
}
