# Flutter TabBar Implementation - Announcement Detail Screen

## Overview
Enhanced the announcement detail screen with dynamic TabBar functionality for displaying multiple announcement types (청년, 신혼부부, 고령자, etc.).

## Implementation Date
2025-10-27

## Changes Made

### 1. New Models Created

#### `announcement_tab.dart`
- Location: `/apps/pickly_mobile/lib/contexts/benefit/models/announcement_tab.dart`
- Purpose: Model for announcement tabs (평형별/연령별 정보)
- Database Table: `announcement_tabs`
- Key Fields:
  - `tab_name`: Tab display name (e.g., "16A 청년", "신혼부부")
  - `age_category_id`: Link to age category
  - `unit_type`: Housing unit type (e.g., "16㎡")
  - `floor_plan_image_url`: Floor plan image URL
  - `supply_count`: Number of units available
  - `income_conditions`: JSONB field for income requirements
  - `additional_info`: JSONB field for extra information
  - `display_order`: Tab ordering

#### `announcement_section.dart`
- Location: `/apps/pickly_mobile/lib/contexts/benefit/models/announcement_section.dart`
- Purpose: Model for modular announcement sections
- Database Table: `announcement_sections`
- Key Fields:
  - `section_type`: Type of section (basic_info, schedule, eligibility, housing_info, location, attachments)
  - `title`: Section title
  - `content`: JSONB field for flexible content structure
  - `display_order`: Section ordering
  - `is_visible`: Visibility toggle

### 2. Repository Updates

Updated `/apps/pickly_mobile/lib/contexts/benefit/repositories/announcement_repository.dart`:

- Added `getAnnouncementTabs(String announcementId)` method
- Added `getAnnouncementSections(String announcementId)` method
- Both methods query Supabase and order by `display_order`

### 3. Riverpod Providers

Updated `/apps/pickly_mobile/lib/features/benefit/providers/announcement_provider.dart`:

- `announcementTabsProvider`: Fetches tabs for announcement
- `announcementSectionsProvider`: Fetches sections for announcement
- **Cache Strategy**: All detail providers use `@Riverpod(keepAlive: false)` for automatic cache invalidation when screen is unmounted

### 4. UI Components

Updated `/apps/pickly_mobile/lib/features/benefit/screens/announcement_detail_screen.dart`:

#### Changed from StatefulWidget to ConsumerStatefulWidget
- Now uses Riverpod for state management
- Fetches data reactively from providers

#### New Widgets Added:

1. **`_UnitTypeTabBar`**: Horizontal scrollable tab selector
   - Displays tab names from database
   - Highlights selected tab
   - OnTap handler for tab selection

2. **`_UnitTypeContent`**: Content display for selected tab
   - Shows floor plan image (with error handling)
   - Displays supply count
   - Shows income conditions (deposit, monthly rent)
   - Displays eligibility conditions
   - Renders additional info from JSONB

3. **`_ImagesRow`**: Image gallery for section content
   - Horizontal scrollable image list
   - Extracts images from section content
   - Handles network errors gracefully

#### Dynamic Section Rendering
- `_buildSectionFromData()`: Parses JSONB content and renders appropriately
- Supports multiple content structures:
  - `items` array with icon/label/value objects
  - `text` field for plain text
  - Key-value pairs for structured data
  - `images` array for image galleries

### 5. Data Flow

```
Database (Supabase)
  ↓
Repository (announcement_repository.dart)
  ↓
Provider (announcement_provider.dart)
  ↓
UI (announcement_detail_screen.dart)
```

### 6. Cache Invalidation Strategy

**Automatic Cache Invalidation:**
- Used `@Riverpod(keepAlive: false)` annotation
- Providers automatically dispose when screen is unmounted
- Data is re-fetched on every screen entry
- Ensures users always see latest content

**Alternative (Manual) Strategy:**
```dart
// Can manually invalidate if needed:
ref.invalidate(announcementDetailProvider(id));
ref.invalidate(announcementTabsProvider(id));
ref.invalidate(announcementSectionsProvider(id));
```

## Features Implemented

### ✅ TabBar Functionality
- Dynamic tabs loaded from database
- Smooth tab selection
- Content switches based on selected tab

### ✅ Type-Specific Information Display
- Deposit amount
- Monthly rent
- Eligibility conditions
- Supply count
- Floor plan images

### ✅ Custom Content Rendering
- Flexible JSONB content parsing
- Support for multiple content types
- Image galleries
- Structured data display

### ✅ Cache Management
- Auto-refresh on screen entry
- Uses Supabase `updated_at` for tracking changes
- AutoDispose pattern for memory efficiency

### ✅ Error Handling
- Graceful loading states
- Error boundaries for network issues
- Fallback UI for missing images
- Empty state handling

## Database Schema Alignment

Aligned with PRD v7.0 schema:

### announcement_tabs
```sql
CREATE TABLE announcement_tabs (
  id uuid PRIMARY KEY,
  announcement_id uuid REFERENCES announcements(id),
  tab_name text NOT NULL,
  age_category_id uuid REFERENCES age_categories(id),
  unit_type text,
  floor_plan_image_url text,
  supply_count integer,
  income_conditions jsonb,
  additional_info jsonb,
  display_order integer DEFAULT 0,
  created_at timestamp
);
```

### announcement_sections
```sql
CREATE TABLE announcement_sections (
  id uuid PRIMARY KEY,
  announcement_id uuid REFERENCES announcements(id),
  section_type text CHECK (section_type IN ('basic_info', 'schedule', 'eligibility', 'housing_info', 'location', 'attachments')),
  title text,
  content jsonb NOT NULL,
  display_order integer DEFAULT 0,
  is_visible boolean DEFAULT true,
  created_at timestamp,
  updated_at timestamp
);
```

## Usage Example

### For Admin Panel (Creating Tabs)

```typescript
// Example: Create a tab for young adults
await supabase
  .from('announcement_tabs')
  .insert({
    announcement_id: 'uuid-here',
    tab_name: '16A 청년',
    age_category_id: 'youth-category-id',
    unit_type: '16㎡',
    floor_plan_image_url: 'https://storage.url/floorplan.jpg',
    supply_count: 200,
    income_conditions: {
      deposit: '3,284만원',
      monthly_rent: '13.8만원',
      eligible_condition: '만 19-39세, 무주택, 월 소득 300만원 이하'
    },
    additional_info: {
      location: '경기도 하남시',
      move_in_date: '2028.09'
    },
    display_order: 1
  });
```

### For Admin Panel (Creating Sections)

```typescript
// Example: Create a schedule section
await supabase
  .from('announcement_sections')
  .insert({
    announcement_id: 'uuid-here',
    section_type: 'schedule',
    title: '일정',
    content: {
      items: [
        {
          icon: '📅',
          label: '접수 기간',
          value: '2025.09.30 - 2025.11.30'
        },
        {
          icon: '',
          label: '당첨자 발표',
          value: '2025.12.25'
        }
      ]
    },
    display_order: 2,
    is_visible: true
  });
```

## Testing Checklist

- [ ] Tabs display correctly from database
- [ ] Tab selection works smoothly
- [ ] Content switches when tab changes
- [ ] Images load with error handling
- [ ] Cache invalidates on screen entry
- [ ] Empty states show appropriately
- [ ] Loading states display correctly
- [ ] Section content renders properly
- [ ] JSONB parsing handles all structures
- [ ] No memory leaks (AutoDispose working)

## Files Modified

1. `/apps/pickly_mobile/lib/contexts/benefit/models/announcement_tab.dart` (NEW)
2. `/apps/pickly_mobile/lib/contexts/benefit/models/announcement_section.dart` (NEW)
3. `/apps/pickly_mobile/lib/contexts/benefit/repositories/announcement_repository.dart` (UPDATED)
4. `/apps/pickly_mobile/lib/features/benefit/providers/announcement_provider.dart` (UPDATED)
5. `/apps/pickly_mobile/lib/features/benefit/screens/announcement_detail_screen.dart` (UPDATED)

## Related Documentation

- PRD v7.0: Database schema specification
- Database Schema: `/backend/supabase/migrations/20251027000001_correct_schema.sql`
- Admin Development Guide: `/docs/prd/admin-development-guide.md`

## Next Steps

1. **Backend Setup**: Create sample data in Supabase for testing
2. **Admin Panel**: Build UI for managing tabs and sections
3. **User Testing**: Validate UX with real announcement data
4. **Performance**: Monitor cache performance and adjust if needed
5. **Analytics**: Track which tabs users interact with most

## Notes

- Used existing `SelectionCard` pattern for consistent UI
- Followed PRD constraints (no modifications to design system)
- Maintained existing file structure and patterns
- All changes are backward compatible
- Ready for integration with admin panel
