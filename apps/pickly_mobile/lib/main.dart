import 'package:flutter/material.dart';
import 'screens/onboarding/splash_screen.dart';

void main() {
  runApp(const PicklyApp());
}

class PicklyApp extends StatelessWidget {
  const PicklyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pickly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF27B473),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}