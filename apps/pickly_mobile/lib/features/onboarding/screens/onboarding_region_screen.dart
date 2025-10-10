import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding region selection screen
///
/// This screen allows users to select their region for location-based
/// product recommendations and completes the onboarding process.
class OnboardingRegionScreen extends StatefulWidget {
  const OnboardingRegionScreen({super.key});

  @override
  State<OnboardingRegionScreen> createState() => _OnboardingRegionScreenState();
}

class _OnboardingRegionScreenState extends State<OnboardingRegionScreen> {
  // Placeholder for region selection state
  String? _selectedRegion;

  // Sample regions
  final List<String> _regions = [
    '서울특별시',
    '부산광역시',
    '대구광역시',
    '인천광역시',
    '광주광역시',
    '대전광역시',
    '울산광역시',
    '세종특별자치시',
    '경기도',
    '강원도',
    '충청북도',
    '충청남도',
    '전라북도',
    '전라남도',
    '경상북도',
    '경상남도',
    '제주특별자치도',
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstRun', false);

    if (mounted) {
      context.go('/filter');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('지역 선택'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: 0.66,
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(height: 32),

              // Section title
              Text(
                '거주 지역을 선택해주세요',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                '지역별 맞춤 상품을 추천해드립니다',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),

              // Placeholder for region selection UI
              Expanded(
                child: ListView.builder(
                  itemCount: _regions.length,
                  itemBuilder: (context, index) {
                    final region = _regions[index];
                    final isSelected = _selectedRegion == region;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: isSelected ? 4 : 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          region,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
                            : const Icon(Icons.circle_outlined, color: Colors.grey),
                        onTap: () {
                          setState(() {
                            _selectedRegion = region;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Complete onboarding button
              ElevatedButton(
                onPressed: _selectedRegion != null ? _completeOnboarding : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '완료',
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
