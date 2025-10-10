import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/onboarding/screens/splash_screen.dart';
import '../features/onboarding/screens/onboarding_start_screen.dart';
import '../features/onboarding/screens/onboarding_household_screen.dart';
import '../features/onboarding/screens/onboarding_region_screen.dart';
import '../features/filter/screens/filter_home_screen.dart';

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
      path: '/onboarding/start',
      name: 'onboarding-start',
      builder: (context, state) => const OnboardingStartScreen(),
    ),
    GoRoute(
      path: '/onboarding/household',
      name: 'onboarding-household',
      builder: (context, state) => const OnboardingHouseholdScreen(),
    ),
    GoRoute(
      path: '/onboarding/region',
      name: 'onboarding-region',
      builder: (context, state) => const OnboardingRegionScreen(),
    ),
    GoRoute(
      path: '/filter',
      name: 'filter',
      builder: (context, state) => const FilterHomeScreen(),
    ),
  ],
  redirect: (context, state) async {
    final location = state.uri.path;

    // Allow access to splash screen without redirect
    if (location == '/splash') {
      return null;
    }

    // Check if user is on first run
    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = prefs.getBool('isFirstRun') ?? true;

    // Redirect to onboarding if first run and trying to access filter
    if (isFirstRun && location == '/filter') {
      return '/onboarding/start';
    }

    // Redirect to filter if not first run and trying to access onboarding
    if (!isFirstRun && location.startsWith('/onboarding')) {
      return '/filter';
    }

    return null;
  },
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
