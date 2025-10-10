import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Onboarding start screen - First screen users see when starting onboarding
///
/// This screen introduces the app and allows users to begin the onboarding process
/// by navigating to the household information screen.
class OnboardingStartScreen extends StatefulWidget {
  const OnboardingStartScreen({super.key});

  @override
  State<OnboardingStartScreen> createState() => _OnboardingStartScreenState();
}

class _OnboardingStartScreenState extends State<OnboardingStartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('온보딩 시작'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App logo or welcome icon
              const Icon(
                Icons.shopping_basket,
                size: 120,
                color: Colors.green,
              ),
              const SizedBox(height: 32),

              // Welcome title
              Text(
                'Pickly에 오신 것을 환영합니다!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Welcome description
              Text(
                '맞춤형 상품 추천을 위해\n간단한 정보를 입력해주세요',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Start button
              ElevatedButton(
                onPressed: () {
                  context.go('/onboarding/household');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '시작하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
