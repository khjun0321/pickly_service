import 'package:freezed_annotation/freezed_annotation.dart';

part 'benefit_category.freezed.dart';
part 'benefit_category.g.dart';

@freezed
class BenefitCategory with _$BenefitCategory {
  const factory BenefitCategory({
    required String id,
    @JsonKey(name: 'title') required String title,
    required String slug,
    String? description,
    @JsonKey(name: 'icon_url') String? iconUrl,
    @JsonKey(name: 'banner_image_url') String? bannerImageUrl,
    @JsonKey(name: 'banner_link_url') String? bannerLinkUrl,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
  }) = _BenefitCategory;

  factory BenefitCategory.fromJson(Map<String, dynamic> json) =>
      _$BenefitCategoryFromJson(json);
}
