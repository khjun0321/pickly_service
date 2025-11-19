/// Announcement Type Model (v7.3)
///
/// Represents a category/filter for benefit announcements.
/// Used in benefit screens to filter announcements by type.
///
/// Example: "청년", "신혼부부", "고령자" for housing category
library;

import 'package:flutter/material.dart';

/// Immutable model representing an announcement type/category.
@immutable
class AnnouncementType {
  /// Unique identifier (UUID from Supabase)
  final String id;

  /// Associated benefit category ID
  final String benefitCategoryId;

  /// Type title (e.g., "청년", "신혼부부")
  final String title;

  /// Optional description
  final String? description;

  /// Sort order for display
  final int sortOrder;

  /// Whether this type is active
  final bool isActive;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;

  /// Creates an immutable [AnnouncementType] instance.
  const AnnouncementType({
    required this.id,
    required this.benefitCategoryId,
    required this.title,
    this.description,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates an [AnnouncementType] from Supabase JSON response (v7.3 schema).
  factory AnnouncementType.fromJson(Map<String, dynamic> json) {
    return AnnouncementType(
      id: json['id'] as String,
      benefitCategoryId: json['benefit_category_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this [AnnouncementType] to JSON for Supabase operations.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'benefit_category_id': benefitCategoryId,
      'title': title,
      'description': description,
      'sort_order': sortOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy with optional field overrides.
  AnnouncementType copyWith({
    String? id,
    String? benefitCategoryId,
    String? title,
    String? description,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnnouncementType(
      id: id ?? this.id,
      benefitCategoryId: benefitCategoryId ?? this.benefitCategoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnnouncementType && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AnnouncementType(id: $id, title: $title, sortOrder: $sortOrder, isActive: $isActive)';
  }
}
