import 'package:freezed_annotation/freezed_annotation.dart';

part 'announcement_file.freezed.dart';
part 'announcement_file.g.dart';

@freezed
class AnnouncementFile with _$AnnouncementFile {
  const factory AnnouncementFile({
    required String id,
    required String announcementId,
    required String fileName,
    required String fileUrl,
    String? fileType,
    int? fileSize,
    String? description,
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default(0) int displayOrder,
    @Default({}) Map<String, dynamic> customData,
  }) = _AnnouncementFile;

  factory AnnouncementFile.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementFileFromJson(json);

  const AnnouncementFile._();

  T? getCustomField<T>(String key) => customData[key] as T?;

  String get fileSizeFormatted {
    if (fileSize == null) return 'Unknown size';
    final kb = fileSize! / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(1)} KB';
    }
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }

  bool get isPdf => fileType?.toLowerCase() == 'pdf' ||
                    fileName.toLowerCase().endsWith('.pdf');

  bool get isImage => ['jpg', 'jpeg', 'png', 'gif', 'webp']
      .any((ext) => fileName.toLowerCase().endsWith('.$ext'));

  bool get isDocument => ['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx']
      .any((ext) => fileName.toLowerCase().endsWith('.$ext'));
}
