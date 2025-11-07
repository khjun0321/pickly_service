// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AnnouncementFile _$AnnouncementFileFromJson(Map<String, dynamic> json) =>
    _AnnouncementFile(
      id: json['id'] as String,
      announcementId: json['announcementId'] as String,
      fileName: json['fileName'] as String,
      fileUrl: json['fileUrl'] as String,
      fileType: json['fileType'] as String?,
      fileSize: (json['fileSize'] as num?)?.toInt(),
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      customData: json['customData'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$AnnouncementFileToJson(_AnnouncementFile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'announcementId': instance.announcementId,
      'fileName': instance.fileName,
      'fileUrl': instance.fileUrl,
      'fileType': instance.fileType,
      'fileSize': instance.fileSize,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'displayOrder': instance.displayOrder,
      'customData': instance.customData,
    };
