// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_section.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnnouncementSection _$AnnouncementSectionFromJson(Map<String, dynamic> json) =>
    AnnouncementSection(
      id: json['id'] as String,
      announcementId: json['announcement_id'] as String,
      sectionType: json['section_type'] as String,
      title: json['title'] as String?,
      content: json['content'] as Map<String, dynamic>,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      isVisible: json['is_visible'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$AnnouncementSectionToJson(
  AnnouncementSection instance,
) => <String, dynamic>{
  'id': instance.id,
  'announcement_id': instance.announcementId,
  'section_type': instance.sectionType,
  'title': instance.title,
  'content': instance.content,
  'display_order': instance.displayOrder,
  'is_visible': instance.isVisible,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
