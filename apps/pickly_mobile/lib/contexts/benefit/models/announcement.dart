/// 혜택 공고 모델 (PRD v7.0 기준)
/// 기본 정보만 포함, 상세 정보는 announcement_sections로 이동
class Announcement {
  final String id;
  final String title;
  final String? subtitle;
  final String? organization;
  final String? categoryId;
  final String? subcategoryId;
  final String? thumbnailUrl;
  final String? externalUrl;
  final String status;
  final bool isFeatured;
  final bool isHomeVisible;
  final int displayPriority;
  final int viewsCount;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Announcement({
    required this.id,
    required this.title,
    this.subtitle,
    this.organization,
    this.categoryId,
    this.subcategoryId,
    this.thumbnailUrl,
    this.externalUrl,
    this.status = 'draft',
    this.isFeatured = false,
    this.isHomeVisible = false,
    this.displayPriority = 0,
    this.viewsCount = 0,
    this.tags = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      organization: json['organization'] as String?,
      categoryId: json['categoryId'] as String? ?? json['category_id'] as String?,
      subcategoryId: json['subcategoryId'] as String? ?? json['subcategory_id'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String? ?? json['thumbnail_url'] as String?,
      externalUrl: json['externalUrl'] as String? ?? json['external_url'] as String?,
      status: json['status'] as String? ?? 'draft',
      isFeatured: json['isFeatured'] as bool? ?? json['is_featured'] as bool? ?? false,
      isHomeVisible: json['isHomeVisible'] as bool? ?? json['is_home_visible'] as bool? ?? false,
      displayPriority: json['displayPriority'] as int? ?? json['display_priority'] as int? ?? 0,
      viewsCount: json['viewsCount'] as int? ?? json['views_count'] as int? ?? 0,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : const [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'organization': organization,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'thumbnailUrl': thumbnailUrl,
      'externalUrl': externalUrl,
      'status': status,
      'isFeatured': isFeatured,
      'isHomeVisible': isHomeVisible,
      'displayPriority': displayPriority,
      'viewsCount': viewsCount,
      'tags': tags,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// 공고 상태 표시용
  String get statusDisplay {
    switch (status) {
      case 'recruiting':
        return '모집중';
      case 'closed':
        return '마감';
      case 'draft':
        return '임시저장';
      default:
        return '알 수 없음';
    }
  }

  /// 모집 중 여부
  bool get isRecruiting => status == 'recruiting';

  /// 마감 여부
  bool get isClosed => status == 'closed';

  /// 날짜 포맷 (YYYY.MM.DD)
  String get formattedDate {
    if (createdAt == null) return '날짜 미정';
    return '${createdAt!.year}.${createdAt!.month.toString().padLeft(2, '0')}.${createdAt!.day.toString().padLeft(2, '0')}';
  }

  /// formattedAnnouncementDate alias (backward compatibility)
  String get formattedAnnouncementDate => formattedDate;

  Announcement copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? organization,
    String? categoryId,
    String? subcategoryId,
    String? thumbnailUrl,
    String? externalUrl,
    String? status,
    bool? isFeatured,
    bool? isHomeVisible,
    int? displayPriority,
    int? viewsCount,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      organization: organization ?? this.organization,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      externalUrl: externalUrl ?? this.externalUrl,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      isHomeVisible: isHomeVisible ?? this.isHomeVisible,
      displayPriority: displayPriority ?? this.displayPriority,
      viewsCount: viewsCount ?? this.viewsCount,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
