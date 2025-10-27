import 'package:freezed_annotation/freezed_annotation.dart';

part 'announcement.freezed.dart';
part 'announcement.g.dart';

/// 혜택 공고 모델
/// LH 공공임대, 복지 혜택 등의 공고 정보를 담는 모델
@freezed
class Announcement with _$Announcement {
  const factory Announcement({
    required String id,
    required String categoryId,
    required String title,
    String? subtitle,
    String? organization,
    DateTime? applicationPeriodStart,
    DateTime? applicationPeriodEnd,
    DateTime? announcementDate,
    @Default(AnnouncementStatus.draft) AnnouncementStatus status,
    @Default(false) bool isFeatured,
    @Default(false) bool isHomeVisible,
    @Default(0) int displayPriority,
    @Default(0) int viewsCount,
    String? summary,
    String? thumbnailUrl,
    String? externalUrl,
    String? externalId,
    @Default([]) List<String> tags,
    DateTime? publishedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default({}) Map<String, dynamic> customData,
    String? description,
    String? content,
    String? agency,
    String? contactInfo,
    DateTime? deadline,
    @Default(0) int displayOrder,
    @Default(0) int bookmarkCount,
    @Default([]) List<String> targetGroups,
  }) = _Announcement;

  factory Announcement.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementFromJson(json);

  const Announcement._();

  bool get isPublished => status == AnnouncementStatus.recruiting ||
                          status == AnnouncementStatus.upcoming ||
                          status == AnnouncementStatus.closed;
  bool get isDraft => status == AnnouncementStatus.draft;
  bool get isRecruiting => status == AnnouncementStatus.recruiting;
  bool get isClosed => status == AnnouncementStatus.closed;

  bool get isApplicationPeriod {
    final now = DateTime.now();
    if (applicationPeriodStart != null && applicationPeriodEnd != null) {
      return now.isAfter(applicationPeriodStart!) && now.isBefore(applicationPeriodEnd!);
    }
    return false;
  }

  bool get hasDeadlinePassed {
    if (deadline != null) {
      return DateTime.now().isAfter(deadline!);
    }
    if (applicationPeriodEnd != null) {
      return DateTime.now().isAfter(applicationPeriodEnd!);
    }
    return false;
  }

  T? getCustomField<T>(String key) => customData[key] as T?;

  int? get unitCount => getCustomField<int>('unit_count');
  String? get location => getCustomField<String>('location');
  String? get housingType => getCustomField<String>('housing_type');
  String? get supplyType => getCustomField<String>('supply_type');
  double? get supplyPrice => getCustomField<num>('supply_price')?.toDouble();
  String? get eligibilityIncome => getCustomField<String>('eligibility_income');
  String? get eligibilityAsset => getCustomField<String>('eligibility_asset');
  int? get minAge => getCustomField<int>('min_age');
  int? get maxAge => getCustomField<int>('max_age');
  List<String>? get eligibleRegions =>
      getCustomField<List<dynamic>>('eligible_regions')?.cast<String>();
  String? get applicationMethod => getCustomField<String>('application_method');
  String? get applicationUrl => getCustomField<String>('application_url');
  String? get requiredDocuments => getCustomField<String>('required_documents');
  String? get selectionProcess => getCustomField<String>('selection_process');
  DateTime? get moveInDate {
    final dateStr = getCustomField<String>('move_in_date');
    return dateStr != null ? DateTime.tryParse(dateStr) : null;
  }
}

/// 공고 상태
enum AnnouncementStatus {
  /// 임시저장
  @JsonValue('draft')
  draft,

  /// 모집중
  @JsonValue('recruiting')
  recruiting,

  /// 예정
  @JsonValue('upcoming')
  upcoming,

  /// 마감
  @JsonValue('closed')
  closed;

  /// 상태 표시용 라벨
  String get label {
    switch (this) {
      case AnnouncementStatus.draft:
        return '임시저장';
      case AnnouncementStatus.recruiting:
        return '모집중';
      case AnnouncementStatus.upcoming:
        return '예정';
      case AnnouncementStatus.closed:
        return '마감';
    }
  }

  /// 상태별 색상 (Material Design Color)
  String get colorHex {
    switch (this) {
      case AnnouncementStatus.draft:
        return '#757575'; // Grey
      case AnnouncementStatus.recruiting:
        return '#4CAF50'; // Green
      case AnnouncementStatus.upcoming:
        return '#2196F3'; // Blue
      case AnnouncementStatus.closed:
        return '#F44336'; // Red
    }
  }

  /// 상태별 아이콘 이모지
  String get emoji {
    switch (this) {
      case AnnouncementStatus.draft:
        return '⚫';
      case AnnouncementStatus.recruiting:
        return '🟢';
      case AnnouncementStatus.upcoming:
        return '🔵';
      case AnnouncementStatus.closed:
        return '🔴';
    }
  }
}
