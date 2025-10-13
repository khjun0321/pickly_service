/// Region Model
///
/// Represents a region from the `regions` Supabase table.
/// Used in the onboarding flow (step 4) to allow users to select their
/// applicable regions for policy filtering.
///
/// This model corresponds to the screen config:
/// `.claude/screens/004-region.json`
library;

import 'package:flutter/foundation.dart';

/// Immutable model representing a region option.
///
/// Regions help filter policy recommendations based on geographic
/// location (e.g., 서울, 경기, 부산, etc.).
@immutable
class Region {
  /// Unique identifier (UUID from Supabase)
  final String id;

  /// Region code (e.g., 'SEOUL', 'GYEONGGI', 'NATIONWIDE')
  final String code;

  /// Display name (e.g., '서울', '경기', '전국')
  final String name;

  /// Display order in lists
  final int sortOrder;

  /// Whether this region is currently active/visible
  final bool isActive;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;

  /// Creates an immutable [Region] instance.
  const Region({
    required this.id,
    required this.code,
    required this.name,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [Region] from Supabase JSON response.
  ///
  /// Handles type conversions and null safety for all fields.
  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this [Region] to JSON for Supabase operations.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'sort_order': sortOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy with optional field overrides.
  Region copyWith({
    String? id,
    String? code,
    String? name,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Region(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Region && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Region(id: $id, code: $code, name: $name, '
        'sortOrder: $sortOrder, isActive: $isActive)';
  }
}
