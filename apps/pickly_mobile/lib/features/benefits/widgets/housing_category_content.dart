import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pickly_design_system/pickly_design_system.dart';
import 'package:pickly_mobile/core/router.dart';
import '../models/policy.dart';
import '../providers/mock_policy_data.dart';

/// Housing category content (주거 카테고리 컨텐츠)
///
/// Displays housing-related policies and benefits with filter tabs
/// Navigates to announcement detail when policy card is tapped
class HousingCategoryContent extends StatefulWidget {
  const HousingCategoryContent({super.key});

  @override
  State<HousingCategoryContent> createState() => _HousingCategoryContentState();
}

class _HousingCategoryContentState extends State<HousingCategoryContent> {
  int _filterIndex = 0; // 0: 등록순, 1: 모집중, 2: 마감

  @override
  Widget build(BuildContext context) {
    final policies = _getFilteredPolicies();

    return Column(
      children: [
        // LH 공고 바로가기 버튼
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push(Routes.housingLh),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.home_work,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'LH 주거 공고 보기',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '한국토지주택공사 분양/임대 정보',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withOpacity(0.8),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Filter tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: Row(
            children: [
              FilterTabBar(
                tabs: const ['등록순', '모집중', '마감'],
                selectedIndex: _filterIndex,
                onTabSelected: (index) {
                  setState(() {
                    _filterIndex = index;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Policy list
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: policies.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final policy = policies[index];
              return PolicyListCard(
                imageUrl: policy.imageUrl,
                title: policy.title,
                organization: policy.organization,
                postedDate: policy.postedDate,
                status: policy.isRecruiting
                    ? RecruitmentStatus.recruiting
                    : RecruitmentStatus.closed,
                onTap: () {
                  // Navigate to announcement detail screen
                  context.go(Routes.announcementDetail(policy.id));
                },
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Get filtered policies based on selected tab
  List<Policy> _getFilteredPolicies() {
    final allPolicies = MockPolicyData.getPoliciesByCategory('housing');

    switch (_filterIndex) {
      case 0: // 등록순 (all policies, sorted by posted date)
        return allPolicies;
      case 1: // 모집중 (recruiting only)
        return allPolicies.where((p) => p.isRecruiting).toList();
      case 2: // 마감 (closed only)
        return allPolicies.where((p) => !p.isRecruiting).toList();
      default:
        return allPolicies;
    }
  }
}
