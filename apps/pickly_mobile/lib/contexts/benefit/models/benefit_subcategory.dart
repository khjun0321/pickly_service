import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'benefit_subcategory.g.dart';

/// BenefitSubcategory - Database-driven filter model
///
/// Represents a subcategory of benefits (e.g., 행복주택, 국민임대) that allows
/// users to filter announcements with greater precision.
///
/// Uses B-Lite pattern: Equatable + json_serializable (NOT Freezed)
/// Reason: Freezed 3.2.3 has mixin generation bug
///
/// Database table: public.benefit_subcategories
@JsonSerializable()
class BenefitSubcategory extends Equatable {
  /// Unique identifier (UUID from database)
  final String id;

  /// Parent category ID (FK to benefit_categories.id)
  @JsonKey(name: 'category_id')
  final String? categoryId;

  /// Display name (e.g., "행복주택", "대학 장학금")
  final String name;

  /// URL-friendly slug (e.g., "happy-housing", "university-scholarship")
  final String slug;

  /// Sort order for display (ascending)
  @JsonKey(name: 'sort_order')
  final int sortOrder;

  /// Active status (false = hidden in UI)
  @JsonKey(name: 'is_active')
  final bool isActive;

  /// Icon URL from Supabase Storage (priority 1)
  @JsonKey(name: 'icon_url')
  final String? iconUrl;

  /// Icon name for local assets (priority 2)
  @JsonKey(name: 'icon_name')
  final String? iconName;

  /// Creation timestamp
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Last update timestamp
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const BenefitSubcategory({
    required this.id,
    this.categoryId,
    required this.name,
    required this.slug,
    this.sortOrder = 0,
    this.isActive = true,
    this.iconUrl,
    this.iconName,
    required this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor from JSON (database response)
  factory BenefitSubcategory.fromJson(Map<String, dynamic> json) =>
      _$BenefitSubcategoryFromJson(json);

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() => _$BenefitSubcategoryToJson(this);

  /// Create a copy with modified fields
  BenefitSubcategory copyWith({
    String? id,
    String? categoryId,
    String? name,
    String? slug,
    int? sortOrder,
    bool? isActive,
    String? iconUrl,
    String? iconName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BenefitSubcategory(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      iconUrl: iconUrl ?? this.iconUrl,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Equatable props for value equality
  @override
  List<Object?> get props => [
        id,
        categoryId,
        name,
        slug,
        sortOrder,
        isActive,
        iconUrl,
        iconName,
        createdAt,
        updatedAt,
      ];

  /// Enable toString() for debugging
  @override
  bool get stringify => true;
}
