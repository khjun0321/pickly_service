import 'package:json_annotation/json_annotation.dart';

part 'announcement.g.dart';

/// 혜택 공고 모델 (PRD v7.0 기준)
/// 기본 정보만 포함, 상세 정보는 announcement_sections로 이동
@JsonSerializable(fieldRename: FieldRename.snake)
class Announcement {
  final String id;
  final String title;
  final String? subtitle;
  final String? organization;

  @JsonKey(name: 'type_id')
  final String? typeId;

  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;

  @JsonKey(name: 'external_url')
  final String? externalUrl;

  @JsonKey(defaultValue: 'draft')
  final String status;

  @JsonKey(name: 'is_featured', defaultValue: false)
  final bool isFeatured;

  @JsonKey(name: 'is_home_visible', defaultValue: false)
  final bool isHomeVisible;

  @JsonKey(name: 'sort_order', defaultValue: 0)
  final int sortOrder;

  @JsonKey(name: 'views_count', defaultValue: 0)
  final int viewsCount;

  @JsonKey(defaultValue: [])
  final List<String> tags;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const Announcement({
    required this.id,
    required this.title,
    this.subtitle,
    this.organization,
    this.typeId,
    this.thumbnailUrl,
    this.externalUrl,
    this.status = 'draft',
    this.isFeatured = false,
    this.isHomeVisible = false,
    this.sortOrder = 0,
    this.viewsCount = 0,
    this.tags = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementFromJson(json);

  Map<String, dynamic> toJson() => _$AnnouncementToJson(this);

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

  /// 썸네일 또는 기본 이미지
  String get thumbnailOrDefault =>
      thumbnailUrl ?? 'https://via.placeholder.com/400x200?text=No+Image';

  Announcement copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? organization,
    String? typeId,
    String? thumbnailUrl,
    String? externalUrl,
    String? status,
    bool? isFeatured,
    bool? isHomeVisible,
    int? sortOrder,
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
      typeId: typeId ?? this.typeId,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      externalUrl: externalUrl ?? this.externalUrl,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      isHomeVisible: isHomeVisible ?? this.isHomeVisible,
      sortOrder: sortOrder ?? this.sortOrder,
      viewsCount: viewsCount ?? this.viewsCount,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
