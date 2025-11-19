import 'package:json_annotation/json_annotation.dart';

part 'announcement_tab.g.dart';

/// 공고 탭 모델 (평형별/연령별 정보)
/// PRD v7.0 기준: announcement_tabs 테이블
@JsonSerializable(fieldRename: FieldRename.snake)
class AnnouncementTab {
  final String id;

  @JsonKey(name: 'announcement_id')
  final String announcementId;

  @JsonKey(name: 'tab_name')
  final String tabName;

  @JsonKey(name: 'age_category_id')
  final String? ageCategoryId;

  @JsonKey(name: 'unit_type')
  final String? unitType;

  @JsonKey(name: 'floor_plan_image_url')
  final String? floorPlanImageUrl;

  @JsonKey(name: 'supply_count')
  final int? supplyCount;

  @JsonKey(name: 'income_conditions')
  final Map<String, dynamic>? incomeConditions;

  @JsonKey(name: 'additional_info')
  final Map<String, dynamic>? additionalInfo;

  @JsonKey(name: 'display_order', defaultValue: 0)
  final int displayOrder;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  const AnnouncementTab({
    required this.id,
    required this.announcementId,
    required this.tabName,
    this.ageCategoryId,
    this.unitType,
    this.floorPlanImageUrl,
    this.supplyCount,
    this.incomeConditions,
    this.additionalInfo,
    this.displayOrder = 0,
    this.createdAt,
  });

  factory AnnouncementTab.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementTabFromJson(json);

  Map<String, dynamic> toJson() => _$AnnouncementTabToJson(this);

  /// 보증금 정보 (income_conditions에서 추출)
  String? get deposit => incomeConditions?['deposit'] as String?;

  /// 월세 정보 (income_conditions에서 추출)
  String? get monthlyRent => incomeConditions?['monthly_rent'] as String?;

  /// 자격 조건 (income_conditions에서 추출)
  String? get eligibleCondition => incomeConditions?['eligible_condition'] as String?;

  AnnouncementTab copyWith({
    String? id,
    String? announcementId,
    String? tabName,
    String? ageCategoryId,
    String? unitType,
    String? floorPlanImageUrl,
    int? supplyCount,
    Map<String, dynamic>? incomeConditions,
    Map<String, dynamic>? additionalInfo,
    int? displayOrder,
    DateTime? createdAt,
  }) {
    return AnnouncementTab(
      id: id ?? this.id,
      announcementId: announcementId ?? this.announcementId,
      tabName: tabName ?? this.tabName,
      ageCategoryId: ageCategoryId ?? this.ageCategoryId,
      unitType: unitType ?? this.unitType,
      floorPlanImageUrl: floorPlanImageUrl ?? this.floorPlanImageUrl,
      supplyCount: supplyCount ?? this.supplyCount,
      incomeConditions: incomeConditions ?? this.incomeConditions,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
