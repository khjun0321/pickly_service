/// Example usage of AppHeader component
///
/// This file demonstrates all three types of AppHeader:
/// - Home header with logo and menu
/// - Detail header with back button, title, and actions
/// - Onboarding header with back button only
library;

import 'package:flutter/material.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

/// Example app demonstrating AppHeader usage
class AppHeaderExample extends StatelessWidget {
  const AppHeaderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppHeader Examples',
      theme: ThemeData(
        fontFamily: PicklyTypography.fontFamily,
        scaffoldBackgroundColor: BackgroundColors.app,
      ),
      home: const ExampleListScreen(),
    );
  }
}

/// Main screen showing all header examples
class ExampleListScreen extends StatelessWidget {
  const ExampleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColors.app,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Spacing.lg),
          children: [
            const Text(
              'AppHeader Examples',
              style: PicklyTypography.titleLarge,
            ),
            const SizedBox(height: Spacing.xxl),
            _buildExampleCard(
              context,
              title: '1. Home Header',
              description: 'Logo + Hamburger menu',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HomeHeaderExample(),
                ),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            _buildExampleCard(
              context,
              title: '2. Detail Header',
              description: 'Back + Title + Actions',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DetailHeaderExample(),
                ),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            _buildExampleCard(
              context,
              title: '3. Onboarding Header',
              description: 'Back button only',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OnboardingHeaderExample(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleCard(
    BuildContext context, {
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: PicklyBorderRadius.radiusLg,
      child: Container(
        padding: const EdgeInsets.all(Spacing.lg),
        decoration: BoxDecoration(
          color: BackgroundColors.surface,
          borderRadius: PicklyBorderRadius.radiusLg,
          boxShadow: PicklyShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: PicklyTypography.titleMedium,
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              description,
              style: PicklyTypography.bodySmall.copyWith(
                color: TextColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 1: Home Header
class HomeHeaderExample extends StatelessWidget {
  const HomeHeaderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColors.app,
      appBar: AppHeader.home(
        onMenuTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menu tapped!')),
          );
        },
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.home_rounded,
                size: 64,
                color: BrandColors.primary,
              ),
              const SizedBox(height: Spacing.xxl),
              Text(
                'Home Header Example',
                style: PicklyTypography.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.lg),
              Text(
                'Features:\n'
                '• Pickly logo (28px height)\n'
                '• Hamburger menu icon (20x20)\n'
                '• Fixed height: 48px\n'
                '• Horizontal padding: 16px',
                style: PicklyTypography.bodyMedium.copyWith(
                  color: TextColors.secondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Example 2: Detail Header
class DetailHeaderExample extends StatelessWidget {
  const DetailHeaderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColors.app,
      appBar: AppHeader.detail(
        title: 'Product Details',
        onBack: () => Navigator.pop(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, size: 20),
            color: TextColors.primary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share tapped!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, size: 20),
            color: TextColors.primary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Favorite tapped!')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.article_rounded,
                size: 64,
                color: BrandColors.primary,
              ),
              const SizedBox(height: Spacing.xxl),
              Text(
                'Detail Header Example',
                style: PicklyTypography.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.lg),
              Text(
                'Features:\n'
                '• Back button (iOS style)\n'
                '• Centered title (Pretendard Bold 18px)\n'
                '• Optional action buttons\n'
                '• Auto-balanced layout\n'
                '• Default Navigator.pop on back',
                style: PicklyTypography.bodyMedium.copyWith(
                  color: TextColors.secondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Example 3: Onboarding Header
class OnboardingHeaderExample extends StatelessWidget {
  const OnboardingHeaderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColors.app,
      appBar: AppHeader.onboarding(
        onBack: () => Navigator.pop(context),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.navigate_before_rounded,
                size: 64,
                color: BrandColors.primary,
              ),
              const SizedBox(height: Spacing.xxl),
              Text(
                'Onboarding Header Example',
                style: PicklyTypography.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.lg),
              Text(
                'Features:\n'
                '• Back button only\n'
                '• Minimal design\n'
                '• Perfect for step-by-step flows\n'
                '• Consistent with detail header style',
                style: PicklyTypography.bodyMedium.copyWith(
                  color: TextColors.secondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Run the example app
void main() {
  runApp(const AppHeaderExample());
}
