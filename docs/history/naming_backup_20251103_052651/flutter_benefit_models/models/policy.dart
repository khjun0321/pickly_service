/// Policy model representing a government benefit or housing announcement
///
/// This model is designed to support:
/// - Backend admin management
/// - Public API data integration
/// - Local mock data for development
class Policy {
  /// Unique identifier
  final String id;

  /// Policy title
  final String title;

  /// Organization or agency name
  final String organization;

  /// Image URL (can be network URL or asset path)
  final String imageUrl;

  /// Posted date in format 'YYYY/MM/DD'
  final String postedDate;

  /// Recruitment status (true = recruiting, false = closed)
  final bool isRecruiting;

  /// Category ID (housing, education, support, etc.)
  final String categoryId;

  /// Optional: Detailed description
  final String? description;

  /// Optional: Application deadline
  final String? deadline;

  /// Optional: Target audience
  final String? targetAudience;

  /// Optional: External link for more information
  final String? externalUrl;

  /// Optional: Required documents
  final List<String>? requiredDocuments;

  const Policy({
    required this.id,
    required this.title,
    required this.organization,
    required this.imageUrl,
    required this.postedDate,
    required this.isRecruiting,
    required this.categoryId,
    this.description,
    this.deadline,
    this.targetAudience,
    this.externalUrl,
    this.requiredDocuments,
  });

  /// Create Policy from JSON (for API integration)
  factory Policy.fromJson(Map<String, dynamic> json) {
    return Policy(
      id: json['id'] as String,
      title: json['title'] as String,
      organization: json['organization'] as String,
      imageUrl: json['image_url'] as String,
      postedDate: json['posted_date'] as String,
      isRecruiting: json['is_recruiting'] as bool,
      categoryId: json['category_id'] as String,
      description: json['description'] as String?,
      deadline: json['deadline'] as String?,
      targetAudience: json['target_audience'] as String?,
      externalUrl: json['external_url'] as String?,
      requiredDocuments: (json['required_documents'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  /// Convert Policy to JSON (for API submission)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'organization': organization,
      'image_url': imageUrl,
      'posted_date': postedDate,
      'is_recruiting': isRecruiting,
      'category_id': categoryId,
      'description': description,
      'deadline': deadline,
      'target_audience': targetAudience,
      'external_url': externalUrl,
      'required_documents': requiredDocuments,
    };
  }

  /// Create a copy with modified fields
  Policy copyWith({
    String? id,
    String? title,
    String? organization,
    String? imageUrl,
    String? postedDate,
    bool? isRecruiting,
    String? categoryId,
    String? description,
    String? deadline,
    String? targetAudience,
    String? externalUrl,
    List<String>? requiredDocuments,
  }) {
    return Policy(
      id: id ?? this.id,
      title: title ?? this.title,
      organization: organization ?? this.organization,
      imageUrl: imageUrl ?? this.imageUrl,
      postedDate: postedDate ?? this.postedDate,
      isRecruiting: isRecruiting ?? this.isRecruiting,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      targetAudience: targetAudience ?? this.targetAudience,
      externalUrl: externalUrl ?? this.externalUrl,
      requiredDocuments: requiredDocuments ?? this.requiredDocuments,
    );
  }
}
