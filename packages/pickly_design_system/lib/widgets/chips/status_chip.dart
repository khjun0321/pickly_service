import 'package:flutter/material.dart';

/// Recruitment status types for policies
enum RecruitmentStatus {
  /// 모집중 (Recruiting)
  recruiting,

  /// 마감 (Closed)
  closed,
}

/// Status chip widget for displaying recruitment status
///
/// Shows either "모집중" (recruiting) or "마감" (closed) status
/// with appropriate colors and styling.
///
/// Example:
/// ```dart
/// StatusChip(status: RecruitmentStatus.recruiting)
/// StatusChip(status: RecruitmentStatus.closed)
/// ```
class StatusChip extends StatelessWidget {
  /// The recruitment status to display
  final RecruitmentStatus status;

  const StatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: ShapeDecoration(
        color: config.backgroundColor,
        shape: RoundedRectangleBorder(
          side: config.borderColor != null
              ? BorderSide(
                  width: 1,
                  color: config.borderColor!,
                )
              : BorderSide.none,
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            config.label,
            style: TextStyle(
              color: config.textColor,
              fontSize: 12,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
              height: 1.50,
            ),
          ),
        ],
      ),
    );
  }

  /// Get status configuration based on status type
  _StatusConfig _getStatusConfig(RecruitmentStatus status) {
    switch (status) {
      case RecruitmentStatus.recruiting:
        return _StatusConfig(
          label: '모집중',
          backgroundColor: const Color(0xFFC6ECFF),
          textColor: const Color(0xFF5090FF),
          borderColor: null,
        );
      case RecruitmentStatus.closed:
        return _StatusConfig(
          label: '마감',
          backgroundColor: const Color(0xFFDDDDDD),
          textColor: Colors.white,
          borderColor: const Color(0xFFDDDDDD),
        );
    }
  }
}

/// Internal configuration class for status styling
class _StatusConfig {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  _StatusConfig({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });
}
