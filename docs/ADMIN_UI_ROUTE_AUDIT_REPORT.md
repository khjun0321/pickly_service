# Admin UI Route Audit Report
**Date**: 2025-11-02
**PRD Version**: v9.6.1
**Auditor**: Code Quality Analyzer

---

## Executive Summary

This audit analyzed the Pickly Admin UI routing structure to identify discrepancies between:
- Sidebar menu items (user-visible navigation)
- Registered routes in App.tsx
- Actual page component files

**Key Findings**:
- ✅ 6 properly connected pages accessible via sidebar
- ⚠️ 11 routes exist but are NOT accessible via sidebar menus
- 🚫 3 orphaned page files exist but are NOT registered in routes
- ❌ 1 broken route link (route defined but file doesn't exist)

---

## ✅ Properly Connected Pages

These pages are fully integrated: sidebar menu → route definition → actual file exists.

| Menu Label | Sidebar Path | Route Path | Page Component |
|------------|-------------|------------|----------------|
| 대시보드 | `/` | `/` (index) | `/pages/dashboard/Dashboard.tsx` |
| 홈 관리 | `/home-management` | `/home-management` | `/pages/home/HomeManagementPage.tsx` |
| 대분류 관리 | `/benefits/categories` | `/benefits/categories` | `/pages/benefits/CategoryManagementPage.tsx` |
| 하위분류 관리 | `/benefits/subcategories` | `/benefits/subcategories` | `/pages/benefits/SubcategoryManagementPage.tsx` |
| 배너 관리 | `/benefits/banners` | `/benefits/banners` | `/pages/benefits/BannerManagementPage.tsx` |
| 사용자·권한 | `/users` | `/users` | `/pages/users/UserList.tsx` |

**Total**: 6 pages

---

## ⚠️ Missing from Sidebar (Hidden/Backend Routes)

These routes are registered in App.tsx but NOT accessible via sidebar menus. Users cannot navigate to these pages through the UI.

### 🔴 **CRITICAL ISSUE**: Incorrect Sidebar Path

| Issue | Sidebar Config | Route Definition | Status |
|-------|---------------|------------------|--------|
| **공고 관리** mismatch | Sidebar: `/benefits/announcements` | Route: `/benefits/announcements-manage` | ❌ **BROKEN LINK** |

**Impact**: Clicking "공고 관리" in sidebar navigates to wrong path. Route exists at `/benefits/announcements-manage` but sidebar points to `/benefits/announcements`.

### Hidden Routes (Not in Sidebar)

| Route Path | Page Component | Category | Purpose |
|-----------|----------------|----------|---------|
| `/benefits/announcements-manage` | `/pages/benefits/AnnouncementManagementPage.tsx` | PRD v9.6 | **Should be in sidebar** |
| `/benefits/manage/:categorySlug` | `/pages/benefits/BenefitManagementPage.tsx` | v7.3 Legacy | Dynamic route for integrated CRUD |
| `/benefits/:categorySlug` | `/pages/benefits/BenefitCategoryPage.tsx` | Legacy | Dynamic category view |
| `/benefits/categories-old` | `/pages/benefits/BenefitCategoryList.tsx` | Legacy | Old category list (deprecated) |
| `/benefits/announcements` | `/pages/benefits/BenefitAnnouncementList.tsx` | Legacy | Legacy announcement list |
| `/benefits/announcements/new` | `/pages/benefits/BenefitAnnouncementForm.tsx` | Legacy | Legacy form (create) |
| `/age-categories` | `/pages/age-categories/AgeCategoriesPage.tsx` | System Config | Backend configuration |
| `/announcement-types` | `/pages/announcement-types/AnnouncementTypesPage.tsx` | System Config | Backend configuration |
| `/api/sources` | `/pages/api/ApiSourceManagementPage.tsx` | PRD v9.6 API | **Should be in sidebar** |
| `/api/collection-logs` | `/pages/api/ApiCollectionLogsPage.tsx` | PRD v9.6 API | **Should be in sidebar** |
| `/login` | `/pages/auth/Login.tsx` | Auth | Public route (not in sidebar) |

**Total**: 11 routes

### Routes That SHOULD Be Added to Sidebar (PRD v9.6 Compliance)

Based on PRD v9.6, these routes should be accessible:

1. **공고 관리** (Announcement Management)
   - Current sidebar path: `/benefits/announcements` ❌
   - Actual route: `/benefits/announcements-manage` ✅
   - **ACTION**: Update sidebar to point to correct path

2. **API 관리 Submenu** (Missing entirely)
   - Sidebar shows: `/api-management` (doesn't exist!) ❌
   - Should have submenu:
     - API 소스 관리: `/api/sources` ✅
     - 수집 로그: `/api/collection-logs` ✅
   - **ACTION**: Replace broken `/api-management` with expandable API submenu

---

## 🚫 Orphaned Page Files (Not in Routes)

These page files exist but are NOT registered in any route. They are completely unreachable.

| File Path | Component Name | Status |
|-----------|---------------|--------|
| `/pages/banners/CategoryBannerForm.tsx` | CategoryBannerForm | Unused/Legacy |
| `/pages/banners/CategoryBannerList.tsx` | CategoryBannerList | Unused/Legacy |
| `/pages/login/LoginPage.tsx` | LoginPage | Duplicate (using `/pages/auth/Login.tsx`) |

**Total**: 3 files

**Recommendation**: These files should either be:
- Deleted if truly unused (after verification)
- Registered in routes if needed for future features
- Documented as deprecated/legacy

---

## ❌ Broken Links (Routes Without Files)

These routes are defined in App.tsx but the actual page component file does NOT exist.

| Route Path | Expected File | Import Statement | Status |
|-----------|---------------|------------------|--------|
| `/benefits/announcements/:id/edit` | `AnnouncementEditCompletePage.tsx` | `import AnnouncementEditCompletePage from '@/pages/benefits/AnnouncementEditCompletePage'` | ❌ **FILE NOT FOUND** |

**Total**: 1 broken route

**Impact**: Navigating to this route will cause runtime error. The import will fail during build.

**Recommendation**:
- Either create the missing file
- Or remove the route definition if no longer needed
- Check if another component should be used instead

---

## 📊 Summary Statistics

| Metric | Count |
|--------|-------|
| **Total sidebar menu items** | 8 (6 direct + 2 bottom) |
| **Total routes defined** | 18 routes |
| **Total page files** | 23 files |
| **Properly connected pages** | 6 ✅ |
| **Routes missing from sidebar** | 11 ⚠️ |
| **Orphaned page files** | 3 🚫 |
| **Broken route links** | 1 ❌ |

---

## 🔧 Recommended Actions (Priority Order)

### 🔴 **HIGH PRIORITY** (Breaks functionality)

1. **Fix Broken Route Link**
   - Route: `/benefits/announcements/:id/edit`
   - Action: Create `AnnouncementEditCompletePage.tsx` OR remove route

2. **Fix Sidebar Path Mismatch**
   - Sidebar "공고 관리" points to: `/benefits/announcements`
   - Should point to: `/benefits/announcements-manage`
   - File: `src/components/common/Sidebar.tsx` line 45

3. **Fix Broken API Management Link**
   - Sidebar "API 관리" points to: `/api-management` (doesn't exist!)
   - Should be expandable submenu with:
     - `/api/sources`
     - `/api/collection-logs`

### 🟡 **MEDIUM PRIORITY** (PRD v9.6 compliance)

4. **Add API Management Submenu**
   - Create collapsible "API 관리" menu (like "혜택 관리")
   - Add "API 소스 관리" → `/api/sources`
   - Add "수집 로그" → `/api/collection-logs`

5. **Clean Up Legacy Routes**
   - Document which legacy routes are still needed
   - Consider removing:
     - `/benefits/categories-old`
     - `/benefits/announcements` (old list)
     - `/benefits/announcements/new` (old form)

### 🟢 **LOW PRIORITY** (Code cleanup)

6. **Remove Orphaned Files**
   - Delete unused banner components
   - Remove duplicate login page
   - Or add them to routes if needed

7. **Add System Config Menu** (Optional)
   - Create "시스템 설정" submenu for:
     - `/age-categories` (연령 카테고리)
     - `/announcement-types` (공고 유형)

---

## 📋 Detailed Analysis

### Sidebar Menu Structure (Current)

```
대시보드 → /
홈 관리 → /home-management
혜택 관리 ▼
  ├─ 대분류 관리 → /benefits/categories
  ├─ 하위분류 관리 → /benefits/subcategories
  ├─ 배너 관리 → /benefits/banners
  └─ 공고 관리 → /benefits/announcements ❌ WRONG PATH
API 관리 → /api-management ❌ ROUTE DOESN'T EXIST
사용자·권한 → /users
```

### Recommended Sidebar Structure (PRD v9.6 Compliant)

```
대시보드 → /
홈 관리 → /home-management
혜택 관리 ▼
  ├─ 대분류 관리 → /benefits/categories
  ├─ 하위분류 관리 → /benefits/subcategories
  ├─ 배너 관리 → /benefits/banners
  └─ 공고 관리 → /benefits/announcements-manage ✅ FIXED
API 관리 ▼ ✅ NEW SUBMENU
  ├─ API 소스 관리 → /api/sources
  └─ 수집 로그 → /api/collection-logs
시스템 설정 ▼ (Optional)
  ├─ 연령 카테고리 → /age-categories
  └─ 공고 유형 → /announcement-types
사용자·권한 → /users
```

---

## 🎯 Conclusion

The Pickly Admin UI has **3 critical issues** that need immediate attention:

1. Broken route link (missing file)
2. Sidebar path mismatch for announcement management
3. Broken API management menu link

Additionally, **11 routes exist but are hidden** from users, including important PRD v9.6 API management pages that should be accessible via sidebar.

**Next Steps**:
1. Fix the 3 critical issues listed above
2. Add API management submenu to sidebar
3. Clean up orphaned files
4. Document legacy vs. active routes
5. Consider adding system configuration submenu

---

**Audit completed**: 2025-11-02
**Reviewed files**: 26 total
**Issues identified**: 15 total
**Estimated fix time**: 2-3 hours
