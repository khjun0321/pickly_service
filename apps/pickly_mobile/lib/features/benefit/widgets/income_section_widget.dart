import 'package:flutter/material.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

/// 소득 기준 섹션 위젯
///
/// 공고 상세 화면에서 소득 기준을 특별한 디자인으로 표시합니다.
/// - 그라데이션 배경 (녹색)
/// - detail 필드 강조
/// - 안내 문구 자동 표시
class IncomeSectionWidget extends StatelessWidget {
  final String? description;
  final List<IncomeField> fields;

  const IncomeSectionWidget({
    super.key,
    this.description,
    required this.fields,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green[50]!,
            Colors.green[100]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: PicklyBorderRadius.radiusXl,
        border: Border.all(color: Colors.green[300]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.attach_money,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '소득 기준',
                      style: PicklyTypography.titleSmall.copyWith(
                        color: TextColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (description != null)
                      Text(
                        description!,
                        style: PicklyTypography.captionSmall.copyWith(
                          color: TextColors.secondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 소득 기준 필드들
          ...fields.map((field) => _buildIncomeField(context, field)),

          // 안내 문구
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange[200]!, width: 1.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.orange[700], size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '소득 기준은 전년도 도시근로자 가구당 월평균 소득을 기준으로 하며, 가구원 수에 따라 달라질 수 있습니다.',
                    style: PicklyTypography.captionSmall.copyWith(
                      color: Colors.orange[900],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeField(BuildContext context, IncomeField field) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 필드 라벨
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                field.label,
                style: PicklyTypography.captionMidium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: TextColors.secondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 필드 값
          Text(
            field.value,
            style: PicklyTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: TextColors.primary,
              height: 1.4,
            ),
          ),

          // 상세 정보
          if (field.detail != null && field.detail!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!, width: 1),
              ),
              child: Text(
                field.detail!,
                style: PicklyTypography.captionSmall.copyWith(
                  color: Colors.green[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 소득 필드 모델
class IncomeField {
  final String label;
  final String value;
  final String? detail;

  const IncomeField({
    required this.label,
    required this.value,
    this.detail,
  });
}
