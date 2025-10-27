import 'package:flutter/material.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

/// Example usage of FilterTab widgets
class FilterTabExample extends StatefulWidget {
  const FilterTabExample({super.key});

  @override
  State<FilterTabExample> createState() => _FilterTabExampleState();
}

class _FilterTabExampleState extends State<FilterTabExample> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Tab Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Individual Filter Tabs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            // Individual tabs
            Row(
              children: [
                FilterTab(
                  label: '등록순',
                  isSelected: _selectedIndex == 0,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                ),
                FilterTab(
                  label: '모집중',
                  isSelected: _selectedIndex == 1,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                ),
                FilterTab(
                  label: '마감',
                  isSelected: _selectedIndex == 2,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            const Text(
              'Filter Tab Bar (Simplified)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            // Using FilterTabBar
            FilterTabBar(
              tabs: const ['등록순', '모집중', '마감'],
              selectedIndex: _selectedIndex,
              onTabSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),

            const SizedBox(height: 32),

            // Display selected tab content
            Text(
              'Selected: ${['등록순', '모집중', '마감'][_selectedIndex]}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF27B473),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
