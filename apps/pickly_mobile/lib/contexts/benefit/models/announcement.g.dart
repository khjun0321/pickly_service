// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Announcement _$AnnouncementFromJson(Map<String, dynamic> json) => Announcement(
  id: json['id'] as String,
  title: json['title'] as String,
  subtitle: json['subtitle'] as String?,
  organization: json['organization'] as String?,
  typeId: json['type_id'] as String?,
  thumbnailUrl: json['thumbnail_url'] as String?,
  externalUrl: json['external_url'] as String?,
  status: json['status'] as String? ?? 'draft',
  isFeatured: json['is_featured'] as bool? ?? false,
  isHomeVisible: json['is_home_visible'] as bool? ?? false,
  sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
  viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$AnnouncementToJson(Announcement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'organization': instance.organization,
      'type_id': instance.typeId,
      'thumbnail_url': instance.thumbnailUrl,
      'external_url': instance.externalUrl,
      'status': instance.status,
      'is_featured': instance.isFeatured,
      'is_home_visible': instance.isHomeVisible,
      'sort_order': instance.sortOrder,
      'views_count': instance.viewsCount,
      'tags': instance.tags,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
