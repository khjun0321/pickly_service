import 'package:flutter/material.dart';

/// Main filter/home screen - Primary app screen after onboarding
///
/// This screen serves as the main interface for Pickly, where users can
/// browse and filter products based on their preferences.
class FilterHomeScreen extends StatefulWidget {
  const FilterHomeScreen({super.key});

  @override
  State<FilterHomeScreen> createState() => _FilterHomeScreenState();
}

class _FilterHomeScreenState extends State<FilterHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pickly'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings screen
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Placeholder icon
              Icon(
                Icons.shopping_cart,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),

              // Placeholder text
              Text(
                '메인 화면',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),

              // Additional info
              Text(
                '상품 필터링 기능이 곧 추가됩니다',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_list),
            label: '필터',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
        onTap: (index) {
          // TODO: Handle navigation between tabs
        },
      ),
    );
  }
}
