import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = prefs.getBool('isFirstRun') ?? true;

    if (isFirstRun) {
      context.go('/onboarding/start');
    } else {
      context.go('/filter');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF27B473),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 300),
              SvgPicture.asset(
                'assets/images/mr_pick_logo.svg',
                package: 'pickly_design_system',
                width: 103,
                height: 103,
              ),
              const SizedBox(height: 32),
              SvgPicture.asset(
                'assets/images/pickly_logo_text.svg',
                package: 'pickly_design_system',
                width: 140,
                height: 47,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
