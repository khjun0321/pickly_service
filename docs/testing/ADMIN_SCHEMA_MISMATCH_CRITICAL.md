# 🚨 CRITICAL: Pickly Admin Schema Mismatch Report

## 📋 Issue Summary
**Date**: 2025-11-01
**Severity**: 🔴 **CRITICAL - Blocking All Announcement Operations**
**Status**: ⚠️ **REQUIRES ARCHITECTURAL DECISION**

---

## 🎯 Problem Statement

The Pickly Admin UI code and database schema have a **fundamental mismatch** that blocks all announcement CRUD operations.

### Current Error
```
Could not find the type_id column of announcements in the schema cache
```

### Root Cause
**The `announcements` table does NOT have a `type_id` column.**

---

## 🔍 Database Schema Analysis

### Actual Schema (PostgreSQL)

```sql
-- announcements table (21 columns)
CREATE TABLE announcements (
  id uuid PRIMARY KEY,
  title text NOT NULL,
  organization text NOT NULL,
  category_id uuid,              -- ✅ EXISTS (FK to benefit_categories)
  subcategory_id uuid,            -- ✅ EXISTS (FK to benefit_subcategories)
  thumbnail_url text,
  region text,
  application_start_date timestamptz,
  application_end_date timestamptz,
  deadline_date date,
  status text NOT NULL DEFAULT 'recruiting',  -- ✅ Correct values
  is_priority boolean NOT NULL DEFAULT false,
  detail_url text,
  link_type text DEFAULT 'none',
  content text,
  subtitle text,
  external_url text,
  is_featured boolean DEFAULT false,
  is_home_visible boolean DEFAULT false,
  display_priority integer DEFAULT 0,
  tags text[],
  search_vector tsvector,
  views_count integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Foreign Keys
FOREIGN KEY (category_id) REFERENCES benefit_categories(id)
FOREIGN KEY (subcategory_id) REFERENCES benefit_subcategories(id)

-- Constraints
CHECK (status IN ('recruiting', 'closed', 'upcoming', 'draft'))
```

### Separate Table: announcement_types

```sql
-- This table EXISTS but is NOT linked to announcements!
CREATE TABLE announcement_types (
  id uuid PRIMARY KEY,
  title text NOT NULL,
  description text,
  sort_order integer DEFAULT 0,
  is_active boolean DEFAULT true,
  benefit_category_id uuid NOT NULL,  -- FK to benefit_categories
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

FOREIGN KEY (benefit_category_id) REFERENCES benefit_categories(id) ON DELETE CASCADE
```

**KEY INSIGHT**: `announcement_types` has NO relationship to `announcements` table!

---

## 🧩 Schema Relationships

```
benefit_categories (주거, 취업, 교육, 건강, etc.)
    ├── benefit_subcategories (세부 분류)
    │       └── announcements (공고 데이터)
    │
    └── announcement_types (공고 유형 - ORPHANED!)
```

**Problem**: The UI tries to link `announcements.type_id` → `announcement_types.id`, but this foreign key **does NOT exist** in the database!

---

## 💥 Impact Analysis

### What's Broken ❌

1. **Announcement Creation**: Fails with 400 error
   - Payload includes `type_id` field
   - Database rejects unknown column

2. **Announcement Editing**: Fails similarly
   - Tries to update non-existent column

3. **Announcement Filtering**: Broken
   - `.in('type_id', typeIds)` returns no results

4. **Form Validation**: Inconsistent
   - Requires `type_id` which database doesn't accept

### What Still Works ✅

1. **Reading existing announcements** (SELECT queries don't fail)
2. **Category/subcategory structure** (correct schema)
3. **Authentication system** (working correctly)
4. **File uploads** (storage buckets operational)

---

## 🔧 Solution Options

### Option 1: Use Existing Schema (benefit_subcategories) ⭐ RECOMMENDED

**Approach**: Change UI to use `subcategory_id` instead of `type_id`

**Changes Required**:

1. **Query benefit_subcategories** instead of announcement_types:
   ```typescript
   const { data: subcategories } = useQuery({
     queryKey: ['benefit_subcategories', categoryId],
     queryFn: async () => {
       const { data, error } = await supabase
         .from('benefit_subcategories')
         .select('*')
         .eq('category_id', categoryId)
         .eq('is_active', true)
         .order('display_order')

       if (error) throw error
       return data
     }
   })
   ```

2. **Update form to use subcategory_id**:
   ```typescript
   const schema = z.object({
     category_id: z.string().nullable(),
     subcategory_id: z.string().min(1, '하위 카테고리를 선택하세요'),
     // ... other fields
   })
   ```

3. **Update INSERT/UPDATE queries**:
   ```typescript
   const { data, error } = await supabase
     .from('announcements')
     .insert({
       category_id: categoryId,
       subcategory_id: formData.subcategory_id,
       title: formData.title,
       // ... other fields
     })
   ```

**Pros**:
- ✅ Uses existing, correct schema
- ✅ No database migration needed
- ✅ Aligns with PRD intention (categories → subcategories → announcements)
- ✅ Faster implementation (1-2 hours)

**Cons**:
- ❌ `announcement_types` table becomes unused (can be dropped later)
- ❌ Requires UI refactoring

---

### Option 2: Add type_id Foreign Key to announcements

**Approach**: Create migration to add `type_id` column and link to `announcement_types`

**Migration Required**:
```sql
-- Add type_id column to announcements
ALTER TABLE announcements
ADD COLUMN type_id uuid;

-- Add foreign key constraint
ALTER TABLE announcements
ADD CONSTRAINT announcements_type_id_fkey
FOREIGN KEY (type_id)
REFERENCES announcement_types(id)
ON DELETE SET NULL;

-- Create index
CREATE INDEX idx_announcements_type_id
ON announcements(type_id)
WHERE type_id IS NOT NULL;

-- Optional: Migrate existing data
-- UPDATE announcements SET type_id = (SELECT id FROM announcement_types WHERE ...)
```

**Pros**:
- ✅ UI code works as-is (minimal changes)
- ✅ `announcement_types` becomes useful
- ✅ Can have both subcategory AND type classification

**Cons**:
- ❌ Database migration required
- ❌ Potential data inconsistency during migration
- ❌ Adds complexity (announcements would have 3 classification fields: category_id, subcategory_id, type_id)
- ❌ Slower implementation (requires testing migration)

---

### Option 3: Repurpose announcement_types as subcategories

**Approach**: Rename `benefit_subcategories` data model to use `announcement_types` table

**Changes Required**:
```sql
-- Drop benefit_subcategories table
DROP TABLE IF EXISTS benefit_subcategories CASCADE;

-- Rename announcement_types for clarity (optional)
-- Or: Keep announcement_types and change FK in announcements
ALTER TABLE announcements
ADD COLUMN type_id uuid;

ALTER TABLE announcements
ADD CONSTRAINT announcements_type_id_fkey
FOREIGN KEY (type_id)
REFERENCES announcement_types(id);

-- Migrate subcategory data to announcement_types
-- ... complex data migration
```

**Pros**:
- ✅ Consolidates classification system
- ✅ UI code works with minimal changes

**Cons**:
- ❌ MAJOR breaking change
- ❌ Requires extensive data migration
- ❌ Breaks mobile app if it uses benefit_subcategories
- ❌ High risk of data loss

---

## 🎯 Recommended Action Plan

### Phase 1: Immediate Fix (Option 1) ⭐

**Timeline**: 2-3 hours
**Risk**: Low

**Steps**:
1. Update `src/types/benefit.ts`:
   - Replace `type_id` with `category_id` and `subcategory_id`
   - Update `AnnouncementStatus` enum values

2. Update `AnnouncementManager.tsx`:
   - Change query from `announcement_types` to `benefit_subcategories`
   - Update form schema to use `subcategory_id`
   - Update all form default values
   - Update INSERT/UPDATE payloads

3. Test announcement creation:
   - Verify dropdown shows subcategories
   - Verify INSERT succeeds
   - Verify no 400 errors

4. Clean up:
   - Consider dropping `announcement_types` table (optional)
   - Or: Repurpose for different use case

---

### Phase 2: Long-term Solution (Future)

**Decision Required**: Should `announcement_types` be:
- **Option A**: Deleted (unused table)
- **Option B**: Linked to announcements (add type_id FK)
- **Option C**: Used for different purpose (e.g., template types)

**Recommendation**: Delete or repurpose announcement_types later, after confirming subcategories meet all requirements.

---

## 📊 PRD v8.9 Documentation Issue

### What PRD v8.9 Claims (INCORRECT)

From PRD v8.9 line 169:
```
✅ announcements (21 columns)
   ├── id, type_id, title, organization  // ❌ type_id DOES NOT EXIST
```

From PRD v8.9 line 178-182:
```
✅ announcement_types (7 columns)  -- Announcement categories
   ├── id, title, description, sort_order
   ├── is_active, benefit_category_id
   └── Seed Data: 10 types
```

**Implication**: PRD v8.9 is **outdated or incorrect** regarding schema structure.

### Actual Database Schema

```sql
-- announcements has:
category_id (FK → benefit_categories)
subcategory_id (FK → benefit_subcategories)

-- NO type_id column exists
```

---

## 🧪 Testing Checklist

### After Implementing Option 1:

- [ ] ✅ Navigate to announcements page
- [ ] ✅ Click "공고 추가"
- [ ] ✅ Dropdown shows benefit_subcategories (not announcement_types)
- [ ] ✅ Select subcategory from dropdown
- [ ] ✅ Fill form and submit
- [ ] ✅ INSERT succeeds (no 400 error)
- [ ] ✅ Announcement appears in list
- [ ] ✅ Edit existing announcement works
- [ ] ✅ Delete announcement works
- [ ] ✅ No console errors

---

## 📝 Implementation Code (Option 1)

### 1. Update Type Definitions

**File**: `src/types/benefit.ts`

```typescript
// ✅ CORRECT
export interface Announcement {
  id: string
  category_id: string | null
  subcategory_id: string | null
  title: string
  organization: string
  region: string | null
  thumbnail_url: string | null
  application_start_date: string | null
  status: AnnouncementStatus
  is_priority: boolean
  detail_url: string | null
  created_at: string
  updated_at: string
}

export interface AnnouncementFormData {
  category_id: string | null
  subcategory_id: string | null
  title: string
  organization: string
  region: string | null
  thumbnail_url: string | null
  application_start_date: string | null
  status: AnnouncementStatus
  is_priority: boolean
  detail_url: string | null
}

export type AnnouncementStatus = 'recruiting' | 'closed' | 'upcoming' | 'draft'
```

### 2. Update Query Logic

**File**: `src/pages/benefits/components/AnnouncementManager.tsx`

```typescript
// Query subcategories instead of announcement_types
const { data: subcategories = [] } = useQuery({
  queryKey: ['benefit_subcategories', categoryId],
  queryFn: async () => {
    const { data, error } = await supabase
      .from('benefit_subcategories')
      .select('*')
      .eq('category_id', categoryId)
      .eq('is_active', true)
      .order('display_order', { ascending: true })

    if (error) throw error
    return data as BenefitSubcategory[]
  },
})

// Query announcements by subcategory
const { data: announcements = [], isLoading } = useQuery({
  queryKey: ['announcements', categoryId],
  queryFn: async () => {
    let query = supabase
      .from('announcements')
      .select('*')
      .eq('category_id', categoryId)
      .order('is_priority', { ascending: false })
      .order('application_start_date', { ascending: false })

    const { data, error } = await query

    if (error) throw error
    return data as Announcement[]
  },
})
```

---

## 🎉 Expected Outcome

After implementing Option 1:
- ✅ Announcements page loads without errors
- ✅ Dropdown shows subcategories (not types)
- ✅ Form submission works (INSERT/UPDATE succeed)
- ✅ No "type_id column not found" errors
- ✅ Full CRUD functionality restored

---

## 📞 Next Steps

1. **Decide**: Which solution option to implement?
2. **Implement**: Chosen solution following this guide
3. **Test**: Using testing checklist above
4. **Update PRD**: Correct PRD v8.9 documentation
5. **Document**: Update this log with final implementation

---

**Generated**: 2025-11-01 21:10:00 KST
**By**: Claude Code Automation
**Priority**: 🔴 **CRITICAL - BLOCKING ALL ANNOUNCEMENTS**
**Recommended Solution**: Option 1 (Use benefit_subcategories)
**Estimated Fix Time**: 2-3 hours
