/// Supabase announcements 테이블의 housing_types JSONB 구조를 위한 모델

/// 필드 모델
class AnnouncementField {
  final String key;
  final String label;
  final String value;
  final String? detail; // ← 소득 기준에서 사용
  final bool visible;
  final int order;

  const AnnouncementField({
    required this.key,
    required this.label,
    required this.value,
    this.detail,
    required this.visible,
    required this.order,
  });

  factory AnnouncementField.fromJson(Map<String, dynamic> json) {
    return AnnouncementField(
      key: json['key'] as String,
      label: json['label'] as String,
      value: json['value'] as String? ?? '',
      detail: json['detail'] as String?,
      visible: json['visible'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
    );
  }
}

/// 섹션 모델
class AnnouncementSection {
  final String type;
  final String? title;
  final String? icon;
  final String? description; // ← 소득 기준 설명
  final bool enabled;
  final int order;
  final List<AnnouncementField> fields;

  const AnnouncementSection({
    required this.type,
    this.title,
    this.icon,
    this.description,
    required this.enabled,
    required this.order,
    required this.fields,
  });

  factory AnnouncementSection.fromJson(Map<String, dynamic> json) {
    return AnnouncementSection(
      type: json['type'] as String,
      title: json['title'] as String?,
      icon: json['icon'] as String?,
      description: json['description'] as String?,
      enabled: json['enabled'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
      fields: (json['fields'] as List<dynamic>?)
              ?.map((f) => AnnouncementField.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// 평형 타입 모델
class HousingType {
  final String id;
  final int area;
  final String areaLabel;
  final String type;
  final String targetGroup;
  final String tabLabel;
  final int order;
  final String floorPlanImage;
  final List<AnnouncementSection> sections;

  const HousingType({
    required this.id,
    required this.area,
    required this.areaLabel,
    required this.type,
    required this.targetGroup,
    required this.tabLabel,
    required this.order,
    required this.floorPlanImage,
    required this.sections,
  });

  factory HousingType.fromJson(Map<String, dynamic> json) {
    return HousingType(
      id: json['id'] as String,
      area: json['area'] as int? ?? 0,
      areaLabel: json['areaLabel'] as String? ?? '',
      type: json['type'] as String? ?? '',
      targetGroup: json['targetGroup'] as String? ?? '',
      tabLabel: json['tabLabel'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      floorPlanImage: json['floorPlanImage'] as String? ?? '',
      sections: (json['sections'] as List<dynamic>?)
              ?.map((s) => AnnouncementSection.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// 공통 섹션을 포함한 전체 공고 상세 모델
class AnnouncementDetail {
  final String id;
  final String title;
  final String? subtitle;
  final String category;
  final String source;
  final String sourceId;
  final Map<String, dynamic> rawData;
  final List<AnnouncementSection> commonSections;
  final List<HousingType> housingTypes;
  final String status;

  const AnnouncementDetail({
    required this.id,
    required this.title,
    this.subtitle,
    required this.category,
    required this.source,
    required this.sourceId,
    required this.rawData,
    required this.commonSections,
    required this.housingTypes,
    required this.status,
  });

  factory AnnouncementDetail.fromJson(Map<String, dynamic> json) {
    final displayConfig = json['display_config'] as Map<String, dynamic>? ?? {};
    final commonSectionsList = displayConfig['commonSections'] as List<dynamic>? ?? [];

    return AnnouncementDetail(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      category: json['category'] as String,
      source: json['source'] as String,
      sourceId: json['source_id'] as String,
      rawData: json['raw_data'] as Map<String, dynamic>? ?? {},
      commonSections: commonSectionsList
          .map((s) => AnnouncementSection.fromJson(s as Map<String, dynamic>))
          .toList(),
      housingTypes: (json['housing_types'] as List<dynamic>?)
              ?.map((h) => HousingType.fromJson(h as Map<String, dynamic>))
              .toList() ??
          [],
      status: json['status'] as String? ?? 'draft',
    );
  }
}
