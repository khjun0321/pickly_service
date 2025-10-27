// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_tab.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnnouncementTab _$AnnouncementTabFromJson(Map<String, dynamic> json) =>
    AnnouncementTab(
      id: json['id'] as String,
      announcementId: json['announcement_id'] as String,
      tabName: json['tab_name'] as String,
      ageCategoryId: json['age_category_id'] as String?,
      unitType: json['unit_type'] as String?,
      floorPlanImageUrl: json['floor_plan_image_url'] as String?,
      supplyCount: (json['supply_count'] as num?)?.toInt(),
      incomeConditions: json['income_conditions'] as Map<String, dynamic>?,
      additionalInfo: json['additional_info'] as Map<String, dynamic>?,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$AnnouncementTabToJson(AnnouncementTab instance) =>
    <String, dynamic>{
      'id': instance.id,
      'announcement_id': instance.announcementId,
      'tab_name': instance.tabName,
      'age_category_id': instance.ageCategoryId,
      'unit_type': instance.unitType,
      'floor_plan_image_url': instance.floorPlanImageUrl,
      'supply_count': instance.supplyCount,
      'income_conditions': instance.incomeConditions,
      'additional_info': instance.additionalInfo,
      'display_order': instance.displayOrder,
      'created_at': instance.createdAt?.toIso8601String(),
    };
