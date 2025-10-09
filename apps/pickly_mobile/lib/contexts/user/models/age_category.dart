import 'package:flutter/foundation.dart';

/// Age category model representing onboarding screen 003
///
/// Represents a demographic category for user selection during onboarding.
/// Matches the Supabase `age_categories` table schema.
@immutable
class AgeCategory {
  final String id;
  final String title;
  final String description;
  final String iconComponent;
  final String? iconUrl;
  final int? minAge;
  final int? maxAge;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

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

  /// Create from Supabase JSON response
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

  /// Convert to JSON for Supabase
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

  /// Get age range display text in Korean
  ///
  /// Returns formatted age range or empty string if no age constraints
  String get ageRangeText {
    if (minAge != null && maxAge != null) {
      return '(만 $minAge세-$maxAge세)';
    } else if (minAge != null) {
      return '(만 $minAge세 이상)';
    } else if (maxAge != null) {
      return '(만 $maxAge세 이하)';
    }
    return '';
  }

  /// Create a copy with updated fields
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AgeCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'AgeCategory(id: $id, title: $title, sortOrder: $sortOrder)';
}
