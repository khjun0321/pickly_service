// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'benefit_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BenefitCategory _$BenefitCategoryFromJson(Map<String, dynamic> json) =>
    _BenefitCategory(
      id: json['id'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
      bannerImageUrl: json['banner_image_url'] as String?,
      bannerLinkUrl: json['banner_link_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$BenefitCategoryToJson(_BenefitCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'slug': instance.slug,
      'description': instance.description,
      'icon_url': instance.iconUrl,
      'banner_image_url': instance.bannerImageUrl,
      'banner_link_url': instance.bannerLinkUrl,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'is_active': instance.isActive,
      'sort_order': instance.sortOrder,
    };
