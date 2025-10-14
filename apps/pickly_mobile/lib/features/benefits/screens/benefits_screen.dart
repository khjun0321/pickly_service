import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pickly_design_system/pickly_design_system.dart';
import 'package:pickly_mobile/core/router.dart';
import 'package:pickly_mobile/features/onboarding/providers/onboarding_storage_provider.dart';

/// Benefits screen (혜택 화면)
///
/// Displays available benefits and promotions for users
class BenefitsScreen extends ConsumerWidget {
  const BenefitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(onboardingStorageServiceProvider);
    final ageCategoryId = storage.getSelectedAgeCategoryId();
    final regionIds = storage.getSelectedRegionIds();
    return Scaffold(
      backgroundColor: BackgroundColors.app,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            AppHeader.home(
              onMenuTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('메뉴 기능 준비 중')),
                );
              },
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

            // Content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.card_giftcard,
                      size: 64,
                      color: BrandColors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '혜택 목록',
                      style: PicklyTypography.titleLarge.copyWith(
                        color: TextColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '다양한 혜택과 프로모션을 준비 중입니다',
                      style: PicklyTypography.bodyMedium.copyWith(
                        color: TextColors.secondary,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: PicklyBottomNavigationBar(
        currentIndex: 1, // Benefits is active
        items: PicklyNavigationItems.defaults,
        onTap: (index) {
          switch (index) {
            case 0:
              // Navigate to home
              context.go(Routes.home);
              break;
            case 1:
              // Already on benefits screen
              break;
            case 2:
              // TODO: Navigate to calendar
              break;
            case 3:
              // TODO: Navigate to AI
              break;
            case 4:
              // TODO: Navigate to my page
              break;
          }
        },
      ),
    );
  }
}
