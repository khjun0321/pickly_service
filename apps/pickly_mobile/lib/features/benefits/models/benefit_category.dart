/// Benefit Category Model (v9.0)
///
/// Represents top-level benefit categories (주거, 복지, 교육, 교통 등)
/// Synced with Admin via Supabase benefit_categories table
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'benefit_category.freezed.dart';
part 'benefit_category.g.dart';

@freezed
class BenefitCategory with _$BenefitCategory {
  const factory BenefitCategory({
    required String id,
    required String title,
    required String slug,
    String? description,
    @JsonKey(name: 'icon_url') String? iconUrl,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'custom_fields') Map<String, dynamic>? customFields,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _BenefitCategory;

  factory BenefitCategory.fromJson(Map<String, dynamic> json) =>
      _$BenefitCategoryFromJson(json);
}
