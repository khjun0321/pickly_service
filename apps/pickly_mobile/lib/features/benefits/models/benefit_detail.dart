/// Benefit Detail Model (v9.0)
///
/// Represents policy/program details under a category
/// Example: 행복주택, 국민임대주택, 영구임대주택 under 주거 category
/// Synced with Admin via Supabase benefit_details table
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'benefit_detail.freezed.dart';
part 'benefit_detail.g.dart';

@freezed
class BenefitDetail with _$BenefitDetail {
  const factory BenefitDetail({
    required String id,
    @JsonKey(name: 'benefit_category_id') required String benefitCategoryId,
    required String title,
    String? description,
    @JsonKey(name: 'icon_url') String? iconUrl,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _BenefitDetail;

  factory BenefitDetail.fromJson(Map<String, dynamic> json) =>
      _$BenefitDetailFromJson(json);
}
