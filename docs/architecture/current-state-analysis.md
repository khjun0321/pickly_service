# Pickly Service - Current State Architecture Analysis

**Analysis Date**: 2025-10-27
**PRD Version**: v7.0
**Analyzed By**: System Architecture Designer

---

## Executive Summary

This analysis evaluates the current Pickly service architecture against PRD v7.0 requirements, identifying alignment, gaps, and recommended actions for Phase 1 MVP development.

**Key Findings**:
- ✅ Database schema aligned with PRD v7.0 (8 core tables)
- ⚠️ Mobile app has hardcoded announcement detail screen (needs dynamic rendering)
- ⚠️ Admin backoffice partially implemented (missing section builder, tab management)
- ✅ Design system well-structured and reusable
- ⚠️ Missing comprehensive announcement repository pattern

---

## 1. Database Schema Analysis

### 1.1 Current State (Migration: 20251027000001_correct_schema.sql)

**Implemented Tables** (8 total - matches PRD v7.0):

| Table | Status | PRD Alignment | Notes |
|-------|--------|---------------|-------|
| `benefit_categories` | ✅ Complete | 100% | Main categories (주거, 교육, 건강...) |
| `benefit_subcategories` | ✅ Complete | 100% | Sub-categories (행복주택, 국민임대...) |
| `announcements` | ✅ Complete | 100% | Core announcement metadata |
| `announcement_sections` | ✅ Complete | 100% | Modular section system |
| `announcement_tabs` | ✅ Complete | 100% | Unit type/age-specific tabs |
| `category_banners` | ✅ Complete | 100% | Category-specific banners |
| `age_categories` | ✅ Complete | 100% | Age-based categorization |
| `user_profiles` | ✅ Complete | 100% | User onboarding data |

### 1.2 Schema Design Strengths

**Modular Section System** (`announcement_sections`):
```sql
section_type IN (
  'basic_info',      -- 기본 정보
  'schedule',        -- 일정
  'eligibility',     -- 신청 자격
  'housing_info',    -- 단지 정보
  'location',        -- 위치
  'attachments'      -- 첨부 파일
)
```
- ✅ Flexible content structure via JSONB
- ✅ Supports dynamic rendering
- ✅ Backoffice can freely compose sections

**Tab System** (`announcement_tabs`):
```sql
-- Supports unit-type specific details:
- tab_name: "16A 청년", "신혼부부"
- floor_plan_image_url: Direct upload support
- income_conditions: JSONB for flexible data
- additional_info: JSONB for extensibility
```

### 1.3 Database Gaps

**No Critical Gaps Identified** ✅

Minor considerations:
- Storage buckets configuration not documented in migrations
- RPC functions for view count increment may need implementation
- Full-text search index (`search_vector`) requires population strategy

---

## 2. Mobile App Architecture (Flutter)

### 2.1 Directory Structure

```
apps/pickly_mobile/lib/
├── core/                          # ❌ DO NOT MODIFY (per CLAUDE.md)
│   ├── router.dart
│   ├── network/
│   ├── services/
│   └── theme/
├── contexts/                      # ❌ DO NOT MODIFY
│   ├── benefit/models/
│   │   └── announcement.dart     # Regular Dart class (PRD v7.0 compliant)
│   └── [other contexts]/
├── features/
│   ├── onboarding/               # ✅ Complete
│   ├── benefits/                 # ⚠️ Mixed implementation
│   ├── benefit/ (singular)       # ⚠️ Duplicate naming, needs consolidation
│   └── housing/                  # ⚠️ LH-specific (Phase 2?)
└── packages/pickly_design_system/ # ✅ Well-structured, DO NOT MODIFY
```

### 2.2 Announcement Detail Screen Analysis

**Current Implementation**: `apps/pickly_mobile/lib/features/benefit/screens/announcement_detail_screen.dart`

**Critical Issues**:

1. **Hardcoded UI** ❌
```dart
// Line 68-163: Static section cards
_SectionCard(title: '기본 정보', children: [...]), // Hardcoded!
_SectionCard(title: '일정', children: [...]),       // Hardcoded!
_SectionCard(title: '신청 자격', children: [...]),  // Hardcoded!
IncomeSectionWidget(...),                          // Hardcoded!
_ComplexInfoCard(),                                // Hardcoded!
_UnitTypesSection(),                               // Hardcoded!
```

**PRD v7.0 Requirement**: Dynamic rendering based on `announcement_sections` table

2. **Missing Data Models** ⚠️
```dart
// Current: announcement_detail_models.dart exists but not integrated
// AnnouncementSection, AnnouncementField, HousingType models defined
// But screen doesn't use them for dynamic rendering
```

3. **No Backend Integration** ❌
- No Supabase query for sections/tabs
- No Repository pattern usage
- Hardcoded data only

### 2.3 Mobile App Strengths

**Well-Implemented Features**:
- ✅ Onboarding flow (region, age category, interests)
- ✅ Category navigation system
- ✅ Banner display system
- ✅ Design system integration

**Models Correctly Refactored** (per recent PRD v7.0):
```dart
// contexts/benefit/models/announcement.dart
class Announcement {
  final String id;
  final String title;
  // ... matches DB schema exactly (no @freezed, regular class)
}
```

### 2.4 Mobile App Gaps

| Gap | Priority | Impact |
|-----|----------|--------|
| Dynamic section rendering | 🔴 High | Core feature for MVP |
| Repository pattern for announcements | 🔴 High | Data layer missing |
| Tab-based unit type switching | 🔴 High | Required for housing announcements |
| Section builder integration | 🔴 High | Backoffice-driven content |
| External URL handling | 🟡 Medium | "공고문 보러가기" button exists |

---

## 3. Admin Backoffice Architecture (React/TypeScript)

### 3.1 Directory Structure

```
apps/pickly_admin/src/
├── api/
│   ├── announcements.ts          # ⚠️ References old schema
│   ├── categories.ts             # ✅ Correct
│   └── banners.ts                # ✅ Correct
├── components/
│   ├── benefits/                 # Mixed quality
│   │   ├── MultiBannerManager.tsx
│   │   └── AnnouncementTable.tsx
│   └── shared/
│       └── FileUploader.tsx      # ✅ Good
├── pages/
│   └── benefits/
│       ├── BenefitAnnouncementForm.tsx  # ⚠️ Incomplete
│       └── BenefitAnnouncementList.tsx
└── types/
    └── database.ts               # ✅ Correct TypeScript types
```

### 3.2 Announcement Form Analysis

**File**: `apps/pickly_admin/src/pages/benefits/BenefitAnnouncementForm.tsx`

**Current Capabilities**:
- ✅ Basic info (title, subtitle, organization)
- ✅ Category/subcategory selection
- ✅ Thumbnail upload to Supabase Storage
- ✅ External URL link
- ✅ Tags management
- ✅ Status (recruiting/closed/draft)
- ✅ Featured flag

**Critical Missing Features** (PRD v7.0 requirements):

1. **Section Builder** ❌
```typescript
// MISSING: Drag-and-drop section composer
// Should allow:
// - Add section (basic_info, schedule, eligibility, etc.)
// - Reorder sections (display_order)
// - Configure content per section type
// - Toggle visibility (is_visible)
```

2. **Tab Management** ❌
```typescript
// MISSING: Unit type/age category tabs
// Should allow:
// - Create tabs ("16A 청년", "신혼부부")
// - Upload floor plan images (floor_plan_image_url)
// - Set income conditions (JSONB input)
// - Set supply count
// - Reorder tabs (display_order)
```

3. **Content Editor** ❌
```typescript
// MISSING: Rich content input for sections
// Section content is JSONB - needs flexible input system
// Different section types need different field structures
```

### 3.3 API Layer Issues

**File**: `apps/pickly_admin/src/api/announcements.ts`

**Problems**:
```typescript
// Line 72-102: fetchAnnouncementById() queries non-existent tables
benefit_categories (icon, color)      // ❌ Wrong fields (should be icon_url)
announcement_unit_types (...)         // ❌ Table doesn't exist! (Use announcement_tabs)
announcement_sections (metadata)       // ⚠️ Field doesn't exist
```

**Should be**:
```typescript
.select(`
  *,
  benefit_categories!inner(id, name, icon_url),
  announcement_sections!inner(
    id, section_type, title, content, display_order, is_visible
  ),
  announcement_tabs!inner(
    id, tab_name, unit_type, floor_plan_image_url,
    supply_count, income_conditions, display_order
  )
`)
```

### 3.4 TypeScript Types

**File**: `apps/pickly_admin/src/types/database.ts`

**Status**: ✅ Mostly correct, generated from Supabase schema

**Minor Issues**:
- Lines 182-183: Contains `application_start_date`, `application_end_date` fields
  - These exist in types but NOT in PRD v7.0 schema
  - Should be stored in `announcement_sections` with type='schedule'

---

## 4. Design System Analysis

### 4.1 Structure

```
packages/pickly_design_system/lib/
├── tokens/
│   └── design_tokens.dart        # Colors, spacing, typography
├── widgets/
│   ├── buttons/
│   ├── cards/
│   ├── navigation/
│   ├── tabs/
│   └── app_header.dart           # Reusable header component
└── pickly_design_system.dart     # Main export
```

### 4.2 Strengths

- ✅ Comprehensive token system (BackgroundColors, TextColors, Spacing)
- ✅ Reusable widget library (buttons, cards, headers)
- ✅ Consistent naming conventions
- ✅ Well-documented with examples
- ✅ Successfully used across mobile app

### 4.3 Recommendations

**DO NOT MODIFY** design system per CLAUDE.md constraints.

For announcement detail screen:
- Use existing `_SectionCard` pattern but populate dynamically
- Leverage `IncomeSectionWidget` for income-specific sections
- Create new widgets in `apps/pickly_mobile/lib/features/benefit/widgets/` if needed

---

## 5. Monorepo Configuration

### 5.1 Melos Setup

**File**: `/Users/kwonhyunjun/Desktop/pickly_service/melos.yaml`

```yaml
packages:
  - apps/**           # Mobile + Admin
  - packages/**       # Design system

scripts:
  analyze: flutter analyze     # Code quality
  test: flutter test          # Testing
  build:android: flutter build appbundle
  format: dart format .
```

**Assessment**: ✅ Standard Flutter monorepo setup, no issues

### 5.2 Storage Buckets

**Required Buckets** (per PRD v7.0):
1. `benefit-images` - Announcement thumbnails
2. `floor-plans` - Unit type floor plan images
3. `attachments` - PDF/document uploads (future)

**Current Status**: ⚠️ Not documented in migrations, needs Supabase dashboard setup

---

## 6. Current vs Required Comparison

### 6.1 Phase 1 MVP Features

| Feature | Required (PRD) | Mobile App | Admin Backoffice | Priority |
|---------|---------------|-----------|-----------------|----------|
| **Onboarding** | | | | |
| Region selection | ✅ | ✅ Complete | N/A | - |
| Age category selection | ✅ | ✅ Complete | ✅ CRUD exists | - |
| Interest categories | ✅ | ✅ Complete | N/A | - |
| **Benefit Feed** | | | | |
| Category tabs (인기, 주거...) | ✅ | ✅ Complete | ✅ CRUD exists | - |
| Category banners | ✅ | ✅ Complete | ✅ CRUD exists | - |
| Subcategory filters | ✅ | ⚠️ Partial | ✅ CRUD exists | 🟡 Medium |
| Announcement list cards | ✅ | ✅ Complete | N/A | - |
| **Announcement Detail** | | | | |
| Dynamic section rendering | ✅ | ❌ Hardcoded | N/A | 🔴 HIGH |
| Basic info section | ✅ | ✅ Static | ✅ Form exists | 🟡 Medium |
| Schedule section | ✅ | ✅ Static | ❌ Missing | 🔴 HIGH |
| Eligibility section | ✅ | ✅ Static | ❌ Missing | 🔴 HIGH |
| Housing info section | ✅ | ✅ Static | ❌ Missing | 🔴 HIGH |
| Location section | ✅ | ✅ Static | ❌ Missing | 🔴 HIGH |
| Attachments section | ✅ | ❌ Missing | ❌ Missing | 🟡 Medium |
| Unit type tabs | ✅ | ✅ Static | ❌ Missing | 🔴 HIGH |
| Floor plan images | ✅ | ✅ Placeholder | ❌ No upload | 🔴 HIGH |
| External link | ✅ | ✅ Complete | ✅ Complete | - |
| **Admin - Categories** | | | | |
| Age category CRUD | ✅ | N/A | ✅ Complete | - |
| Benefit category CRUD | ✅ | N/A | ✅ Complete | - |
| Subcategory CRUD | ✅ | N/A | ⚠️ Partial | 🟡 Medium |
| **Admin - Announcements** | | | | |
| Basic info form | ✅ | N/A | ✅ Complete | - |
| Section builder | ✅ | N/A | ❌ Missing | 🔴 HIGH |
| Tab manager | ✅ | N/A | ❌ Missing | 🔴 HIGH |
| Thumbnail upload | ✅ | N/A | ✅ Complete | - |
| **Admin - Banners** | | | | |
| Category banner CRUD | ✅ | N/A | ✅ Complete | - |
| Image upload | ✅ | N/A | ✅ Complete | - |
| Display order | ✅ | N/A | ✅ Complete | - |

---

## 7. Architecture Diagrams

### 7.1 Current Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         Pickly Service                          │
└─────────────────────────────────────────────────────────────────┘

┌──────────────────┐        ┌──────────────────┐        ┌──────────────────┐
│   Mobile App     │◄──────►│   Supabase DB    │◄──────►│  Admin Panel     │
│   (Flutter)      │  REST  │   (PostgreSQL)   │  REST  │  (React/TS)      │
└──────────────────┘        └──────────────────┘        └──────────────────┘
        │                            │                            │
        │                            │                            │
        ▼                            ▼                            ▼
┌──────────────────┐        ┌──────────────────┐        ┌──────────────────┐
│  Design System   │        │  Supabase Auth   │        │   File Uploads   │
│  (Shared Pkg)    │        │  (Users/RLS)     │        │   (Storage API)  │
└──────────────────┘        └──────────────────┘        └──────────────────┘

DATABASE SCHEMA (8 tables):
┌─────────────────────────────────────────────────────────────────┐
│ USER & ONBOARDING                                               │
│ • age_categories (연령 카테고리)                                │
│ • user_profiles (사용자 프로필)                                 │
├─────────────────────────────────────────────────────────────────┤
│ CATEGORY SYSTEM                                                 │
│ • benefit_categories (혜택 카테고리)                            │
│ • benefit_subcategories (서브 카테고리)                         │
│ • category_banners (카테고리별 배너)                            │
├─────────────────────────────────────────────────────────────────┤
│ ANNOUNCEMENT SYSTEM (Modular!)                                  │
│ • announcements (공고 기본 정보)                                │
│ • announcement_sections (섹션 - JSONB content)                  │
│ • announcement_tabs (평형별 탭)                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 7.2 Required Data Flow (Announcement Detail)

```
CURRENT (❌ Hardcoded):
┌──────────────────┐
│  Detail Screen   │
│  ┌────────────┐  │
│  │ Static UI  │  │  ← Hardcoded sections
│  │  - 기본정보 │  │
│  │  - 일정    │  │
│  │  - 자격    │  │
│  └────────────┘  │
└──────────────────┘

REQUIRED (✅ Dynamic):
┌──────────────────┐        ┌─────────────────────────────────┐
│  Detail Screen   │        │  Supabase Query                 │
│  ┌────────────┐  │        │  ┌───────────────────────────┐  │
│  │ Dynamic UI │◄─┼────────┼──┤ announcement_sections     │  │
│  │  (Builder) │  │        │  │ - section_type            │  │
│  └────────────┘  │        │  │ - content (JSONB)         │  │
│                  │        │  │ - display_order           │  │
│  ┌────────────┐  │        │  └───────────────────────────┘  │
│  │  Tab View  │◄─┼────────┼──┤ announcement_tabs         │  │
│  │  (Units)   │  │        │  │ - tab_name                │  │
│  └────────────┘  │        │  │ - floor_plan_image_url    │  │
└──────────────────┘        │  │ - income_conditions       │  │
                            │  └───────────────────────────┘  │
                            └─────────────────────────────────┘

FLOW:
1. User taps announcement card
2. Navigate to detail screen with announcement_id
3. Fetch:
   - announcements (basic info)
   - announcement_sections (ordered by display_order)
   - announcement_tabs (ordered by display_order)
4. Render sections dynamically based on section_type
5. Render tabs for unit types
6. Display external_url button
```

---

## 8. Files Requiring Modification

### 8.1 Mobile App (Flutter)

**Priority: HIGH** 🔴

1. **Create Repository Pattern**
   - `apps/pickly_mobile/lib/features/benefit/repositories/announcement_repository.dart`
   - Methods: `fetchAnnouncementDetail(id)`, `fetchSections(id)`, `fetchTabs(id)`

2. **Refactor Detail Screen**
   - `apps/pickly_mobile/lib/features/benefit/screens/announcement_detail_screen.dart`
   - Replace hardcoded sections with dynamic builder
   - Use existing models from `announcement_detail_models.dart`

3. **Create Section Widgets**
   - `apps/pickly_mobile/lib/features/benefit/widgets/section_renderer.dart`
   - Switch on `section_type` to render appropriate UI
   - Reuse existing `_SectionCard`, `IncomeSectionWidget`, etc.

4. **Create Tab Widget**
   - `apps/pickly_mobile/lib/features/benefit/widgets/unit_type_tabs.dart`
   - Dynamic tab rendering based on `announcement_tabs`
   - Floor plan image display

**Files to NOT Modify** ❌:
- `apps/pickly_mobile/lib/core/**`
- `apps/pickly_mobile/lib/contexts/**`
- `packages/pickly_design_system/**`

### 8.2 Admin Backoffice (React/TypeScript)

**Priority: HIGH** 🔴

1. **Fix API Layer**
   - `apps/pickly_admin/src/api/announcements.ts`
   - Update `fetchAnnouncementById()` query (lines 72-102)
   - Remove references to `announcement_unit_types`
   - Use correct `announcement_sections` and `announcement_tabs`

2. **Create Section Builder Component**
   - `apps/pickly_admin/src/components/announcements/SectionBuilder.tsx`
   - Drag-and-drop section ordering
   - Section type selector (basic_info, schedule, etc.)
   - JSONB content editor per section type
   - Add/remove/reorder sections

3. **Create Tab Manager Component**
   - `apps/pickly_admin/src/components/announcements/TabManager.tsx`
   - Add/remove tabs
   - Floor plan image uploader
   - Income conditions JSONB editor
   - Tab reordering

4. **Extend Announcement Form**
   - `apps/pickly_admin/src/pages/benefits/BenefitAnnouncementForm.tsx`
   - Add Tab 3: "섹션 구성" (Section Builder)
   - Add Tab 4: "평형 정보" (Tab Manager)
   - Integrate new components

5. **Create Section Editor Components** (per section type)
   - `apps/pickly_admin/src/components/announcements/sections/BasicInfoEditor.tsx`
   - `apps/pickly_admin/src/components/announcements/sections/ScheduleEditor.tsx`
   - `apps/pickly_admin/src/components/announcements/sections/EligibilityEditor.tsx`
   - `apps/pickly_admin/src/components/announcements/sections/HousingInfoEditor.tsx`
   - `apps/pickly_admin/src/components/announcements/sections/LocationEditor.tsx`
   - `apps/pickly_admin/src/components/announcements/sections/AttachmentsEditor.tsx`

### 8.3 Backend (Supabase)

**Priority: MEDIUM** 🟡

1. **Storage Buckets Setup** (via Supabase Dashboard)
   - Create bucket: `benefit-images` (public)
   - Create bucket: `floor-plans` (public)
   - Create bucket: `attachments` (public, future)

2. **RLS Policies Review**
   - Verify policies in migration are sufficient
   - Add admin-only write policies if needed

3. **Full-Text Search Population** (optional, Phase 2)
   - Create trigger to populate `search_vector` on announcements
   - Index tags array for filtering

---

## 9. Implementation Roadmap

### 9.1 Phase 1A: Core Data Layer (Week 1)

**Goal**: Enable dynamic data flow

1. **Mobile Repository** (2 days)
   - Create `AnnouncementRepository`
   - Implement Supabase queries for sections/tabs
   - Add error handling and caching

2. **Admin API Fix** (1 day)
   - Update `announcements.ts` queries
   - Remove deprecated fields
   - Add type safety

3. **Storage Setup** (0.5 days)
   - Create Supabase storage buckets
   - Configure public access policies

### 9.2 Phase 1B: Admin Section Builder (Week 2-3)

**Goal**: Backoffice can create structured announcements

1. **Section Builder UI** (5 days)
   - Drag-and-drop interface
   - Section type selector
   - Content editors per type
   - Save to `announcement_sections`

2. **Tab Manager UI** (3 days)
   - Tab creation/editing
   - Floor plan uploader
   - Income conditions input
   - Save to `announcement_tabs`

3. **Integration** (2 days)
   - Connect to Announcement Form
   - E2E testing (create → view in DB)

### 9.3 Phase 1C: Mobile Dynamic Rendering (Week 4)

**Goal**: Mobile app displays backoffice-created content

1. **Section Renderer** (3 days)
   - Create dynamic widget builder
   - Switch on `section_type`
   - Map JSONB to UI components

2. **Tab Widget** (2 days)
   - Dynamic tab bar
   - Floor plan display
   - Income info rendering

3. **Integration & Polish** (2 days)
   - Connect to repository
   - Loading states
   - Error handling
   - E2E testing

### 9.4 Phase 1D: Testing & Refinement (Week 5)

1. **Data Flow Testing**
   - Admin creates announcement → Mobile displays correctly
   - Section ordering works
   - Tab switching works

2. **Edge Cases**
   - Empty sections
   - Missing images
   - Long content

3. **Polish**
   - Loading skeletons
   - Error messages
   - Image optimization

---

## 10. Risk Assessment

### 10.1 High Risks 🔴

| Risk | Impact | Mitigation |
|------|--------|------------|
| Section JSONB structure inconsistency | High | Define strict TypeScript/Dart types for each section_type |
| Admin UX complexity (section builder) | High | Start with simple list-based UI, iterate to drag-drop |
| Mobile performance (many sections) | Medium | Implement virtualization for long announcements |

### 10.2 Medium Risks 🟡

| Risk | Impact | Mitigation |
|------|--------|------------|
| Storage bucket quotas | Medium | Monitor usage, implement image compression |
| RLS policy gaps | Medium | Thorough testing with different user roles |
| Migration from hardcoded to dynamic | Medium | Feature flag for gradual rollout |

### 10.3 Low Risks 🟢

| Risk | Impact | Mitigation |
|------|--------|------------|
| Design system limitations | Low | Extend in feature folder if needed |
| Monorepo tooling | Low | Melos is stable and well-documented |

---

## 11. Technology Stack Validation

### 11.1 Frontend (Mobile)

**Flutter + Riverpod** ✅
- Pros: Strong typing, hot reload, mature ecosystem
- Cons: None identified
- Status: Well-utilized, good state management

**GoRouter** ✅
- Pros: Type-safe navigation, deep linking support
- Status: Correctly implemented in `core/router.dart`

### 11.2 Frontend (Admin)

**React + TypeScript** ✅
- Pros: Fast development, huge ecosystem
- Status: Good practices observed

**MUI (Material-UI)** ✅
- Pros: Professional components, consistent design
- Status: Well-integrated

**TanStack Query** ✅
- Pros: Excellent caching, automatic refetching
- Status: Used correctly in forms

**React Hook Form + Zod** ✅
- Pros: Type-safe forms, great DX
- Status: Properly implemented

### 11.3 Backend

**Supabase** ✅
- Pros: PostgreSQL, Auth, Storage, RLS all-in-one
- Cons: Vendor lock-in (mitigated by PostgreSQL compatibility)
- Status: Schema well-designed

**PostgreSQL** ✅
- Pros: JSONB support (critical for flexible sections), full-text search
- Status: Using JSONB effectively

---

## 12. Recommended Next Actions

### 12.1 Immediate (This Week)

1. **Review and Approve** this analysis with stakeholders
2. **Prioritize** gaps based on business impact
3. **Create** detailed technical specifications for:
   - Mobile: Section renderer architecture
   - Admin: Section builder UX/UI mockups
4. **Set up** Supabase storage buckets

### 12.2 Short-term (Next 2 Weeks)

1. **Implement** Mobile repository layer
2. **Fix** Admin API queries
3. **Build** Section Builder MVP (list-based UI)
4. **Build** Tab Manager MVP

### 12.3 Medium-term (3-4 Weeks)

1. **Refactor** Mobile detail screen to dynamic rendering
2. **Enhance** Admin section builder (drag-drop)
3. **E2E testing** of full announcement creation → viewing flow
4. **Performance optimization** (image caching, lazy loading)

---

## 13. Conclusion

The Pickly service architecture is **solid** with a well-designed database schema that perfectly aligns with PRD v7.0. The main gaps are in **implementation of dynamic features** rather than fundamental design flaws.

**Strengths**:
- ✅ Modular database design enables flexibility
- ✅ Clear separation of concerns (mobile/admin/design system)
- ✅ Modern tech stack with good tooling
- ✅ Monorepo structure supports code sharing

**Critical Path to MVP**:
1. Mobile repository layer
2. Admin section builder
3. Mobile dynamic section renderer
4. Integration testing

**Estimated Effort**: 4-5 weeks with 1-2 developers focusing on critical path items.

**Recommendation**: Proceed with implementation following the roadmap in Section 9, starting with Phase 1A (Core Data Layer).

---

## Appendix A: File Inventory

### A.1 Mobile App Key Files

```
apps/pickly_mobile/lib/
├── core/
│   ├── router.dart (8,436 bytes)
│   └── [protected - do not modify]
├── contexts/
│   └── benefit/models/
│       └── announcement.dart (Regular Dart class, PRD v7.0 compliant)
├── features/
│   ├── benefit/
│   │   ├── models/
│   │   │   └── announcement_detail_models.dart (160 lines)
│   │   ├── screens/
│   │   │   └── announcement_detail_screen.dart (564 lines, NEEDS REFACTOR)
│   │   ├── widgets/
│   │   │   ├── income_section_widget.dart
│   │   │   └── [create more here]
│   │   └── providers/
│   │       └── announcement_provider.dart
│   └── onboarding/ (✅ Complete)
```

### A.2 Admin Backoffice Key Files

```
apps/pickly_admin/src/
├── api/
│   └── announcements.ts (343 lines, NEEDS UPDATE)
├── pages/benefits/
│   └── BenefitAnnouncementForm.tsx (928 lines, NEEDS EXTENSION)
├── components/
│   └── [CREATE announcements/ folder for new components]
└── types/
    └── database.ts (606 lines, ✅ Correct)
```

### A.3 Database Migration Files

```
backend/supabase/migrations/
├── 20251007035747_onboarding_schema.sql
├── 20251007999999_update_icon_urls.sql
├── 20251010000000_age_categories_update.sql
└── 20251027000001_correct_schema.sql (✅ Primary schema, 263 lines)
```

---

**End of Analysis**

*Generated by: System Architecture Designer*
*Date: 2025-10-27*
*For: Pickly Service Phase 1 MVP Development*
