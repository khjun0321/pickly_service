import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pickly_mobile/features/onboarding/screens/splash_screen.dart';
import 'package:pickly_mobile/features/onboarding/screens/age_category_screen.dart';
// TODO: Import remaining onboarding screens when implemented
// import '../features/onboarding/screens/onboarding_start_screen.dart';
// import '../features/onboarding/screens/personal_info_screen.dart';
// import '../features/onboarding/screens/region_screen.dart';
// import '../features/onboarding/screens/income_screen.dart';

// Main app screens
// TODO: Import main app screens when implemented
// import '../features/home/screens/home_screen.dart';
// import '../features/policy/screens/policy_detail_screen.dart';

/// Type-safe route paths
/// Use these constants for navigation instead of hardcoded strings
abstract class Routes {
  // Splash
  static const splash = '/splash';

  // Onboarding flow
  static const onboardingStart = '/onboarding/start';
  static const personalInfo = '/onboarding/personal-info';
  static const region = '/onboarding/region';
  static const ageCategory = '/onboarding/age-category';
  static const income = '/onboarding/income';

  // Main app
  static const home = '/home';
  static const filter = '/home/filter';

  // Policy
  static String policyDetail(String id) => '/policy/$id';
  static const search = '/policy/search';
}

/// Creates and configures the GoRouter for the Pickly Mobile app
///
/// Route structure:
/// - /splash: Initial splash screen (2s auto-redirect)
/// - /onboarding/*: Onboarding flow (start → personal-info → region → age-category)
/// - /home: Main policy feed
/// - /policy/:id: Policy detail pages
final GoRouter appRouter = GoRouter(
  initialLocation: Routes.splash,

  // Global redirect logic
  redirect: (context, state) {
    // TODO: Implement onboarding completion check
    // final prefs = await SharedPreferences.getInstance();
    // final isOnboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    // final currentPath = state.uri.path;

    // Redirect to onboarding if not completed
    // if (!isOnboardingComplete &&
    //     !currentPath.startsWith('/onboarding') &&
    //     currentPath != Routes.splash) {
    //   return Routes.onboardingStart;
    // }

    return null; // No redirect
  },

  routes: [
    // ==================== SPLASH ====================
    GoRoute(
      path: Routes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // ==================== ONBOARDING FLOW ====================
    // TODO: Uncomment when OnboardingStartScreen is implemented
    // GoRoute(
    //   path: Routes.onboardingStart,
    //   name: 'onboarding-start',
    //   builder: (context, state) => const OnboardingStartScreen(),
    // ),

    // TODO: Uncomment when PersonalInfoScreen is implemented
    // 001: Personal Info (name, age, gender)
    // GoRoute(
    //   path: Routes.personalInfo,
    //   name: 'personal-info',
    //   builder: (context, state) => const PersonalInfoScreen(),
    // ),

    // TODO: Uncomment when RegionScreen is implemented
    // 002: Region selection
    // GoRoute(
    //   path: Routes.region,
    //   name: 'region',
    //   builder: (context, state) => const RegionScreen(),
    // ),

    // 003: Age category selection (IMPLEMENTED)
    GoRoute(
      path: Routes.ageCategory,
      name: 'age-category',
      builder: (context, state) => const AgeCategoryScreen(),
    ),

    // TODO: Uncomment when IncomeScreen is implemented
    // 004: Income level (optional, Phase 2)
    // GoRoute(
    //   path: Routes.income,
    //   name: 'income',
    //   builder: (context, state) => const IncomeScreen(),
    // ),

    // ==================== MAIN APP ====================
    // TODO: Uncomment when HomeScreen is implemented
    // GoRoute(
    //   path: Routes.home,
    //   name: 'home',
    //   builder: (context, state) => const HomeScreen(),
    //   routes: [
    //     // Filter screen
    //     GoRoute(
    //       path: 'filter',
    //       name: 'filter',
    //       builder: (context, state) => const FilterScreen(),
    //     ),
    //   ],
    // ),

    // ==================== POLICY ====================
    // TODO: Uncomment when PolicyDetailScreen is implemented
    // GoRoute(
    //   path: '/policy/:id',
    //   name: 'policy-detail',
    //   builder: (context, state) {
    //     final id = state.pathParameters['id']!;
    //     return PolicyDetailScreen(policyId: id);
    //   },
    // ),

    // TODO: Uncomment when SearchScreen is implemented
    // GoRoute(
    //   path: Routes.search,
    //   name: 'search',
    //   builder: (context, state) => const SearchScreen(),
    // ),
  ],

  // ==================== ERROR HANDLING ====================
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
            onPressed: () => context.go(Routes.splash),
            child: const Text('홈으로 돌아가기'),
          ),
        ],
      ),
    ),
  ),
);
