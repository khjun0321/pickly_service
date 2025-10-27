import 'package:freezed_annotation/freezed_annotation.dart';

part 'benefit_category.freezed.dart';
part 'benefit_category.g.dart';

@freezed
class BenefitCategory with _$BenefitCategory {
  const factory BenefitCategory({
    required String id,
    required String name,
    required String slug,
    String? description,
    String? iconUrl,
    String? bannerImageUrl,
    String? bannerLinkUrl,
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default(true) bool isActive,
    @Default(0) int displayOrder,
  }) = _BenefitCategory;

  factory BenefitCategory.fromJson(Map<String, dynamic> json) =>
      _$BenefitCategoryFromJson(json);
}
