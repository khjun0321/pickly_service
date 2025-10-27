import 'package:flutter/material.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

/// Example usage of StatusChip widget
class StatusChipExample extends StatelessWidget {
  const StatusChipExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Chip Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recruitment Status Chips',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),

            // Recruiting status
            const Row(
              children: [
                StatusChip(status: RecruitmentStatus.recruiting),
                SizedBox(width: 8),
                Text('모집중 상태'),
              ],
            ),
            const SizedBox(height: 16),

            // Closed status
            const Row(
              children: [
                StatusChip(status: RecruitmentStatus.closed),
                SizedBox(width: 8),
                Text('마감 상태'),
              ],
            ),
            const SizedBox(height: 32),

            // Example in a card context
            const Text(
              'In Card Context',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              width: 88,
              height: 100,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xFF9747FF),
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Stack(
                children: [
                  Positioned(
                    left: 11,
                    top: 20,
                    child: StatusChip(status: RecruitmentStatus.recruiting),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              width: 88,
              height: 100,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xFFDDDDDD),
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Stack(
                children: [
                  Positioned(
                    left: 10,
                    top: 56,
                    child: StatusChip(status: RecruitmentStatus.closed),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
