/// Age Category Model
///
/// Represents an age category from the `age_categories` Supabase table.
/// Used in the onboarding flow (step 3) to allow users to select their
/// applicable age/generation categories.
///
/// This model corresponds to the screen config:
/// `.claude/screens/003-age-category.json`
library;

import 'package:flutter/foundation.dart';

/// Immutable model representing an age category option.
///
/// Age categories help personalize policy recommendations based on
/// life stage (e.g., youth, newlyweds, parents, seniors, etc.).
@immutable
class AgeCategory {
  /// Unique identifier (UUID from Supabase)
  final String id;

  /// Display title (e.g., "청년", "신혼부부·예비부부")
  final String title;

  /// Detailed description (e.g., "(만 19세-39세) 대학생, 취업준비생, 직장인")
  final String description;

  /// Icon component identifier for UI rendering
  final String iconComponent;

  /// Optional icon URL (can be null)
  final String? iconUrl;

  /// Minimum age for eligibility (null if not applicable)
  final int? minAge;

  /// Maximum age for eligibility (null if not applicable)
  final int? maxAge;

  /// Display order in lists
  final int sortOrder;

  /// Whether this category is currently active/visible
  final bool isActive;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;

  /// Creates an immutable [AgeCategory] instance.
  const AgeCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.iconComponent,
    this.iconUrl,
    this.minAge,
    this.maxAge,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates an [AgeCategory] from Supabase JSON response.
  ///
  /// Handles type conversions and null safety for all fields.
  factory AgeCategory.fromJson(Map<String, dynamic> json) {
    return AgeCategory(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconComponent: json['icon_component'] as String,
      iconUrl: json['icon_url'] as String?,
      minAge: json['min_age'] as int?,
      maxAge: json['max_age'] as int?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this [AgeCategory] to JSON for Supabase operations.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon_component': iconComponent,
      'icon_url': iconUrl,
      'min_age': minAge,
      'max_age': maxAge,
      'sort_order': sortOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy with optional field overrides.
  AgeCategory copyWith({
    String? id,
    String? title,
    String? description,
    String? iconComponent,
    String? iconUrl,
    int? minAge,
    int? maxAge,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AgeCategory(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconComponent: iconComponent ?? this.iconComponent,
      iconUrl: iconUrl ?? this.iconUrl,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Checks if a given age falls within this category's age range.
  ///
  /// Returns true if:
  /// - No age constraints are defined (minAge and maxAge are null)
  /// - Age is within the defined range (inclusive)
  bool isAgeInRange(int age) {
    if (minAge == null && maxAge == null) return true;
    if (minAge != null && age < minAge!) return false;
    if (maxAge != null && age > maxAge!) return false;
    return true;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AgeCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AgeCategory(id: $id, title: $title, description: $description, '
        'iconComponent: $iconComponent, sortOrder: $sortOrder, isActive: $isActive)';
  }
}
