# Pre-Existing Bugs Report (Before Hybrid Fix)

**Date**: 2025-11-04 20:30 KST
**Status**: ❌ **BASELINE NOT WORKING**

---

## 🚨 Discovery

While attempting to incrementally reapply the hybrid fix (commit `41ea525`), I discovered that **the baseline itself has build errors**.

The task description stated "앱 빌드는 정상적으로 복구되었습니다" (the app build has been restored successfully), but testing reveals **this is not accurate**.

---

## ❌ Pre-Existing Errors (Present in commit 1dd76fd and 41ea525)

### **Error 1: Announcement Model Field Mismatch**

**Location**: `lib/contexts/benefit/repositories/benefit_repository.dart:lines 450-462`

**Code**:
```dart
Future<bool> isAcceptingApplications(String announcementId) async {
  try {
    final announcement = await getAnnouncement(announcementId);
    final now = DateTime.now();

    // No dates specified = always accepting
    if (announcement.applicationPeriodStart == null &&  // ❌ Field doesn't exist
        announcement.applicationPeriodEnd == null) {    // ❌ Field doesn't exist
      return true;
    }

    // Check if within application period
    if (announcement.applicationPeriodStart != null &&  // ❌ Field doesn't exist
        now.isBefore(announcement.applicationPeriodStart!)) {
      return false;
    }

    if (announcement.applicationPeriodEnd != null &&    // ❌ Field doesn't exist
        now.isAfter(announcement.applicationPeriodEnd!)) {
      return false;
    }

    return true;
  } catch (e, stackTrace) {
    throw AnnouncementException(e.toString(), stackTrace);
  }
}
```

**Error Messages**:
```
lib/contexts/benefit/repositories/benefit_repository.dart:450:24: Error: The getter 'applicationPeriodStart' isn't defined for the type 'Announcement'.
lib/contexts/benefit/repositories/benefit_repository.dart:451:24: Error: The getter 'applicationPeriodEnd' isn't defined for the type 'Announcement'.
lib/contexts/benefit/repositories/benefit_repository.dart:456:24: Error: The getter 'applicationPeriodStart' isn't defined for the type 'Announcement'.
lib/contexts/benefit/repositories/benefit_repository.dart:457:37: Error: The getter 'applicationPeriodStart' isn't defined for the type 'Announcement'.
lib/contexts/benefit/repositories/benefit_repository.dart:461:24: Error: The getter 'applicationPeriodEnd' isn't defined for the type 'Announcement'.
lib/contexts/benefit/repositories/benefit_repository.dart:462:36: Error: The getter 'applicationPeriodEnd' isn't defined for the type 'Announcement'.
```

**Root Cause**:
The `Announcement` model (in `lib/contexts/benefit/models/announcement.dart`) does NOT have these fields. The model only has:
- `id`, `title`, `subtitle`, `organization`
- `subcategoryId`, `thumbnailUrl`, `externalUrl`
- `status`, `isFeatured`, `isHomeVisible`, `sortOrder`, `viewCount`
- `tags`, `createdAt`, `updatedAt`

**Origin**: This bug was introduced in commit `1dd76fd` (Phase 3 implementation) and exists in ALL subsequent commits including the hybrid fix (`41ea525`).

---

### **Error 2: AnnouncementFile Freezed Malformation**

**Location**: `lib/contexts/benefit/models/announcement_file.dart`

**Error Message**:
```
lib/contexts/benefit/models/announcement_file.dart:7:7: Error: The non-abstract class 'AnnouncementFile' is missing implementations for these members:
 - _$AnnouncementFile.announcementId
 - _$AnnouncementFile.createdAt
 - _$AnnouncementFile.customData
 - _$AnnouncementFile.description
 - _$AnnouncementFile.displayOrder
 - _$AnnouncementFile.fileName
 - _$AnnouncementFile.fileSize
 - _$AnnouncementFile.fileType
 - _$AnnouncementFile.fileUrl
 - _$AnnouncementFile.id
 - _$AnnouncementFile.toJson
 - _$AnnouncementFile.updatedAt
```

**Root Cause**:
The generated `.freezed.dart` file has malformed line 18 where all getters are concatenated without proper line breaks:
```dart
String get id; String get announcementId; String get fileName; String get fileUrl; String? get fileType; int? get fileSize; String? get description; DateTime get createdAt; DateTime? get updatedAt; int get displayOrder; Map<String, dynamic> get customData;
```

**Origin**: This is a Freezed code generation bug that existed in commit `1dd76fd` (Phase 3) and persists in all subsequent commits.

---

## 📊 Build Status Timeline

| Commit | Description | Build Status |
|--------|-------------|--------------|
| `1dd76fd` | Phase 3 - Realtime Sync | ❌ **FAILS** (same errors) |
| `41ea525` | Hybrid Fix | ❌ **FAILS** (same errors) |
| Current | After git restore | ❌ **FAILS** (same errors) |

**Conclusion**: There is NO working baseline in recent commits. The bugs existed BEFORE the hybrid fix was applied.

---

## 🎯 Required Action

Before we can incrementally reapply the hybrid fix, we **MUST** first fix these pre-existing bugs:

### **Fix 1: Simplify isAcceptingApplications()**

**Current (Broken)**:
```dart
Future<bool> isAcceptingApplications(String announcementId) async {
  final announcement = await getAnnouncement(announcementId);
  final now = DateTime.now();

  if (announcement.applicationPeriodStart == null &&
      announcement.applicationPeriodEnd == null) {
    return true;
  }
  // ... more code using non-existent fields
}
```

**Fixed (Uses existing status field)**:
```dart
Future<bool> isAcceptingApplications(String announcementId) async {
  try {
    final announcement = await getAnnouncement(announcementId);
    // Check if status is 'recruiting' (모집중)
    return announcement.status == 'recruiting';
  } catch (e, stackTrace) {
    throw AnnouncementException(e.toString(), stackTrace);
  }
}
```

### **Fix 2: AnnouncementFile Freezed Issue**

**Options**:
1. **Remove the model** - if it's not being used
2. **Fix the model definition** - ensure it matches Freezed requirements
3. **Regenerate with dart format** - try to fix formatting

**Recommendation**: Check if `AnnouncementFile` is actually used anywhere. If not, remove it. If yes, fix the model definition.

---

## 📋 Revised Task Plan

### **Phase 0: Fix Pre-Existing Bugs** ← **WE ARE HERE**
1. Fix `isAcceptingApplications()` method
2. Fix or remove `AnnouncementFile` model
3. Verify app builds successfully
4. Create working baseline

### **Phase 1-4: Incremental Hybrid Fix** (AFTER Phase 0)
1. Add autoDispose to provider
2. Add lazy Builder to router
3. Add AutomaticKeepAliveClientMixin
4. Add timeout and error handling

---

## 🤔 Why This Happened

The task description assumed a working baseline existed, but:

1. **Commit 41ea525** (hybrid fix) was built ON TOP of bugs from commit 1dd76fd
2. **Commit 1dd76fd** (Phase 3) introduced the Announcement field errors and Freezed issues
3. **No one tested the build** after Phase 3 was merged

**Result**: We have 2-3 commits of broken code, and the hybrid fix made it worse by adding MORE complexity on top of existing bugs.

---

## ✅ Next Steps

1. **Apply Fix 1**: Simplify `isAcceptingApplications()` to use existing `status` field
2. **Apply Fix 2**: Fix or remove `AnnouncementFile` model
3. **Verify Build**: Confirm app builds successfully
4. **THEN**: Proceed with incremental hybrid fix reapplication

---

**Status**: ⚠️ **BASELINE FIX REQUIRED BEFORE INCREMENTAL REAPPLICATION**

**Recommendation**: Fix pre-existing bugs first, THEN apply hybrid fix incrementally

---

**Last Updated**: 2025-11-04 20:30 KST

**Engineer**: Claude Code

**Requires**: Fix Phase 0 bugs before proceeding to Phase 1-4
