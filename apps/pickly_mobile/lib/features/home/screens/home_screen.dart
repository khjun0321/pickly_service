import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickly_design_system/pickly_design_system.dart';
import 'package:pickly_mobile/features/onboarding/providers/onboarding_storage_provider.dart';

/// Home screen - Main policy feed
///
/// Displays personalized policy recommendations based on user's
/// age category and region selections from onboarding.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(onboardingStorageServiceProvider);
    final ageCategoryId = storage.getSelectedAgeCategoryId();
    final regionIds = storage.getSelectedRegionIds();

    return Scaffold(
      backgroundColor: BackgroundColors.app,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            AppHeader.home(
              onMenuTap: () {
                // TODO: Open menu drawer
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('메뉴 기능 준비 중')),
                );
              },
            ),

            const SizedBox(height: 24),

            // Welcome message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '맞춤 정책',
                    style: PicklyTypography.titleLarge.copyWith(
                      color: TextColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '나에게 맞는 혜택을 확인하세요',
                    style: PicklyTypography.bodyMedium.copyWith(
                      color: TextColors.secondary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Filter status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '현재 필터 설정',
                      style: PicklyTypography.titleMedium.copyWith(
                        color: TextColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 20,
                          color: BrandColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '연령대: ${ageCategoryId ?? "미설정"}',
                          style: PicklyTypography.bodyMedium.copyWith(
                            color: TextColors.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 20,
                          color: BrandColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '지역: ${regionIds.isEmpty ? "미설정" : regionIds.join(", ")}',
                            style: PicklyTypography.bodyMedium.copyWith(
                              color: TextColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Policies list (placeholder)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: TextColors.tertiary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '정책 목록을 준비 중입니다',
                      style: PicklyTypography.bodyLarge.copyWith(
                        color: TextColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '곧 맞춤 정책을 추천해드릴게요!',
                      style: PicklyTypography.bodyMedium.copyWith(
                        color: TextColors.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
