import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/onboarding/screens/splash_screen.dart';
import '../features/onboarding/screens/age_category_screen.dart';

/// Creates and configures the GoRouter for the Pickly Mobile app
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding/age-category',
      name: 'age-category',
      builder: (context, state) => const AgeCategoryScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            '페이지를 찾을 수 없습니다',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Path: ${state.uri.path}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/splash'),
            child: const Text('홈으로 돌아가기'),
          ),
        ],
      ),
    ),
  ),
);
