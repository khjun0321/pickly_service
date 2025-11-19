/// Announcement Model
///
/// Represents a benefit announcement (공고) within the Pickly system.
/// Used to display specific benefit programs that users can apply for.
///
/// Each announcement belongs to an announcement type and contains details
/// about the program including title, organization, region, dates, and status.
library;

import 'package:flutter/material.dart';

/// Immutable model representing a benefit announcement.
///
/// Announcements are the core content displayed in each category tab,
/// showing users available benefit programs they can apply for.
@immutable
class Announcement {
  /// Unique identifier (UUID from Supabase)
  final String id;

  /// Associated announcement type ID (v7.3)
  final String typeId;

  /// Announcement title
  final String title;

  /// Issuing organization name
  final String organization;

  /// Target region (e.g., "서울", "경기", "전국")
  final String? region;

  /// Thumbnail image URL
  final String? thumbnailUrl;

  /// Posted or announcement date
  final DateTime postedDate;

  /// Application status: 'open', 'closed', 'upcoming'
  final String status;

  /// Whether this is a priority/featured announcement
  final bool isPriority;

  /// Link to detailed announcement page
  final String? detailUrl;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;

  /// Creates an immutable [Announcement] instance.
  const Announcement({
    required this.id,
    required this.typeId,
    required this.title,
    required this.organization,
    this.region,
    this.thumbnailUrl,
    required this.postedDate,
    required this.status,
    required this.isPriority,
    this.detailUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates an [Announcement] from Supabase JSON response (v7.3 schema).
  ///
  /// Handles type conversions and null safety for all fields.
  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as String,
      typeId: json['type_id'] as String,
      title: json['title'] as String,
      organization: json['organization'] as String,
      region: json['region'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      postedDate: DateTime.parse(json['posted_date'] as String),
      status: json['status'] as String? ?? 'open',
      isPriority: json['is_priority'] as bool? ?? false,
      detailUrl: json['detail_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this [Announcement] to JSON for Supabase operations.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type_id': typeId,
      'title': title,
      'organization': organization,
      'region': region,
      'thumbnail_url': thumbnailUrl,
      'posted_date': postedDate.toIso8601String(),
      'status': status,
      'is_priority': isPriority,
      'detail_url': detailUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy with optional field overrides.
  Announcement copyWith({
    String? id,
    String? typeId,
    String? title,
    String? organization,
    String? region,
    String? thumbnailUrl,
    DateTime? postedDate,
    String? status,
    bool? isPriority,
    String? detailUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Announcement(
      id: id ?? this.id,
      typeId: typeId ?? this.typeId,
      title: title ?? this.title,
      organization: organization ?? this.organization,
      region: region ?? this.region,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      postedDate: postedDate ?? this.postedDate,
      status: status ?? this.status,
      isPriority: isPriority ?? this.isPriority,
      detailUrl: detailUrl ?? this.detailUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Checks if this announcement is currently open for applications.
  bool get isOpen => status == 'open';

  /// Checks if this announcement is closed.
  bool get isClosed => status == 'closed';

  /// Checks if this announcement is upcoming.
  bool get isUpcoming => status == 'upcoming';

  /// Gets status badge color based on current status.
  Color getStatusColor() {
    switch (status) {
      case 'open':
        return const Color(0xFF4CAF50); // Green
      case 'closed':
        return const Color(0xFF9E9E9E); // Gray
      case 'upcoming':
        return const Color(0xFF2196F3); // Blue
      default:
        return const Color(0xFF9E9E9E); // Default gray
    }
  }

  /// Gets human-readable status text.
  String getStatusText() {
    switch (status) {
      case 'open':
        return '신청 가능';
      case 'closed':
        return '마감';
      case 'upcoming':
        return '예정';
      default:
        return status;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Announcement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Announcement(id: $id, typeId: $typeId, title: $title, '
        'organization: $organization, status: $status, isPriority: $isPriority)';
  }
}
