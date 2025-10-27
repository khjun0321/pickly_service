/// Benefit announcement model
/// Represents housing and other benefit announcements from various organizations
class BenefitAnnouncement {
  final String id;
  final String categoryId;
  final String title;
  final String? subtitle;
  final String organization;
  final DateTime? applicationPeriodStart;
  final DateTime? applicationPeriodEnd;
  final DateTime? announcementDate;
  final String status; // 'draft', 'published', 'closed', 'archived'
  final bool isFeatured;
  final int viewsCount;
  final String? summary;
  final String? thumbnailUrl;
  final String? externalUrl;
  final List<String>? tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BenefitAnnouncement({
    required this.id,
    required this.categoryId,
    required this.title,
    this.subtitle,
    required this.organization,
    this.applicationPeriodStart,
    this.applicationPeriodEnd,
    this.announcementDate,
    required this.status,
    this.isFeatured = false,
    this.viewsCount = 0,
    this.summary,
    this.thumbnailUrl,
    this.externalUrl,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BenefitAnnouncement.fromJson(Map<String, dynamic> json) {
    return BenefitAnnouncement(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      organization: json['organization'] as String,
      applicationPeriodStart: json['application_period_start'] != null
          ? DateTime.parse(json['application_period_start'] as String)
          : null,
      applicationPeriodEnd: json['application_period_end'] != null
          ? DateTime.parse(json['application_period_end'] as String)
          : null,
      announcementDate: json['announcement_date'] != null
          ? DateTime.parse(json['announcement_date'] as String)
          : null,
      status: json['status'] as String? ?? 'draft',
      isFeatured: json['is_featured'] as bool? ?? false,
      viewsCount: json['views_count'] as int? ?? 0,
      summary: json['summary'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      externalUrl: json['external_url'] as String?,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'title': title,
      'subtitle': subtitle,
      'organization': organization,
      'application_period_start': applicationPeriodStart?.toIso8601String(),
      'application_period_end': applicationPeriodEnd?.toIso8601String(),
      'announcement_date': announcementDate?.toIso8601String(),
      'status': status,
      'is_featured': isFeatured,
      'views_count': viewsCount,
      'summary': summary,
      'thumbnail_url': thumbnailUrl,
      'external_url': externalUrl,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Check if announcement is currently recruiting
  bool get isRecruiting {
    if (status != 'published') return false;
    if (applicationPeriodStart == null || applicationPeriodEnd == null) {
      return false;
    }

    final now = DateTime.now();
    return now.isAfter(applicationPeriodStart!) &&
           now.isBefore(applicationPeriodEnd!.add(const Duration(days: 1)));
  }

  /// Check if announcement is closed
  bool get isClosed {
    if (status == 'closed' || status == 'archived') return true;
    if (applicationPeriodEnd == null) return false;

    return DateTime.now().isAfter(applicationPeriodEnd!);
  }

  /// Format announcement date for display
  String get formattedAnnouncementDate {
    if (announcementDate == null) return '';
    return '${announcementDate!.year}.${announcementDate!.month.toString().padLeft(2, '0')}.${announcementDate!.day.toString().padLeft(2, '0')}';
  }

  BenefitAnnouncement copyWith({
    String? id,
    String? categoryId,
    String? title,
    String? subtitle,
    String? organization,
    DateTime? applicationPeriodStart,
    DateTime? applicationPeriodEnd,
    DateTime? announcementDate,
    String? status,
    bool? isFeatured,
    int? viewsCount,
    String? summary,
    String? thumbnailUrl,
    String? externalUrl,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BenefitAnnouncement(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      organization: organization ?? this.organization,
      applicationPeriodStart: applicationPeriodStart ?? this.applicationPeriodStart,
      applicationPeriodEnd: applicationPeriodEnd ?? this.applicationPeriodEnd,
      announcementDate: announcementDate ?? this.announcementDate,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      viewsCount: viewsCount ?? this.viewsCount,
      summary: summary ?? this.summary,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      externalUrl: externalUrl ?? this.externalUrl,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
