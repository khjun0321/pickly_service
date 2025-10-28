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
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      parentId: json['parent_id'] as String?,
      customFields: json['custom_fields'] as Map<String, dynamic>?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$BenefitCategoryToJson(_BenefitCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'slug': instance.slug,
      'description': instance.description,
      'icon_url': instance.iconUrl,
      'sort_order': instance.sortOrder,
      'is_active': instance.isActive,
      'parent_id': instance.parentId,
      'custom_fields': instance.customFields,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
