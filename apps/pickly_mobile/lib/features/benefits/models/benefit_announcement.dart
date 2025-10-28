/// Benefit Announcement Model (v9.0)
///
/// Represents individual benefit announcements linked to policies
/// Synced with Admin via Supabase benefit_announcements table
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'benefit_announcement.freezed.dart';
part 'benefit_announcement.g.dart';

@freezed
class BenefitAnnouncement with _$BenefitAnnouncement {
  const factory BenefitAnnouncement({
    required String id,
    @JsonKey(name: 'category_id') required String categoryId,
    @JsonKey(name: 'benefit_detail_id') String? benefitDetailId,
    required String title,
    String? subtitle,
    required String organization,
    @JsonKey(name: 'application_period_start') DateTime? applicationPeriodStart,
    @JsonKey(name: 'application_period_end') DateTime? applicationPeriodEnd,
    @JsonKey(name: 'announcement_date') DateTime? announcementDate,
    @Default('draft') String status,
    @JsonKey(name: 'is_featured') @Default(false) bool isFeatured,
    @JsonKey(name: 'views_count') @Default(0) int viewsCount,
    String? summary,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'external_url') String? externalUrl,
    @Default([]) List<String> tags,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'published_at') DateTime? publishedAt,
    @JsonKey(name: 'display_order') @Default(0) int displayOrder,
    @JsonKey(name: 'custom_data') Map<String, dynamic>? customData,
    String? content,
  }) = _BenefitAnnouncement;

  factory BenefitAnnouncement.fromJson(Map<String, dynamic> json) =>
      _$BenefitAnnouncementFromJson(json);
}

/// Extension for BenefitAnnouncement helper methods
extension BenefitAnnouncementX on BenefitAnnouncement {
  /// Get formatted status display text
  String get statusDisplay {
    switch (status) {
      case 'published':
        return '게시됨';
      case 'draft':
        return '임시저장';
      case 'archived':
        return '보관됨';
      default:
        return status;
    }
  }

  /// Check if announcement is published
  bool get isPublished => status == 'published';

  /// Check if announcement is in draft
  bool get isDraft => status == 'draft';

  /// Check if announcement is archived
  bool get isArchived => status == 'archived';

  /// Get application period status
  String get applicationPeriodStatus {
    final now = DateTime.now();

    if (applicationPeriodStart == null || applicationPeriodEnd == null) {
      return '기간 미정';
    }

    if (now.isBefore(applicationPeriodStart!)) {
      return '신청 예정';
    } else if (now.isAfter(applicationPeriodEnd!)) {
      return '신청 마감';
    } else {
      return '신청 가능';
    }
  }

  /// Check if application is open
  bool get isApplicationOpen {
    final now = DateTime.now();
    if (applicationPeriodStart == null || applicationPeriodEnd == null) {
      return false;
    }
    return now.isAfter(applicationPeriodStart!) && now.isBefore(applicationPeriodEnd!);
  }

  /// Format date range for display
  String get formattedApplicationPeriod {
    if (applicationPeriodStart == null || applicationPeriodEnd == null) {
      return '기간 미정';
    }

    final start = applicationPeriodStart!;
    final end = applicationPeriodEnd!;

    return '${start.year}.${start.month.toString().padLeft(2, '0')}.${start.day.toString().padLeft(2, '0')} - '
           '${end.year}.${end.month.toString().padLeft(2, '0')}.${end.day.toString().padLeft(2, '0')}';
  }

  /// Get thumbnail or default placeholder
  String get thumbnailOrDefault =>
      thumbnailUrl ?? 'https://via.placeholder.com/400x200?text=No+Image';
}
