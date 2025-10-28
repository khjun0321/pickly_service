/// Benefit Program Model (v8.0)
///
/// Represents a program type/category for benefit announcements.
/// Replaces the old "announcement_types" concept with "programs".
/// Used in benefit screens to filter announcements by program type.
///
/// Example: "청년", "신혼부부", "고령자" for housing category
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'benefit_program.freezed.dart';
part 'benefit_program.g.dart';

@freezed
class BenefitProgram with _$BenefitProgram {
  const factory BenefitProgram({
    required String id,
    required String benefitCategoryId,
    required String title,
    String? description,
    String? iconUrl,
    @Default(0) int sortOrder,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _BenefitProgram;

  factory BenefitProgram.fromJson(Map<String, dynamic> json) =>
      _$BenefitProgramFromJson(json);
}
