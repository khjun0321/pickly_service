// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Announcement _$AnnouncementFromJson(Map<String, dynamic> json) =>
    _Announcement(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      organization: json['organization'] as String?,
      applicationPeriodStart: json['applicationPeriodStart'] == null
          ? null
          : DateTime.parse(json['applicationPeriodStart'] as String),
      applicationPeriodEnd: json['applicationPeriodEnd'] == null
          ? null
          : DateTime.parse(json['applicationPeriodEnd'] as String),
      announcementDate: json['announcementDate'] == null
          ? null
          : DateTime.parse(json['announcementDate'] as String),
      status:
          $enumDecodeNullable(_$AnnouncementStatusEnumMap, json['status']) ??
          AnnouncementStatus.draft,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isHomeVisible: json['isHomeVisible'] as bool? ?? false,
      displayPriority: (json['displayPriority'] as num?)?.toInt() ?? 0,
      viewsCount: (json['viewsCount'] as num?)?.toInt() ?? 0,
      summary: json['summary'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      externalUrl: json['externalUrl'] as String?,
      externalId: json['externalId'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      customData: json['customData'] as Map<String, dynamic>? ?? const {},
      description: json['description'] as String?,
      content: json['content'] as String?,
      agency: json['agency'] as String?,
      contactInfo: json['contactInfo'] as String?,
      deadline: json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String),
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      bookmarkCount: (json['bookmarkCount'] as num?)?.toInt() ?? 0,
      targetGroups:
          (json['targetGroups'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$AnnouncementToJson(
  _Announcement instance,
) => <String, dynamic>{
  'id': instance.id,
  'categoryId': instance.categoryId,
  'title': instance.title,
  'subtitle': instance.subtitle,
  'organization': instance.organization,
  'applicationPeriodStart': instance.applicationPeriodStart?.toIso8601String(),
  'applicationPeriodEnd': instance.applicationPeriodEnd?.toIso8601String(),
  'announcementDate': instance.announcementDate?.toIso8601String(),
  'status': _$AnnouncementStatusEnumMap[instance.status]!,
  'isFeatured': instance.isFeatured,
  'isHomeVisible': instance.isHomeVisible,
  'displayPriority': instance.displayPriority,
  'viewsCount': instance.viewsCount,
  'summary': instance.summary,
  'thumbnailUrl': instance.thumbnailUrl,
  'externalUrl': instance.externalUrl,
  'externalId': instance.externalId,
  'tags': instance.tags,
  'publishedAt': instance.publishedAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'customData': instance.customData,
  'description': instance.description,
  'content': instance.content,
  'agency': instance.agency,
  'contactInfo': instance.contactInfo,
  'deadline': instance.deadline?.toIso8601String(),
  'displayOrder': instance.displayOrder,
  'bookmarkCount': instance.bookmarkCount,
  'targetGroups': instance.targetGroups,
};

const _$AnnouncementStatusEnumMap = {
  AnnouncementStatus.draft: 'draft',
  AnnouncementStatus.recruiting: 'recruiting',
  AnnouncementStatus.upcoming: 'upcoming',
  AnnouncementStatus.closed: 'closed',
};
