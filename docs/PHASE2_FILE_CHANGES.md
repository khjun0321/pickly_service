# Phase 2 - Exact File Changes

## File 1: apps/pickly_mobile/lib/features/benefits/models/announcement.dart

### Change 1.1 - Line 21-22 (Field Declaration)
```dart
// BEFORE
  /// Associated announcement type ID (v7.3)
  final String typeId;

// AFTER
  /// Associated announcement subcategory ID (PRD v9.6.1)
  final String subcategoryId;
```

### Change 1.2 - Line 60 (Constructor)
```dart
// BEFORE
    required this.typeId,

// AFTER
    required this.subcategoryId,
```

### Change 1.3 - Line 80 (fromJson)
```dart
// BEFORE
      typeId: json['type_id'] as String,

// AFTER
      subcategoryId: json['subcategory_id'] as String,
```

### Change 1.4 - Line 103 (toJson)
```dart
// BEFORE
      'type_id': typeId,

// AFTER
      'subcategory_id': subcategoryId,
```

### Change 1.5 - Line 121 (copyWith parameter)
```dart
// BEFORE
    String? typeId,

// AFTER
    String? subcategoryId,
```

### Change 1.6 - Line 136 (copyWith implementation)
```dart
// BEFORE
      typeId: typeId ?? this.typeId,

// AFTER
      subcategoryId: subcategoryId ?? this.subcategoryId,
```

### Change 1.7 - Line 199 (toString)
```dart
// BEFORE
    return 'Announcement(id: $id, typeId: $typeId, title: $title, '

// AFTER
    return 'Announcement(id: $id, subcategoryId: $subcategoryId, title: $title, '
```

---

## File 2: apps/pickly_mobile/lib/contexts/benefit/models/announcement.dart

### Change 2.1 - Line 14-15 (Field Declaration - subcategory)
```dart
// BEFORE
  @JsonKey(name: 'type_id')
  final String? typeId;

// AFTER
  @JsonKey(name: 'subcategory_id')
  final String? subcategoryId;
```

### Change 2.2 - Line 35-36 (Field Declaration - view count)
```dart
// BEFORE
  @JsonKey(name: 'views_count', defaultValue: 0)
  final int viewsCount;

// AFTER
  @JsonKey(name: 'view_count', defaultValue: 0)
  final int viewCount;
```

### Change 2.3 - Line 52 (Constructor - subcategory)
```dart
// BEFORE
    this.typeId,

// AFTER
    this.subcategoryId,
```

### Change 2.4 - Line 59 (Constructor - view count)
```dart
// BEFORE
    this.viewsCount = 0,

// AFTER
    this.viewCount = 0,
```

### Change 2.5 - Line 108 (copyWith parameter - subcategory)
```dart
// BEFORE
    String? typeId,

// AFTER
    String? subcategoryId,
```

### Change 2.6 - Line 115 (copyWith parameter - view count)
```dart
// BEFORE
    int? viewsCount,

// AFTER
    int? viewCount,
```

### Change 2.7 - Line 125 (copyWith implementation - subcategory)
```dart
// BEFORE
      typeId: typeId ?? this.typeId,

// AFTER
      subcategoryId: subcategoryId ?? this.subcategoryId,
```

### Change 2.8 - Line 132 (copyWith implementation - view count)
```dart
// BEFORE
      viewsCount: viewsCount ?? this.viewsCount,

// AFTER
      viewCount: viewCount ?? this.viewCount,
```

---

## Summary

**Total Changes**: 15 (7 in file 1, 8 in file 2)
**Total Files**: 2
**Lines Modified**: ~24
**Field Renames**: 
- `typeId` → `subcategoryId` (11 occurrences)
- `viewsCount` → `viewCount` (4 occurrences)
**JSON Key Updates**:
- `'type_id'` → `'subcategory_id'` (2 occurrences)
- `'views_count'` → `'view_count'` (1 occurrence)
