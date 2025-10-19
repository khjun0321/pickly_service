/// Category Banner Model
///
/// Represents a promotional banner for a specific benefit category.
/// Used in the benefits screen to display category-specific advertisements
/// and promotional content.
///
/// Banners are displayed at the top of each category section to highlight
/// important policies, special campaigns, or featured content.
library;

import 'package:flutter/material.dart';

/// Immutable model representing a category-specific banner.
///
/// Category banners help promote specific policies or campaigns within
/// each benefit category (e.g., 인기, 주거, 교육, 지원, 교통, 복지).
@immutable
class CategoryBanner {
  /// Unique identifier (UUID from Supabase or mock ID)
  final String id;

  /// Associated category ID (e.g., 'popular', 'housing', 'education')
  final String categoryId;

  /// Banner title text
  final String title;

  /// Banner subtitle or description text
  final String subtitle;

  /// Image URL for banner visual
  final String imageUrl;

  /// Background color for banner (hex format)
  final String backgroundColor;

  /// Action URL when banner is tapped
  final String actionUrl;

  /// Display order within category (lower = higher priority)
  final int displayOrder;

  /// Whether this banner is currently active/visible
  final bool isActive;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;

  /// Creates an immutable [CategoryBanner] instance.
  const CategoryBanner({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.backgroundColor,
    required this.actionUrl,
    required this.displayOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [CategoryBanner] from Supabase JSON response.
  ///
  /// Handles type conversions and null safety for all fields.
  factory CategoryBanner.fromJson(Map<String, dynamic> json) {
    return CategoryBanner(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      imageUrl: json['image_url'] as String,
      backgroundColor: json['background_color'] as String,
      actionUrl: json['action_url'] as String,
      displayOrder: json['display_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this [CategoryBanner] to JSON for Supabase operations.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'title': title,
      'subtitle': subtitle,
      'image_url': imageUrl,
      'background_color': backgroundColor,
      'action_url': actionUrl,
      'display_order': displayOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy with optional field overrides.
  CategoryBanner copyWith({
    String? id,
    String? categoryId,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? backgroundColor,
    String? actionUrl,
    int? displayOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryBanner(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      actionUrl: actionUrl ?? this.actionUrl,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts hex color string to Flutter Color object.
  ///
  /// Supports formats:
  /// - '#RRGGBB' (6 digits)
  /// - '#AARRGGBB' (8 digits with alpha)
  /// - 'RRGGBB' (without #)
  ///
  /// Returns default color if parsing fails.
  Color getBackgroundColor() {
    try {
      String colorStr = backgroundColor.replaceAll('#', '');
      if (colorStr.length == 6) {
        colorStr = 'FF$colorStr'; // Add full opacity
      }
      return Color(int.parse(colorStr, radix: 16));
    } catch (e) {
      debugPrint('⚠️ Failed to parse banner color: $backgroundColor, using default');
      return const Color(0xFFE3F2FD); // Light blue fallback
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryBanner && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CategoryBanner(id: $id, categoryId: $categoryId, title: $title, '
        'displayOrder: $displayOrder, isActive: $isActive)';
  }
}
