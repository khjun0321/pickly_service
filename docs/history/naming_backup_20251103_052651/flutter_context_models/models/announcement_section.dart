import 'package:json_annotation/json_annotation.dart';

part 'announcement_section.g.dart';

/// 공고 섹션 모델 (모듈식 구성)
/// PRD v7.0 기준: announcement_sections 테이블
@JsonSerializable(fieldRename: FieldRename.snake)
class AnnouncementSection {
  final String id;

  @JsonKey(name: 'announcement_id')
  final String announcementId;

  @JsonKey(name: 'section_type')
  final String sectionType;

  final String? title;

  final Map<String, dynamic> content;

  @JsonKey(name: 'display_order', defaultValue: 0)
  final int displayOrder;

  @JsonKey(name: 'is_visible', defaultValue: true)
  final bool isVisible;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const AnnouncementSection({
    required this.id,
    required this.announcementId,
    required this.sectionType,
    this.title,
    required this.content,
    this.displayOrder = 0,
    this.isVisible = true,
    this.createdAt,
    this.updatedAt,
  });

  factory AnnouncementSection.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementSectionFromJson(json);

  Map<String, dynamic> toJson() => _$AnnouncementSectionToJson(this);

  /// 섹션 타입 표시용
  String get sectionTypeDisplay {
    switch (sectionType) {
      case 'basic_info':
        return '기본 정보';
      case 'schedule':
        return '일정';
      case 'eligibility':
        return '신청 자격';
      case 'housing_info':
        return '단지 정보';
      case 'location':
        return '위치';
      case 'attachments':
        return '첨부 파일';
      default:
        return sectionType;
    }
  }

  /// 이미지 URL 리스트 (content에서 추출)
  List<String> get imageUrls {
    final images = content['images'];
    if (images is List) {
      return images.whereType<String>().toList();
    }
    return [];
  }

  /// PDF URL 리스트 (content에서 추출)
  List<String> get pdfUrls {
    final pdfs = content['pdfs'];
    if (pdfs is List) {
      return pdfs.whereType<String>().toList();
    }
    return [];
  }

  AnnouncementSection copyWith({
    String? id,
    String? announcementId,
    String? sectionType,
    String? title,
    Map<String, dynamic>? content,
    int? displayOrder,
    bool? isVisible,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnnouncementSection(
      id: id ?? this.id,
      announcementId: announcementId ?? this.announcementId,
      sectionType: sectionType ?? this.sectionType,
      title: title ?? this.title,
      content: content ?? this.content,
      displayOrder: displayOrder ?? this.displayOrder,
      isVisible: isVisible ?? this.isVisible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
