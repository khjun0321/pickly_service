# 📘 Pickly PRD v9.9.1 — Icon Asset Management Policy (Design vs Data)

**Version**: 9.9.1
**Date**: 2025-11-06
**Status**: ✅ Active
**Purpose**: 아이콘을 '디자인 고정형'과 '데이터 연동형'으로 구분해 UI 일관성과 유지보수성을 확보

---

## 🎯 Purpose

Pickly 모바일 앱에서 사용하는 아이콘을 두 가지 유형으로 명확히 분류하여:
1. **디자인 일관성** 유지 (UI 컴포넌트 고정)
2. **데이터 유연성** 확보 (Admin에서 변경 가능한 컨텐츠)
3. **유지보수성** 향상 (변경 범위 명확화)

### 🔥 Major Change
**fire.svg → popular.svg 전면 교체**
- 기존 `fire.svg`는 의미가 불명확하여 `popular.svg`로 통일
- DB 데이터 마이그레이션 필요

---

## 🧱 Policy Overview

### Icon Classification Matrix

| 구분 | 예시 | 관리 위치 | DB 저장 규칙 | 변경 가능 여부 |
|------|------|-----------|--------------|----------------|
| **디자인 고정형** | SearchBar, TabBar, Button, EmptyState | `pickly_design_system/assets/icons/` | DB 미저장 (코드에서 asset 직접 참조) | ❌ 불가 (디자인 시스템 변경 필요) |
| **데이터 연동형** | 혜택 카테고리, 공고 썸네일, 필터칩 아이콘 | Supabase Storage (`benefit-icons`) | **파일명만 저장** (예: `popular.svg`) | ✅ 가능 (Admin에서 업로드/교체) |

---

## 🧩 Implementation Rules

### 1️⃣ 디자인 고정형 아이콘

**특징**:
- UI 컴포넌트의 일부로 고정
- 디자인 시스템 업데이트 시에만 변경
- 코드에서 직접 asset 경로 참조

**구현**:
```dart
// ✅ CORRECT: Design System Asset
SvgPicture.asset(
  'assets/icons/search.svg',
  package: 'pickly_design_system',
  width: 24,
  height: 24,
)
```

**파일 위치**:
```
packages/pickly_design_system/assets/icons/
├── search.svg
├── filter.svg
├── menu.svg
├── back.svg
├── close.svg
└── ... (UI 컴포넌트 전용)
```

### 2️⃣ 데이터 연동형 아이콘

**특징**:
- Admin에서 업로드/교체 가능
- DB에는 **파일명만** 저장 (경로 금지)
- 앱은 자동으로 asset/network 판별

**구현**:
```dart
// ✅ CORRECT: Dynamic Icon Loading
final iconUrl = category.iconUrl; // "popular.svg" (파일명만)
final resolvedUrl = await resolveIconUrl(iconUrl);

if (resolvedUrl.startsWith('asset://')) {
  // Local asset exists
  SvgPicture.asset(resolvedUrl.replaceFirst('asset://', ''));
} else {
  // Load from Supabase Storage
  SvgPicture.network(resolvedUrl);
}
```

**DB 저장 규칙**:
```sql
-- ✅ CORRECT: 파일명만 저장
icon_url = 'popular.svg'

-- ❌ WRONG: 경로 포함
icon_url = '/icons/popular.svg'
icon_url = 'assets/icons/popular.svg'
icon_url = 'http://..../popular.svg'
```

**파일 위치**:
- **Supabase Storage**: `benefit-icons/` 버킷
- **Local Fallback**: `packages/pickly_design_system/assets/icons/` (optional)

---

## 📁 File Naming Convention

### Standard Names (표준 파일명)

| Category | File Name | Description |
|----------|-----------|-------------|
| 인기 | `popular.svg` | 🔥 Changed from `fire.svg` |
| 주거 | `home.svg` | House/Housing |
| 교육 | `book.svg` | Education/School |
| 건강 | `heart.svg` | Health/Medical |
| 교통 | `bus.svg` | Transportation |
| 복지 | `welfare.svg` | Welfare/Support |
| 취업 | `briefcase.svg` | Employment/Job |
| 지원 | `money.svg` | Financial Support |
| 문화 | `theater.svg` | Culture/Arts |

### Naming Rules

1. **소문자만 사용**: `popular.svg` ✅ / `Popular.svg` ❌
2. **하이픈/언더스코어**: `young_man.svg`, `old-man.svg` ✅
3. **특수문자 금지**: `인기.svg`, `주거!.svg` ❌
4. **확장자 필수**: `.svg` (PNG/JPG는 별도 정책)

---

## 🔄 Migration Plan: fire.svg → popular.svg

### Phase 1: DB Update
```sql
-- Update all fire.svg references to popular.svg
UPDATE public.benefit_categories
SET icon_url = 'popular.svg'
WHERE icon_url IN ('fire.svg', 'flame.svg', 'hot.svg', '/icons/fire.svg');
```

### Phase 2: Storage Update
```bash
# In Supabase Storage (benefit-icons bucket)
1. Upload new file: popular.svg
2. Delete old file: fire.svg (after verification)
```

### Phase 3: Design System Update
```bash
# In pickly_design_system/assets/icons/
mv fire.svg popular.svg  # Rename local asset
```

### Phase 4: Code References
All code using `iconUrl` from DB will automatically use new filename.
No code changes needed if using `resolveIconUrl()` utility.

---

## ✅ PRD Requirements Checklist

### UI Design Requirements
- [x] 써클탭의 모양/간격/활성 스타일은 디자인 시스템 고정
- [x] 텍스트(title)와 아이콘(icon_url)만 DB에서 동적 교체 가능
- [x] 아이콘 로딩 실패 시 fallback UI 표시

### Data Requirements
- [x] DB에는 파일명만 저장 (경로 금지)
- [x] 경로 포함 시 자동 제거 (DB trigger)
- [x] Admin 업로드 시 `benefit-icons/` 버킷 사용

### Code Requirements
- [x] `resolveIconUrl()` 유틸리티 함수 구현
- [x] Local asset 우선, 없으면 network URL 생성
- [x] 에러 핸들링 및 로딩 상태 관리

---

## 🚀 Implementation Sequence

1. **DB Schema Update**: icon_url 정규화 + trigger 생성
2. **Migration Script**: fire.svg → popular.svg 전환
3. **Utility Function**: `media_resolver.dart` 구현
4. **Component Update**: `TabCircleWithLabel` 동적 로딩 지원
5. **Testing**: Hot reload로 아이콘 변경 확인
6. **Documentation**: Admin 가이드 작성

---

## 📊 Success Criteria

1. ✅ 모든 benefit_categories의 icon_url이 파일명만 포함
2. ✅ fire.svg 참조 0건, popular.svg 정상 표시
3. ✅ Admin에서 아이콘 업로드 시 앱에 즉시 반영
4. ✅ Local asset 없을 때 Supabase Storage에서 로드 성공
5. ✅ 네트워크 오류 시 fallback UI 표시

---

## 🔗 Related Documents

- PRD v9.9.2: CircleTab Dynamic Binding Implementation
- PRD v9.6: Benefit Categories Realtime Stream
- Design System: Icon Guidelines

---

**Document Control**
- Author: Claude Code
- Last Updated: 2025-11-06
- Next Review: 2025-12-06
