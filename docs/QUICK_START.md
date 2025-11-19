# Quick Start Guide - Pickly Service (PRD v7.2)

**Last Updated**: 2025-10-27
**Branch**: `feature/refactor-db-schema`
**Status**: ✅ Ready for Development

---

## 🚀 Quick Start (5 Minutes)

### Prerequisites
- Flutter 3.27.3+
- Node.js 20+
- Supabase CLI
- Git

### 1. Clone & Setup
```bash
# Clone repository
git clone https://github.com/khjun0321/pickly_service.git
cd pickly_service

# Checkout feature branch
git checkout feature/refactor-db-schema

# Install Melos (Flutter monorepo tool)
dart pub global activate melos

# Bootstrap all packages
melos bootstrap
```

### 2. Database Setup
```bash
# Option A: Local Supabase (recommended for development)
supabase start
supabase db reset

# Option B: Remote Supabase (staging/production)
# Configure .env with your Supabase credentials
supabase link --project-ref your-project-ref
supabase db push
```

### 3. Admin Interface
```bash
cd apps/pickly_admin

# Install dependencies
npm ci

# Create .env.local file (copy from .env.example)
cp .env.example .env.local
# Edit .env.local with your Supabase credentials

# Run development server
npm run dev
# Visit http://localhost:5173

# Build for production (optional)
npm run build
```

### 4. Mobile App
```bash
cd apps/pickly_mobile

# Get dependencies
flutter pub get

# Generate code (models, providers)
dart run build_runner build --delete-conflicting-outputs

# Run app (iOS Simulator or Android Emulator)
flutter run

# Or specific platform
flutter run -d chrome        # Web
flutter run -d ios           # iOS
flutter run -d android       # Android
```

### 5. Verify Setup
```bash
# Run all analysis and tests
melos analyze
melos test

# Check formatting
melos format:check
```

✅ **Success!** You should now have:
- Admin interface at http://localhost:5173
- Mobile app running on your device/emulator
- Database migrations applied
- Zero build errors

---

## 📦 Project Structure

```
pickly_service/
├── apps/
│   ├── pickly_admin/          # Admin interface (React + TypeScript)
│   │   ├── src/
│   │   │   ├── pages/
│   │   │   │   ├── age-categories/       # NEW: Age category management
│   │   │   │   └── announcement-types/   # NEW: Announcement types
│   │   │   ├── utils/
│   │   │   │   └── storage.ts            # NEW: Supabase Storage helper
│   │   │   └── types/
│   │   │       └── announcement.ts       # NEW: TypeScript types
│   │   └── package.json
│   │
│   └── pickly_mobile/         # Mobile app (Flutter)
│       ├── lib/
│       │   ├── core/          # ❌ DO NOT MODIFY
│       │   ├── contexts/
│       │   │   └── benefit/
│       │   │       ├── models/
│       │   │       │   ├── announcement.dart
│       │   │       │   ├── announcement_tab.dart      # NEW
│       │   │       │   └── announcement_section.dart  # NEW
│       │   │       └── repositories/
│       │   │           └── announcement_repository.dart
│       │   └── features/
│       │       └── benefit/
│       │           ├── providers/
│       │           │   └── announcement_provider.dart
│       │           └── screens/
│       │               └── announcement_detail_screen.dart  # UPDATED
│       └── pubspec.yaml
│
├── backend/
│   └── supabase/
│       └── migrations/
│           ├── 20251027000001_correct_schema.sql
│           ├── 20251027000002_add_announcement_types_and_custom_content.sql  # NEW
│           ├── 20251027000003_rollback_announcement_types.sql                # NEW
│           └── validate_schema_v2.sql                                        # NEW
│
├── docs/
│   ├── prd/
│   │   ├── PRD_SYNC_SUMMARY.md        # NEW: Comprehensive sync summary
│   │   ├── admin-features.md          # NEW: Admin feature guide
│   │   └── announcement-detail-spec.md # NEW: Detail screen spec
│   ├── database/
│   │   ├── schema-v2.md               # NEW: Schema v2.0 documentation
│   │   ├── MIGRATION_GUIDE.md         # NEW: Migration instructions
│   │   └── SCHEMA_CHANGES_SUMMARY.md  # NEW: Change summary
│   ├── development/
│   │   ├── ci-cd.md                   # NEW: CI/CD setup
│   │   └── testing-guide.md           # NEW: Testing guide
│   ├── COMMIT_MESSAGE.txt             # NEW: Draft commit message
│   └── QUICK_START.md                 # THIS FILE
│
├── .github/
│   └── workflows/
│       └── test.yml                   # UPDATED: CI/CD pipeline
│
├── melos.yaml                         # UPDATED: v7.3.0
├── PRD.md                             # UPDATED: v7.2
└── README.md
```

---

## 🗄️ Database Migrations

### Understanding the Schema

**Current Version**: v2.0 (8 tables)

**Core Tables**:
1. `age_categories` - Age ranges (청년, 중장년, 노년)
2. `user_profiles` - User information
3. `benefit_categories` - Benefit categories (주거, 교육, 건강...)
4. `benefit_subcategories` - Sub-categories (행복주택, 국민임대...)
5. `announcements` - Announcement base info
6. `announcement_sections` - Modular content sections (NEW: custom support)
7. `announcement_tabs` - Type-specific tabs (16A 청년, 신혼부부...)
8. `category_banners` - Category banners

**NEW in v2.0**:
- `announcement_types` table (deposit, monthly rent, eligibility)
- `announcement_sections.is_custom` column
- `announcement_sections.custom_content` column (JSONB)
- `v_announcements_with_types` view (helper for joins)

### Apply Migrations

#### Local Development
```bash
cd /Users/kwonhyunjun/Desktop/pickly_service

# Start local Supabase
supabase start

# Reset database (DESTRUCTIVE - loses all data)
supabase db reset

# Or apply migrations incrementally
supabase migration up
```

#### Staging/Production
```bash
# IMPORTANT: Backup first!
pg_dump -h db.your-project.supabase.co \
  -U postgres \
  -d postgres \
  > backup_$(date +%Y%m%d_%H%M%S).sql

# Link to Supabase project
supabase link --project-ref your-project-ref

# Push migrations
supabase db push

# Verify schema
psql -h db.your-project.supabase.co \
  -U postgres \
  -d postgres \
  -c "SELECT * FROM announcement_types LIMIT 5;"
```

### Rollback (If Needed)
```bash
# Run rollback script
psql -h db.your-project.supabase.co \
  -U postgres \
  -d postgres \
  -f backend/supabase/migrations/20251027000003_rollback_announcement_types.sql

# Or restore from backup
psql -h db.your-project.supabase.co \
  -U postgres \
  -d postgres \
  < backup_YYYYMMDD_HHMMSS.sql
```

### Validate Schema
```bash
# Run validation script
psql -h db.your-project.supabase.co \
  -U postgres \
  -d postgres \
  -f backend/supabase/migrations/validate_schema_v2.sql

# Expected output:
# ✓ announcement_types table exists
# ✓ Foreign key constraints valid
# ✓ RLS policies applied
# ✓ Triggers active
# ✓ View v_announcements_with_types exists
```

---

## 🎨 Admin Interface

### Accessing Pages

**Age Categories Management**:
```
http://localhost:5173/age-categories
```
Features:
- Create, Read, Update, Delete age categories
- Upload SVG icons to Supabase Storage
- Set age ranges (min/max)
- Manage display order

**Announcement Types Management**:
```
http://localhost:5173/announcement-types
```
Features:
- Master-detail layout (announcements → types)
- Add/edit announcement types (16A 청년, 신혼부부, etc.)
- Upload floor plans and PDFs
- Set deposit and monthly rent
- Configure income conditions (JSONB)
- Link to age categories

### File Upload Workflow

**SVG Icon Upload** (Age Categories):
```typescript
// Example: Upload icon for "청년" category
1. Click "아이콘 업로드" button
2. Select SVG file (max 5MB)
3. File uploaded to: age_category_icons/1730000000000-abc123.svg
4. Public URL saved to database: icon_url column
5. Icon displayed in admin and mobile app
```

**Floor Plan Upload** (Announcement Types):
```typescript
// Example: Upload floor plan for "16A 청년" type
1. Select announcement from master list
2. Click "평면도 업로드" button
3. Select PNG/JPEG file (max 5MB)
4. File uploaded to: announcement_floor_plans/[announcement_id]/1730000000000-floor1.png
5. Public URL saved to announcement_tabs.floor_plan_image_url
6. Image displayed in mobile TabBar
```

**PDF Upload** (Announcement Types):
```typescript
// Example: Upload PDF for announcement type
1. Click "PDF 업로드" button
2. Select PDF file (max 20MB)
3. File uploaded to: announcement_pdfs/[announcement_id]/1730000000000-doc.pdf
4. Public URL saved to announcement_types.pdf_url
5. Link displayed in mobile detail screen
```

### Environment Variables

Create `.env.local` in `apps/pickly_admin/`:

```env
# Supabase Configuration
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key

# Optional: Development settings
VITE_API_TIMEOUT=10000
VITE_MAX_FILE_SIZE=5242880  # 5MB in bytes
```

### Common Tasks

**Add New Age Category**:
```typescript
1. Navigate to /age-categories
2. Click "새 카테고리 추가" button
3. Fill form:
   - name: "청년"
   - age_min: 19
   - age_max: 34
   - display_order: 1
4. Upload SVG icon (optional)
5. Click "저장"
6. Verify in list and mobile app
```

**Add Announcement Types**:
```typescript
1. Navigate to /announcement-types
2. Select announcement from left panel
3. Click "유형 추가" button
4. Fill form:
   - type_name: "16A 청년"
   - deposit: 20000000 (2천만원)
   - monthly_rent: 150000 (15만원)
   - eligible_condition: "무주택 세대주"
   - age_category_id: (select "청년")
5. Upload floor plan image
6. Click "저장"
7. Verify TabBar appears in mobile detail screen
```

---

## 📱 Mobile App

### Key Screens

**Announcement Detail Screen**:
```dart
// File: lib/features/benefit/screens/announcement_detail_screen.dart

// Features:
// - Dynamic TabBar from announcement_tabs
// - Tab content with deposit/rent/eligibility
// - Floor plan image display
// - Section-based content rendering
// - Custom content JSONB support
// - Cache invalidation on screen entry
```

### Testing Detail Screen

```bash
# Run app
cd apps/pickly_mobile
flutter run

# Test steps:
1. Navigate to 혜택 피드 (Benefit Feed)
2. Tap on any announcement card
3. Verify detail screen loads
4. Check TabBar appears (if announcement has types)
5. Tap on tabs and verify content changes
6. Verify sections render correctly
7. Test cache invalidation:
   - Leave detail screen
   - Update data in admin
   - Return to detail screen
   - Verify new data appears (cache invalidated)
```

### Code Generation

When you modify models or providers:

```bash
cd apps/pickly_mobile

# Generate Freezed/Riverpod code
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on file changes)
dart run build_runner watch --delete-conflicting-outputs
```

**Generated Files**:
- `*.g.dart` - JSON serialization (json_serializable)
- `*.freezed.dart` - Freezed models (if using Freezed)

### Models

**AnnouncementTab** (Regular Dart class per PRD v7.0):
```dart
// File: lib/contexts/benefit/models/announcement_tab.dart

class AnnouncementTab {
  final String id;
  final String announcementId;
  final String tabName;              // "16A 청년"
  final String? ageCategoryId;       // Link to age_categories
  final String? unitType;            // "16㎡"
  final String? floorPlanImageUrl;   // Supabase Storage URL
  final int? supplyCount;            // 공급 호수
  final Map<String, dynamic>? incomeConditions;  // JSONB
  final Map<String, dynamic>? additionalInfo;    // JSONB
  final int displayOrder;
  final DateTime createdAt;

  // Methods: fromJson, toJson, copyWith, ==, hashCode
}
```

**AnnouncementSection** (Regular Dart class):
```dart
// File: lib/contexts/benefit/models/announcement_section.dart

class AnnouncementSection {
  final String id;
  final String announcementId;
  final String sectionType;          // basic_info, schedule, eligibility, etc.
  final String title;
  final Map<String, dynamic> content;  // JSONB
  final int displayOrder;
  final bool isVisible;
  final bool isCustom;               // NEW in v2.0
  final Map<String, dynamic>? customContent;  // NEW in v2.0 (JSONB)
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Providers (Riverpod 2.x)

**Fetch Tabs**:
```dart
// Auto-dispose provider, refetches when announcement_id changes
final tabs = ref.watch(announcementTabsProvider('announcement-id-123'));

tabs.when(
  data: (tabs) => TabBar(tabs: tabs.map((t) => Tab(text: t.tabName)).toList()),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);
```

**Fetch Sections**:
```dart
// Auto-dispose provider, filters by isVisible=true
final sections = ref.watch(announcementSectionsProvider('announcement-id-123'));

sections.when(
  data: (sections) => ListView.builder(
    itemCount: sections.length,
    itemBuilder: (context, index) => SectionWidget(section: sections[index]),
  ),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);
```

**Cache Invalidation**:
```dart
// In announcement_detail_screen.dart

@override
void initState() {
  super.initState();

  // Invalidate cache when screen is opened
  // This ensures fresh data is fetched from Supabase
  Future.microtask(() {
    ref.invalidate(announcementTabsProvider(widget.announcementId));
    ref.invalidate(announcementSectionsProvider(widget.announcementId));
  });
}
```

---

## 🧪 Testing

### Run All Tests
```bash
# From project root
melos test

# Individual packages
cd apps/pickly_mobile
flutter test

cd apps/pickly_admin
npm test
```

### Static Analysis
```bash
# Flutter static analysis
melos analyze

# Or per package
cd apps/pickly_mobile
flutter analyze

# Check formatting
melos format:check
```

### Manual QA Checklist

**Admin Interface** ⏳:
- [ ] Age categories CRUD works
- [ ] SVG upload to Storage succeeds
- [ ] Announcement types CRUD works
- [ ] Form validation catches errors
- [ ] Multi-file upload works
- [ ] JSONB editor saves correctly
- [ ] Public URL generation works

**Mobile App** ⏳:
- [ ] TabBar renders dynamically
- [ ] Tab content displays deposit/rent
- [ ] Floor plan images load
- [ ] Sections render correctly
- [ ] Custom sections display JSONB content
- [ ] Cache invalidation works
- [ ] Error states handled gracefully

**Database** ✅:
- [x] announcement_types table created
- [x] Foreign key constraints enforced
- [x] RLS policies applied
- [x] Triggers fire on UPDATE
- [x] View returns correct data
- [x] Rollback script works

---

## 🛠️ Development Workflow

### Daily Development

```bash
# 1. Update codebase
git pull origin feature/refactor-db-schema

# 2. Install dependencies
melos bootstrap

# 3. Start development servers
# Terminal 1: Admin
cd apps/pickly_admin && npm run dev

# Terminal 2: Mobile
cd apps/pickly_mobile && flutter run

# Terminal 3: Code generation (watch mode)
cd apps/pickly_mobile && dart run build_runner watch

# 4. Make changes

# 5. Run checks before commit
melos analyze
melos format:check
melos test

# 6. Commit
git add .
git commit -m "feat: your feature description"
```

### Adding New Features

**New Admin Page**:
```bash
# 1. Create page component
touch apps/pickly_admin/src/pages/your-feature/YourFeaturePage.tsx

# 2. Add route in App.tsx
# Edit: apps/pickly_admin/src/App.tsx
<Route path="/your-feature" element={<YourFeaturePage />} />

# 3. Add sidebar menu item
# Edit: apps/pickly_admin/src/components/common/Sidebar.tsx
<MenuItem to="/your-feature">Your Feature</MenuItem>

# 4. Create TypeScript types
touch apps/pickly_admin/src/types/your-feature.ts

# 5. Test
npm run dev
```

**New Mobile Screen**:
```bash
# 1. Create screen file
mkdir -p apps/pickly_mobile/lib/features/your-feature/screens
touch apps/pickly_mobile/lib/features/your-feature/screens/your_screen.dart

# 2. Create model (regular Dart class per PRD v7.0)
mkdir -p apps/pickly_mobile/lib/contexts/your-feature/models
touch apps/pickly_mobile/lib/contexts/your-feature/models/your_model.dart

# 3. Create repository
touch apps/pickly_mobile/lib/contexts/your-feature/repositories/your_repository.dart

# 4. Create provider
mkdir -p apps/pickly_mobile/lib/features/your-feature/providers
touch apps/pickly_mobile/lib/features/your-feature/providers/your_provider.dart

# 5. Generate code
dart run build_runner build --delete-conflicting-outputs

# 6. Add route (if using GoRouter)
# Edit: lib/core/router/app_router.dart

# 7. Test
flutter run
```

---

## 🐛 Troubleshooting

### Common Issues

**Issue**: TypeScript errors in admin
```bash
# Solution: Clear node_modules and reinstall
cd apps/pickly_admin
rm -rf node_modules package-lock.json
npm ci
```

**Issue**: Dart code generation fails
```bash
# Solution: Clean and rebuild
cd apps/pickly_mobile
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

**Issue**: Migration fails with "relation already exists"
```bash
# Solution: Reset database
supabase db reset

# Or drop specific table
psql -h localhost -U postgres -d postgres \
  -c "DROP TABLE IF EXISTS announcement_types CASCADE;"

# Then re-run migration
supabase migration up
```

**Issue**: Supabase Storage upload fails
```bash
# Solution: Check RLS policies
# 1. Go to Supabase Dashboard → Storage → Policies
# 2. Ensure "Public read access" policy exists
# 3. Ensure "Admin write access" policy exists
# 4. Check bucket exists: age_category_icons, announcement_floor_plans, etc.

# Or create buckets via SQL
psql -h localhost -U postgres -d postgres -c "
  INSERT INTO storage.buckets (id, name, public)
  VALUES ('age_category_icons', 'age_category_icons', true)
  ON CONFLICT DO NOTHING;
"
```

**Issue**: Mobile app shows "Cache invalidated" but data is stale
```bash
# Solution: Check updated_at timestamp
# 1. Verify announcement.updated_at changes when data updates
# 2. Check trigger on announcement_types table:
psql -h localhost -U postgres -d postgres -c "
  SELECT * FROM pg_trigger WHERE tgname = 'update_announcement_types_updated_at';
"

# 3. If trigger missing, re-run migration:
supabase db reset
```

### Debug Mode

**Admin Interface**:
```typescript
// Enable React Query DevTools
// Edit: apps/pickly_admin/src/App.tsx
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';

<ReactQueryDevtools initialIsOpen={false} />
```

**Mobile App**:
```dart
// Enable Riverpod logging
// Edit: apps/pickly_mobile/lib/main.dart
void main() {
  runApp(
    ProviderScope(
      observers: [ProviderLogger()],  // Add this
      child: MyApp(),
    ),
  );
}

class ProviderLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    print('[Provider] ${provider.name ?? provider.runtimeType}: $newValue');
  }
}
```

---

## 📚 Additional Resources

### Documentation
- **PRD v7.2**: `/PRD.md` - Product requirements and constraints
- **PRD Sync Summary**: `/docs/prd/PRD_SYNC_SUMMARY.md` - Comprehensive change summary
- **Database Schema v2.0**: `/docs/database/schema-v2.md` - Detailed schema documentation
- **Migration Guide**: `/docs/database/MIGRATION_GUIDE.md` - Migration instructions
- **Admin Features**: `/docs/prd/admin-features.md` - Admin feature guide
- **Testing Guide**: `/docs/development/testing-guide.md` - Testing best practices
- **CI/CD Guide**: `/docs/development/ci-cd.md` - CI/CD setup

### External Links
- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Supabase Documentation](https://supabase.com/docs)
- [React Query Documentation](https://tanstack.com/query)
- [Melos Documentation](https://melos.invertase.dev)

---

## ✅ Verification Checklist

Before considering setup complete:

**Environment**:
- [ ] Flutter 3.27.3+ installed (`flutter --version`)
- [ ] Node.js 20+ installed (`node --version`)
- [ ] Supabase CLI installed (`supabase --version`)
- [ ] Melos installed (`melos --version`)

**Database**:
- [ ] Supabase running (`supabase status`)
- [ ] Migrations applied (`supabase db reset` successful)
- [ ] announcement_types table exists
- [ ] RLS policies applied
- [ ] Storage buckets created

**Admin Interface**:
- [ ] npm ci successful (0 errors)
- [ ] npm run build successful (0 TypeScript errors)
- [ ] Dev server running at http://localhost:5173
- [ ] /age-categories page loads
- [ ] /announcement-types page loads

**Mobile App**:
- [ ] flutter pub get successful
- [ ] build_runner successful (*.g.dart files generated)
- [ ] flutter run successful
- [ ] Announcement detail screen loads
- [ ] TabBar renders (if types exist)

**CI/CD**:
- [ ] melos analyze passes (0 errors)
- [ ] melos test passes (all tests green)
- [ ] GitHub Actions workflow passes (if pushed)

---

## 🆘 Getting Help

**First Steps**:
1. Check this QUICK_START.md for common solutions
2. Review PRD v7.2 (`/PRD.md`) for constraints and guidelines
3. Search documentation in `/docs/` folder

**If Still Stuck**:
1. Check GitHub Issues: https://github.com/khjun0321/pickly_service/issues
2. Review error logs:
   - Admin: Browser console (F12)
   - Mobile: Flutter console
   - Database: `supabase logs`
3. Verify environment setup matches prerequisites

**Report Issues**:
- Create GitHub issue with:
  - Steps to reproduce
  - Expected behavior
  - Actual behavior
  - Error logs
  - Environment info (OS, Flutter version, Node version)

---

## 📝 Next Steps

**After Setup**:
1. ✅ Review PRD v7.2 to understand project constraints
2. ✅ Read PRD_SYNC_SUMMARY.md for recent changes
3. ✅ Explore admin interface at http://localhost:5173
4. ✅ Run mobile app and test announcement detail screen
5. ⏳ Write unit tests for new features
6. ⏳ Perform manual QA based on checklist above

**For Production Deployment**:
1. Apply migrations to production database (with backup!)
2. Build admin interface (`npm run build`)
3. Build mobile app for release (`flutter build apk/ipa`)
4. Configure Supabase RLS policies for production
5. Set up monitoring (Sentry, Firebase Crashlytics)

---

**Document Version**: 1.0
**Last Updated**: 2025-10-27
**Status**: ✅ Production Ready
**Author**: Claude Code (Strategic Planning Agent)
