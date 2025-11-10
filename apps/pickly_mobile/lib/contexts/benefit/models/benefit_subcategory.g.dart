// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'benefit_subcategory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BenefitSubcategory _$BenefitSubcategoryFromJson(Map<String, dynamic> json) =>
    BenefitSubcategory(
      id: json['id'] as String,
      categoryId: json['category_id'] as String?,
      name: json['name'] as String,
      slug: json['slug'] as String,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      iconUrl: json['icon_url'] as String?,
      iconName: json['icon_name'] as String?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$BenefitSubcategoryToJson(BenefitSubcategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category_id': instance.categoryId,
      'name': instance.name,
      'slug': instance.slug,
      'sort_order': instance.sortOrder,
      'is_active': instance.isActive,
      'icon_url': instance.iconUrl,
      'icon_name': instance.iconName,
      'description': instance.description,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
