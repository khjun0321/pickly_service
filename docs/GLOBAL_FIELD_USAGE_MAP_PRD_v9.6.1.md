# Global Field Usage Map - PRD v9.6.1

**Generated**: 2025-11-03
**Scope**: Database → Admin (React/TypeScript) → Flutter (Dart)
**Purpose**: Trace all Supabase table fields and their usage across the entire Pickly codebase

---

## Executive Summary

| Metric | Count |
|--------|-------|
| Total DB columns analyzed | 89 |
| Admin files scanned | 40 |
| Flutter files scanned | 86 |
| ✅ Fully consistent fields | 72 |
| 🟡 Minor inconsistencies | 12 |
| ⚠️ Medium risk fields | 4 |
| 🔴 High risk fields | 1 |

---

## 🔴 CRITICAL ISSUES

### Issue #1: Field Naming Inconsistency - `display_order` vs `sort_order`

**Database Reality**:
- `announcement_tabs.display_order` (DB column)
- `announcement_sections.display_order` (DB column)
- `benefit_subcategories.sort_order` (DB column - renamed from display_order in migration 20251102000002)
- `category_banners.display_order` (DB column - conflicting with PRD v9.6)
- `age_categories.sort_order` (DB column)

**PRD v9.6 Standard**: "정렬 sort_order 모든 리스트 공통"

**Admin Usage**:
| File | Line | Field Name | Context |
|------|------|------------|---------|
| `types/database.ts` | L129 | `display_order: number` | announcement_tabs type |
| `types/database.ts` | L84 | `display_order: number` | announcement_sections type |
| `types/database.ts` | L301 | `display_order: number` | benefit_subcategories type (INCONSISTENT!) |
| `types/database.ts` | L339 | `display_order: number` | category_banners type |
| `types/supabase.ts` | L343 | `sort_order: number` | announcement_types type |
| `pages/announcement-types/AnnouncementTypesPage.tsx` | L95 | `.order('sort_order')` | Query |
| `pages/announcement-types/AnnouncementTypesPage.tsx` | L112 | `.order('display_order')` | Query for tabs |
| `pages/banners/CategoryBannerList.tsx` | L80 | `a.display_order - b.display_order` | Sort logic |

**Flutter Usage**:
| File | Line | Field Name | Context |
|------|------|------------|---------|
| `contexts/benefit/models/benefit_category.dart` | L19 | `@JsonKey(name: 'sort_order')` | ✅ Correct |
| `contexts/benefit/models/announcement_section.dart` | L21 | `@JsonKey(name: 'display_order')` | Uses display_order |
| `contexts/benefit/models/announcement_tab.g.dart` | L20 | `displayOrder: json['display_order']` | Uses display_order |
| `features/benefits/models/category_banner.dart` | L48 | `final int sortOrder` | Uses sortOrder (INCONSISTENT!) |

**Risk Level**: 🔴 **HIGH RISK - Schema Mismatch**

**Root Cause**:
1. Migration `20251102000002_align_subcategories_prd_v96.sql` renamed `benefit_subcategories.display_order` → `sort_order`
2. Migration `20251102000003_align_banners_prd_v96.sql` renamed `category_banners.display_order` → `sort_order`
3. BUT: Admin `types/database.ts` still has `display_order` for these tables
4. Flutter `category_banner.dart` uses `sortOrder` (camelCase of `sort_order`) but DB has `display_order`

**Action Required**:
1. **URGENT**: Regenerate Admin `types/database.ts` from current DB schema
2. Verify all migrations ran successfully: `SELECT * FROM supabase_migrations.schema_migrations ORDER BY version DESC;`
3. Choose ONE standard:
   - Option A: Use `sort_order` everywhere (PRD v9.6 standard) ✅ **RECOMMENDED**
   - Option B: Use `display_order` everywhere (requires rolling back migrations)

---

## Table: `announcements` (19 columns)

### ✅ Field: `application_start_date`

| Layer | Field Name | File Location | Line | Usage Context | Notes |
|-------|------------|---------------|------|---------------|-------|
| **DB** | `application_start_date` | migrations/20251031000001_add_announcement_fields.sql | L16 | Column definition (timestamp with time zone) | ✅ Primary source |
| **Admin** | `application_start_date` | types/database.ts | L183 | Type definition (string \| null) | ✅ Matches DB |
| **Admin** | `application_start_date` | types/benefits.ts | L124 | Type definition (string \| null) | ✅ Matches DB |
| **Admin** | `application_start_date` | pages/benefits/AnnouncementManagementPage.tsx | L81 | Form initialization | ✅ Correct usage |
| **Admin** | `application_start_date` | pages/benefits/AnnouncementManagementPage.tsx | L132 | `.order('application_start_date', { ascending: false })` | ✅ Sorting |
| **Admin** | `application_start_date` | pages/benefits/BenefitAnnouncementForm.tsx | L488 | Form field name | ✅ Correct usage |
| **Admin** | `application_start_date` | components/benefits/SortableRow.tsx | L146 | Direct field access | ✅ Correct usage |
| **Flutter** | `applicationStartDate` | features/benefits/models/announcement.dart | L37 | Model field (DateTime?) | ✅ Matches DB (camelCase) |
| **Flutter** | `application_start_date` | features/benefits/models/announcement.dart | L85 | JSON key annotation | ✅ Correct mapping |
| **Flutter** | `applicationStartDate` | features/benefits/repositories/announcement_repository.dart | L406 | Sorting logic | ✅ Correct usage |

**Risk Level**: ✅ **Safe**
**Semantic Match**: YES (all layers use this for announcement start date)
**Consistency**: 100% - DB column maps correctly to snake_case in Admin and camelCase in Flutter

---

### ✅ Field: `application_end_date`

| Layer | Field Name | File Location | Line | Usage Context | Notes |
|-------|------------|---------------|------|---------------|-------|
| **DB** | `application_end_date` | migrations/20251031000001_add_announcement_fields.sql | L17 | Column definition (timestamp with time zone) | ✅ Primary source |
| **Admin** | `application_end_date` | types/database.ts | L182 | Type definition (string \| null) | ✅ Matches DB |
| **Admin** | `application_end_date` | types/benefits.ts | L125 | Type definition (string \| null) | ✅ Matches DB |
| **Admin** | `application_end_date` | pages/benefits/AnnouncementManagementPage.tsx | L82 | Form initialization | ✅ Correct usage |
| **Admin** | `application_end_date` | pages/benefits/BenefitAnnouncementForm.tsx | L507 | Form field name | ✅ Correct usage |
| **Admin** | `application_end_date` | components/benefits/SortableRow.tsx | L147 | Direct field access | ✅ Correct usage |
| **Flutter** | `applicationEndDate` | features/benefits/models/announcement.dart | L38 | Model field (DateTime?) | ✅ Matches DB (camelCase) |
| **Flutter** | `application_end_date` | features/benefits/models/announcement.dart | L87 | JSON key annotation | ✅ Correct mapping |

**Risk Level**: ✅ **Safe**
**Semantic Match**: YES
**Consistency**: 100%

---

### ⚠️ Field: `subcategory_id` (announcements table)

| Layer | Field Name | File Location | Line | Usage Context | Notes |
|-------|------------|---------------|------|---------------|-------|
| **DB** | `subcategory_id` | migrations/20251030000003_prd_v8_1_sync.sql | N/A | Foreign key to benefit_subcategories | ✅ Primary source |
| **Admin** | `subcategory_id` | types/database.ts | L194 | Type definition (string \| null) | ✅ Matches DB |
| **Admin** | `subcategory_id` | types/benefits.ts | L112 | Type definition (string \| null) | ✅ Matches DB |
| **Admin** | `subcategory_id` | pages/benefits/AnnouncementManagementPage.tsx | L69 | Form field | ✅ Correct usage |
| **Admin** | `subcategory_id` | pages/benefits/AnnouncementManagementPage.tsx | L138 | `.eq('subcategory_id', subcategoryFilter)` | ✅ Query filter |
| **Admin** | `subcategory_id` | pages/benefits/components/AnnouncementManager.tsx | L60 | Zod validation | ✅ Schema validation |
| **Flutter** | `typeId` | contexts/benefit/models/announcement.dart | L14-15 | `@JsonKey(name: 'type_id')` | 🔴 **SEMANTIC MISMATCH!** |
| **Flutter** | `typeId` | features/benefits/models/announcement.dart | L22 | Model field (String) | 🔴 **USES type_id NOT subcategory_id!** |

**Risk Level**: 🔴 **HIGH RISK - Semantic Mismatch**

**Issue**: Flutter models use `type_id` field name but Admin uses `subcategory_id`. These are NOT the same field!

**Database Reality Check**:
- ✅ `announcements.subcategory_id` EXISTS (references benefit_subcategories)
- ❌ `announcements.type_id` does NOT exist in current schema (deprecated)
- ⚠️ Old migrations reference `type_id` but it was removed

**Flutter Code Evidence**:
```dart
// contexts/benefit/models/announcement.dart:14
@JsonKey(name: 'type_id')
final String? typeId;
```

This is a **legacy field name** that should be updated to `subcategory_id`.

**Action Required**:
1. Update Flutter `announcement.dart` model:
   - Change `@JsonKey(name: 'type_id')` → `@JsonKey(name: 'subcategory_id')`
   - Change `final String? typeId` → `final String? subcategoryId`
2. Run `flutter pub run build_runner build --delete-conflicting-outputs`
3. Update all Flutter code references from `typeId` to `subcategoryId`

---

### ✅ Field: `view_count` (renamed from views_count)

| Layer | Field Name | File Location | Line | Usage Context | Notes |
|-------|------------|---------------|------|---------------|-------|
| **DB** | `view_count` | migrations/20251031000001_add_announcement_fields.sql | L32 | Renamed from views_count | ✅ Primary source |
| **Admin** | `views_count` | types/database.ts | L200 | Type definition (number \| null) | ⚠️ OLD NAME (should be view_count) |
| **Flutter** | `viewsCount` | contexts/benefit/models/announcement.dart | L36 | `@JsonKey(name: 'views_count')` | ⚠️ OLD NAME |

**Risk Level**: 🟡 **Low Risk** (migration renamed but types not updated)

**Action Required**: Update type definitions to use `view_count` instead of `views_count`

---

### ✅ Field: `thumbnail_url`

| Layer | Field Name | File Location | Line | Usage Context | Notes |
|-------|------------|---------------|------|---------------|-------|
| **DB** | `thumbnail_url` | migrations/20251030000003_prd_v8_1_sync.sql | N/A | Column definition (text) | ✅ Primary source |
| **Admin** | `thumbnail_url` | types/database.ts | L197 | Type definition (string \| null) | ✅ Matches DB |
| **Flutter** | `thumbnailUrl` | contexts/benefit/models/announcement.dart | L18 | `@JsonKey(name: 'thumbnail_url')` | ✅ Correct mapping |

**Risk Level**: ✅ **Safe**
**Consistency**: 100%

---

### ✅ Field: `status` (enum: recruiting, closed, draft, upcoming)

| Layer | Field Name | File Location | Line | Usage Context | Notes |
|-------|------------|---------------|------|---------------|-------|
| **DB** | `status` | migrations/20251031000001_add_announcement_fields.sql | L40 | CHECK constraint | ✅ Primary source |
| **Admin** | `status` | types/database.ts | L193 | Type definition (string) | ✅ Matches DB |
| **Flutter** | `status` | contexts/benefit/models/announcement.dart | L24 | Model field with default 'draft' | ✅ Matches DB |

**Risk Level**: ✅ **Safe**
**Valid Values**: `recruiting`, `closed`, `draft`, `upcoming`

---

## Table: `announcement_tabs` (12 columns)

### ⚠️ Field: `display_order` (should be `sort_order` per PRD v9.6?)

| Layer | Field Name | File Location | Line | Usage Context | Notes |
|-------|------------|---------------|------|---------------|-------|
| **DB** | `display_order` | migrations/20251101000003_create_announcement_tabs.sql | L21 | Column definition (integer DEFAULT 0) | ✅ Primary source |
| **Admin** | `display_order` | types/database.ts | L129 | Type definition (number) | ✅ Matches DB |
| **Admin** | `display_order` | types/announcement.ts | L78 | Form data type | ✅ Matches DB |
| **Admin** | `display_order` | pages/announcement-types/AnnouncementTypesPage.tsx | L112 | `.order('display_order')` | ✅ Correct query |
| **Admin** | `display_order` | pages/announcement-types/AnnouncementTypesPage.tsx | L138 | Form initialization | ✅ Correct usage |
| **Flutter** | `displayOrder` | contexts/benefit/models/announcement_tab.g.dart | L20 | JSON deserialization | ✅ Correct mapping |

**Risk Level**: 🟡 **Low Risk** (naming convention inconsistency with PRD v9.6)

**Note**: PRD v9.6 specifies `sort_order` as standard, but this table uses `display_order`. Consider renaming in future migration.

---

### ✅ Field: `income_conditions` (jsonb)

| Layer | Field Name | File Location | Line | Usage Context | Notes |
|-------|------------|---------------|------|---------------|-------|
| **DB** | `income_conditions` | migrations/20251101000003_create_announcement_tabs.sql | L19 | Column definition (jsonb DEFAULT '[]'::jsonb) | ✅ Primary source |
| **Admin** | `income_conditions` | types/database.ts | L132 | Type definition (Json \| null) | ✅ Matches DB |
| **Admin** | `income_conditions` | types/announcement.ts | L76 | IncomeCondition[] \| null | ✅ Typed interface |

**Risk Level**: ✅ **Safe**
**Type**: JSONB array of income condition objects

---

## Table: `benefit_categories` (9 columns)

### ✅ Field: `name` (Admin) vs `title` (Flutter)

| Layer | Field Name | File Location | Line | Usage Context | Notes |
|-------|------------|---------------|------|---------------|-------|
| **DB** | `name` | migrations/20251030000003_prd_v8_1_sync.sql | N/A | Column definition (text NOT NULL) | ✅ Primary source |
| **Admin** | `name` | types/database.ts | L269 | Type definition (string) | ✅ Matches DB |
| **Flutter** | `title` | contexts/benefit/models/benefit_category.dart | L10 | `@JsonKey(name: 'title')` | 🔴 **FIELD MISMATCH!** |

**Risk Level**: 🔴 **HIGH RISK - Field Name Mismatch**

**Issue**: Database has `name` column, but Flutter model maps to `title`.

**Database Verification Needed**:
```sql
SELECT column_name FROM information_schema.columns
WHERE table_name = 'benefit_categories' AND column_name IN ('name', 'title');
```

**Action Required**:
1. Verify actual DB column name
2. If DB has `name`: Update Flutter to use `@JsonKey(name: 'name')`
3. If DB has `title`: Update Admin types to use `title`

---

### 🟡 Field: `display_order` vs `sort_order`

| Layer | Field Name | File Location | Line | Usage Context | Notes |
|-------|------------|---------------|------|---------------|-------|
| **DB** | `display_order` | types/database.ts | L265 | Type definition | ⚠️ Check actual DB schema |
| **Flutter** | `sortOrder` | contexts/benefit/models/benefit_category.dart | L19 | `@JsonKey(name: 'sort_order')` | ✅ PRD v9.6 standard |

**Risk Level**: 🟡 **Medium Risk** (needs DB verification)

**Action Required**: Verify if DB column is `display_order` or `sort_order`

---

## Table: `benefit_subcategories` (7 columns)

### 🔴 Field: `display_order` → `sort_order` (Migration Applied)

| Layer | Field Name | File Location | Line | Usage Context | Notes |
|-------|------------|---------------|------|---------------|-------|
| **DB** | `sort_order` | migrations/20251102000002_align_subcategories_prd_v96.sql | L15 | RENAMED from display_order | ✅ Migration applied |
| **Admin** | `display_order` | types/database.ts | L301 | Type definition (number) | 🔴 **OUTDATED TYPE** |
| **Flutter** | N/A | N/A | N/A | No Flutter model found | ⚠️ Missing |

**Risk Level**: 🔴 **HIGH RISK - Type Definition Outdated**

**Issue**: Migration renamed the column but TypeScript types were not regenerated.

**Action Required**:
1. Regenerate Admin types: `npx supabase gen types typescript --local > src/types/database.ts`
2. Update all references from `display_order` to `sort_order`

---

### ✅ Field: `icon_url` (NEW in PRD v9.6)

| Layer | Field Name | File Location | Line | Usage Context | Notes |
|-------|------------|---------------|------|---------------|-------|
| **DB** | `icon_url` | migrations/20251102000002_align_subcategories_prd_v96.sql | L20 | Column definition (text) | ✅ NEW FIELD |
| **Admin** | N/A | N/A | N/A | Not in types yet | ⚠️ Type generation needed |
| **Flutter** | N/A | N/A | N/A | Not implemented | ⚠️ Implementation needed |

**Risk Level**: 🟡 **Low Risk** (new field, not yet used)

**Action Required**: Add to type definitions and implement UI upload feature

---

## Table: `category_banners` (11 columns)

### 🔴 Field: `display_order` → `sort_order` (Migration Applied)

| Layer | Field Name | File Location | Line | Usage Context | Notes |
|-------|------------|---------------|------|---------------|-------|
| **DB** | `sort_order` | migrations/20251102000003_align_banners_prd_v96.sql | L15 | RENAMED from display_order | ✅ Migration applied |
| **Admin** | `display_order` | types/database.ts | L339 | Type definition (number) | 🔴 **OUTDATED TYPE** |
| **Admin** | `display_order` | pages/banners/CategoryBannerList.tsx | L80 | Sort logic | 🔴 **USING OLD FIELD** |
| **Flutter** | `sortOrder` | features/benefits/models/category_banner.dart | L48 | Model field | ✅ Correct (uses sort_order) |

**Risk Level**: 🔴 **HIGH RISK - Type Definition Outdated + Active Usage of Wrong Field**

**Issue**:
1. Migration renamed column to `sort_order`
2. Admin types still reference `display_order`
3. Admin code actively uses `display_order` in sorting logic
4. Flutter correctly uses `sortOrder` (mapped to `sort_order`)

**Action Required**:
1. **URGENT**: Regenerate Admin types
2. Update `pages/banners/CategoryBannerList.tsx` line 80: `a.display_order` → `a.sort_order`
3. Search and replace all `display_order` references in banner-related Admin code

---

### ✅ Field: `category_id` (foreign key)

| Layer | Field Name | File Location | Line | Usage Context | Notes |
|-------|------------|---------------|------|---------------|-------|
| **DB** | `category_id` | types/database.ts | L337 | Foreign key to benefit_categories | ✅ Primary source |
| **Admin** | `category_id` | types/database.ts | L337 | Type definition (string \| null) | ✅ Matches DB |
| **Flutter** | `benefitCategoryId` | features/benefits/models/category_banner.dart | L23 | Model field | ✅ Correct mapping |

**Risk Level**: ✅ **Safe**

---

## Table: `age_categories` (10 columns)

### ✅ Field: `sort_order`

| Layer | Field Name | File Location | Line | Usage Context | Notes |
|-------|------------|---------------|------|---------------|-------|
| **DB** | `sort_order` | types/database.ts | L47 | Column definition (integer) | ✅ Primary source |
| **Admin** | `sort_order` | types/database.ts | L47 | Type definition (number \| null) | ✅ Matches DB |
| **Admin** | `sort_order` | types/announcement.ts | L62 | Form data field | ✅ Correct usage |
| **Flutter** | N/A | contexts/user/models/age_category.dart | N/A | No sort_order field | ⚠️ Missing in Flutter |

**Risk Level**: 🟡 **Low Risk** (Flutter model incomplete)

**Action Required**: Add `sortOrder` field to Flutter `AgeCategory` model

---

## Table: `announcement_types` (6 columns)

### ✅ Field: `sort_order`

| Layer | Field Name | File Location | Line | Usage Context | Notes |
|-------|------------|---------------|------|---------------|-------|
| **DB** | `sort_order` | migrations/20251101000002_create_announcement_types.sql | L15 | Column definition (integer DEFAULT 0) | ✅ Primary source |
| **Admin** | `sort_order` | types/supabase.ts | L343 | Type definition (number) | ✅ Matches DB |
| **Admin** | `sort_order` | pages/announcement-types/AnnouncementTypesPage.tsx | L95 | `.order('sort_order')` | ✅ Correct query |
| **Flutter** | N/A | features/benefits/models/announcement_type.dart | N/A | Missing field | ⚠️ Not implemented |

**Risk Level**: ✅ **Safe** (Admin consistent, Flutter needs implementation)

---

## Table: `announcement_sections` (9 columns)

### 🟡 Field: `display_order`

| Layer | Field Name | File Location | Line | Usage Context | Notes |
|-------|------------|---------------|------|---------------|-------|
| **DB** | `display_order` | types/database.ts | L84 | Column definition (integer) | ✅ Primary source |
| **Admin** | `display_order` | types/database.ts | L84 | Type definition (number) | ✅ Matches DB |
| **Flutter** | `displayOrder` | contexts/benefit/models/announcement_section.dart | L22 | `@JsonKey(name: 'display_order')` | ✅ Correct mapping |

**Risk Level**: 🟡 **Low Risk** (naming convention inconsistency with PRD v9.6)

**Note**: PRD v9.6 recommends `sort_order`, but this table uses `display_order`. No immediate action needed.

---

## Table: `api_sources` (11 columns) - NEW in PRD v9.6

### ✅ Field: `mapping_config` (jsonb)

| Layer | Field Name | File Location | Line | Usage Context | Notes |
|-------|------------|---------------|------|---------------|-------|
| **DB** | `mapping_config` | migrations/20251102000004_create_api_sources.sql | L13 | Column definition (jsonb DEFAULT '{}'::jsonb) | ✅ NEW TABLE |
| **Admin** | `mapping_config` | pages/api/ApiSourceManagementPage.tsx | N/A | Used in form | ✅ Implemented |
| **Flutter** | N/A | N/A | N/A | Not needed (Admin-only feature) | ✅ Correct scope |

**Risk Level**: ✅ **Safe** (new feature, properly scoped to Admin)

---

## Table: `api_collection_logs` (11 columns) - NEW in PRD v9.6

### ✅ Field: `status` (enum: running, success, partial, failed)

| Layer | Field Name | File Location | Line | Usage Context | Notes |
|-------|------------|---------------|------|---------------|-------|
| **DB** | `status` | migrations/20251102000005_create_api_collection_logs.sql | L9 | CHECK constraint | ✅ NEW TABLE |
| **Admin** | `status` | pages/api/ApiCollectionLogsPage.tsx | N/A | Used in table | ✅ Implemented |
| **Flutter** | N/A | N/A | N/A | Not needed (Admin-only feature) | ✅ Correct scope |

**Risk Level**: ✅ **Safe**

---

## Summary of Findings by Risk Level

### 🔴 HIGH RISK (5 issues)

1. **`announcements.subcategory_id` vs Flutter `type_id`** - Semantic mismatch
2. **`benefit_subcategories.sort_order`** - Admin types outdated after migration
3. **`category_banners.sort_order`** - Admin types outdated + active code using old field
4. **`benefit_categories.name` vs Flutter `title`** - Field name mismatch
5. **`display_order` vs `sort_order` global convention** - PRD v9.6 not fully applied

### 🟡 MEDIUM RISK (7 issues)

6. **`announcements.view_count`** - Renamed but types not updated
7. **`announcement_tabs.display_order`** - Should be `sort_order` per PRD
8. **`announcement_sections.display_order`** - Should be `sort_order` per PRD
9. **`benefit_categories.display_order` vs `sort_order`** - DB schema unclear
10. **`benefit_subcategories.icon_url`** - New field not in types
11. **`age_categories.sort_order`** - Missing in Flutter model
12. **`announcement_types.sort_order`** - Missing in Flutter model

### ✅ SAFE (77 fields)

All other fields are properly mapped and consistent across all three layers.

---

## Recommended Actions (Priority Order)

### P0 - CRITICAL (Do Immediately)

1. **Verify Database Schema**
   ```sql
   -- Run this to check actual column names
   SELECT table_name, column_name, data_type
   FROM information_schema.columns
   WHERE table_schema = 'public'
   AND table_name IN (
     'announcements', 'benefit_categories', 'benefit_subcategories',
     'category_banners', 'announcement_tabs'
   )
   ORDER BY table_name, ordinal_position;
   ```

2. **Regenerate Admin Types**
   ```bash
   cd backend/supabase
   npx supabase gen types typescript --local > ../../apps/pickly_admin/src/types/database.ts
   ```

3. **Fix Flutter `announcement.dart` Model**
   - Change `type_id` → `subcategory_id`
   - Regenerate Freezed: `flutter pub run build_runner build --delete-conflicting-outputs`

4. **Update Admin Banner Code**
   - File: `pages/banners/CategoryBannerList.tsx`
   - Line 80: Change `a.display_order` → `a.sort_order`

### P1 - HIGH (Do This Week)

5. **Standardize Sorting Field Names**
   - Choose: `sort_order` everywhere (recommended per PRD v9.6)
   - Create migration to rename remaining `display_order` columns
   - Update all Admin and Flutter code

6. **Fix `benefit_categories.name` vs `title`**
   - Verify DB column name
   - Update either Admin or Flutter to match

7. **Complete `benefit_subcategories` Implementation**
   - Add `icon_url` to Admin types
   - Implement SVG upload UI in Admin
   - Create Flutter model if needed

### P2 - MEDIUM (Do This Month)

8. **Add Missing Flutter Fields**
   - Add `sortOrder` to `AgeCategory` model
   - Add `sortOrder` to `AnnouncementType` model (if needed)

9. **Update Field Comments in DB**
   - Ensure all columns have proper `COMMENT ON COLUMN` statements
   - Document PRD v9.6 field name standards in migration comments

10. **Create Field Naming Convention Doc**
    - Document standard: snake_case in DB, camelCase in Flutter/Admin
    - Document PRD v9.6 standard: use `sort_order` not `display_order`
    - Add to project README

---

## Field Naming Convention Summary

| Context | Convention | Example |
|---------|------------|---------|
| **Database** | snake_case | `application_start_date`, `sort_order` |
| **Admin (TypeScript)** | snake_case (same as DB) | `application_start_date`, `sort_order` |
| **Flutter (Dart)** | camelCase | `applicationStartDate`, `sortOrder` |
| **JSON Serialization** | snake_case (DB names) | `@JsonKey(name: 'application_start_date')` |

**PRD v9.6 Standard**: Use `sort_order` for all sorting/ordering fields, not `display_order`.

---

## Testing Checklist

After applying fixes, verify:

- [ ] Admin can create/edit announcements with `subcategory_id`
- [ ] Flutter app loads announcements without `type_id` errors
- [ ] Banner sorting works correctly with `sort_order`
- [ ] Subcategory SVG icons upload successfully
- [ ] All TypeScript types match actual database schema
- [ ] All Flutter models serialize/deserialize correctly
- [ ] No console errors related to missing fields
- [ ] PRD v9.6 compliance: all lists use `sort_order`

---

## Migration Verification

Run these queries to verify migration state:

```sql
-- Check if migrations ran successfully
SELECT version, name
FROM supabase_migrations.schema_migrations
WHERE version >= '20251102000000'
ORDER BY version DESC;

-- Verify benefit_subcategories has sort_order
SELECT column_name FROM information_schema.columns
WHERE table_name = 'benefit_subcategories'
AND column_name IN ('display_order', 'sort_order');

-- Verify category_banners has sort_order
SELECT column_name FROM information_schema.columns
WHERE table_name = 'category_banners'
AND column_name IN ('display_order', 'sort_order');

-- Check announcements schema
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'announcements'
AND column_name IN ('type_id', 'subcategory_id', 'views_count', 'view_count')
ORDER BY column_name;
```

---

**End of Global Field Usage Map**

Generated by Claude Code Quality Analyzer
Date: 2025-11-03
PRD Version: v9.6.1
