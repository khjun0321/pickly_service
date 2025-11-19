// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'benefit_program.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BenefitProgram _$BenefitProgramFromJson(Map<String, dynamic> json) =>
    _BenefitProgram(
      id: json['id'] as String,
      benefitCategoryId: json['benefitCategoryId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      iconUrl: json['iconUrl'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$BenefitProgramToJson(_BenefitProgram instance) =>
    <String, dynamic>{
      'id': instance.id,
      'benefitCategoryId': instance.benefitCategoryId,
      'title': instance.title,
      'description': instance.description,
      'iconUrl': instance.iconUrl,
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
