import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/onboarding/splash_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: PicklyApp(),
    ),
  );
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