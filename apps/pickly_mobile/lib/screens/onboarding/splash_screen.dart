import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

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