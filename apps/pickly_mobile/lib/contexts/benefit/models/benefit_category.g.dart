// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'benefit_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BenefitCategory _$BenefitCategoryFromJson(Map<String, dynamic> json) =>
    _BenefitCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      iconUrl: json['iconUrl'] as String?,
      bannerImageUrl: json['bannerImageUrl'] as String?,
      bannerLinkUrl: json['bannerLinkUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$BenefitCategoryToJson(_BenefitCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'iconUrl': instance.iconUrl,
      'bannerImageUrl': instance.bannerImageUrl,
      'bannerLinkUrl': instance.bannerLinkUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isActive': instance.isActive,
      'displayOrder': instance.displayOrder,
    };
