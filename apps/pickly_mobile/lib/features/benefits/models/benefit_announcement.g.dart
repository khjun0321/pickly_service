// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'benefit_announcement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BenefitAnnouncement _$BenefitAnnouncementFromJson(Map<String, dynamic> json) =>
    _BenefitAnnouncement(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      benefitDetailId: json['benefit_detail_id'] as String?,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      organization: json['organization'] as String,
      applicationPeriodStart: json['application_period_start'] == null
          ? null
          : DateTime.parse(json['application_period_start'] as String),
      applicationPeriodEnd: json['application_period_end'] == null
          ? null
          : DateTime.parse(json['application_period_end'] as String),
      announcementDate: json['announcement_date'] == null
          ? null
          : DateTime.parse(json['announcement_date'] as String),
      status: json['status'] as String? ?? 'draft',
      isFeatured: json['is_featured'] as bool? ?? false,
      viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
      summary: json['summary'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      externalUrl: json['external_url'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      publishedAt: json['published_at'] == null
          ? null
          : DateTime.parse(json['published_at'] as String),
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      customData: json['custom_data'] as Map<String, dynamic>?,
      content: json['content'] as String?,
    );

Map<String, dynamic> _$BenefitAnnouncementToJson(
  _BenefitAnnouncement instance,
) => <String, dynamic>{
  'id': instance.id,
  'category_id': instance.categoryId,
  'benefit_detail_id': instance.benefitDetailId,
  'title': instance.title,
  'subtitle': instance.subtitle,
  'organization': instance.organization,
  'application_period_start': instance.applicationPeriodStart
      ?.toIso8601String(),
  'application_period_end': instance.applicationPeriodEnd?.toIso8601String(),
  'announcement_date': instance.announcementDate?.toIso8601String(),
  'status': instance.status,
  'is_featured': instance.isFeatured,
  'views_count': instance.viewsCount,
  'summary': instance.summary,
  'thumbnail_url': instance.thumbnailUrl,
  'external_url': instance.externalUrl,
  'tags': instance.tags,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'published_at': instance.publishedAt?.toIso8601String(),
  'display_order': instance.displayOrder,
  'custom_data': instance.customData,
  'content': instance.content,
};
