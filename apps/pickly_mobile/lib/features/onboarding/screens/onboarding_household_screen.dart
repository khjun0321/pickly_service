import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Onboarding household information screen
///
/// This screen collects household composition information from the user
/// to provide personalized product recommendations.
class OnboardingHouseholdScreen extends StatefulWidget {
  const OnboardingHouseholdScreen({super.key});

  @override
  State<OnboardingHouseholdScreen> createState() => _OnboardingHouseholdScreenState();
}

class _OnboardingHouseholdScreenState extends State<OnboardingHouseholdScreen> {
  // Placeholder for household selection state
  int? _selectedHouseholdSize;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('가구 정보'),
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
                value: 0.33,
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(height: 32),

              // Section title
              Text(
                '가구 구성을 선택해주세요',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                '상품 추천에 활용됩니다',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),

              // Placeholder for household selection UI
              Expanded(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final householdSize = index + 1;
                    final isSelected = _selectedHouseholdSize == householdSize;

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
                          '${householdSize}인 가구',
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
                            : const Icon(Icons.circle_outlined, color: Colors.grey),
                        onTap: () {
                          setState(() {
                            _selectedHouseholdSize = householdSize;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Next button
              ElevatedButton(
                onPressed: _selectedHouseholdSize != null
                    ? () {
                        context.go('/onboarding/region');
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '다음',
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
