import 'package:flutter/material.dart';
import 'package:pickly_design_system/pickly_design_system.dart';
import '../models/policy.dart';
import '../providers/mock_policy_data.dart';

/// Transportation category content (교통 카테고리 컨텐츠)
///
/// Displays transportation-related policies and benefits with filter tabs
class TransportationCategoryContent extends StatefulWidget {
  const TransportationCategoryContent({super.key});

  @override
  State<TransportationCategoryContent> createState() => _TransportationCategoryContentState();
}

class _TransportationCategoryContentState extends State<TransportationCategoryContent> {
  int _filterIndex = 0; // 0: 등록순, 1: 모집중, 2: 마감

  @override
  Widget build(BuildContext context) {
    final policies = _getFilteredPolicies();

    return Column(
      children: [
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
                  debugPrint('Policy tapped: ${policy.id}');
                  // TODO: Navigate to policy detail page
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
    final allPolicies = MockPolicyData.getPoliciesByCategory('transportation');

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
