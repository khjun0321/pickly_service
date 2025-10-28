// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'benefit_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BenefitDetail _$BenefitDetailFromJson(Map<String, dynamic> json) =>
    _BenefitDetail(
      id: json['id'] as String,
      benefitCategoryId: json['benefit_category_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$BenefitDetailToJson(_BenefitDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'benefit_category_id': instance.benefitCategoryId,
      'title': instance.title,
      'description': instance.description,
      'icon_url': instance.iconUrl,
      'sort_order': instance.sortOrder,
      'is_active': instance.isActive,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
