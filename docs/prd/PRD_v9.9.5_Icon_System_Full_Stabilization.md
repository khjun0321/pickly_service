# 🎨 PRD v9.9.5 — Icon System Full Stabilization (Design + Binding)

**Version:** 9.9.5 (Final Icon Integration)
**Date:** 2025-11-10
**Status:** ✅ Active
**Authors:** Pickly Team (Hyunjun + Claude Code)
**Scope:** Design Static Icons + Dynamic Icon Binding 완전 통합

---

## 🧭 I. 프로젝트 개요

PRD v9.9.5는 Pickly 아이콘 시스템의 **최종 안정화 버전**입니다.

### 핵심 목표
1. ✅ **디자인 고정형 아이콘** (Design Static Icons) 정책 확립
2. ✅ **데이터 연동형 아이콘** (Dynamic Managed Icons) 완전 통합
3. ✅ placeholder.svg 등록 및 fallback 개선
4. ✅ fire.svg → popular.svg 전면 교체
5. ✅ CategoryIcon → MediaResolver 통합

---

## 🧩 II. Icon System Architecture

### 1. 아이콘 분류 체계

| 구분 | 용도 | 관리 위치 | DB 저장 | 변경 방식 | 예시 |
|------|------|------------|---------|-----------|------|
| **🎨 Design Static Icons** | UI 컴포넌트, 버튼, 검색창 등 | `pickly_design_system/assets/icons/` | ❌ 없음 | Flutter 코드 직접 참조 | `search.svg`, `filter.svg`, `bookmark_filled.svg` |
| **🧩 Dynamic Managed Icons** | Admin 관리 데이터 기반 콘텐츠 | Supabase Storage (`benefit-icons`, `age-icons`) | ✅ 파일명.svg | Admin 업로드 시 자동 반영 | `benefit-icons/housing.svg`, `age-icons/young_man.svg` |

---

### 2. 디자인 고정형 아이콘 (Design Static Icons)

**정의**: UI 구성을 위한 고정된 아이콘 (변경 빈도 낮음)

**관리 규칙**:
1. **Design System에서만 관리**
   - 경로: `packages/pickly_design_system/assets/icons/`
   - Flutter 코드에서 직접 참조

2. **DB에 저장하지 않음**
   - 데이터베이스와 무관하게 독립적 관리
   - 버전 관리는 Git으로만 수행

3. **변경 시 Flutter 앱 재빌드 필요**
   - 아이콘 추가/수정 → Design System 패키지 업데이트
   - Hot Reload로는 반영 불가

**예시 코드**:
```dart
// ✅ 디자인 고정형 아이콘 사용
SvgPicture.asset(
  'packages/pickly_design_system/assets/icons/search.svg',
  package: 'pickly_design_system',
  width: 24,
  height: 24,
  colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
);
```

**디자인 고정형 아이콘 목록**:
- `search.svg` - 검색 아이콘
- `filter.svg` - 필터 아이콘
- `bookmark.svg` / `bookmark_filled.svg` - 북마크
- `home.svg` / `home_filled.svg` - 홈 탭
- `benefits.svg` / `benefits_filled.svg` - 혜택 탭
- `mypage.svg` / `mypage_filled.svg` - 마이페이지 탭
- `arrow_left.svg` / `arrow_right.svg` - 네비게이션
- `close.svg` - 닫기
- `check.svg` - 체크마크
- `placeholder.svg` - Fallback 아이콘

---

### 3. 데이터 연동형 아이콘 (Dynamic Managed Icons)

**정의**: Admin에서 관리하며 데이터베이스와 연동되는 동적 아이콘

**관리 규칙**:
1. **Supabase Storage에 저장**
   - `benefit-icons`: 혜택 카테고리 아이콘
   - `age-icons`: 연령대 카테고리 아이콘
   - 향후 확장 가능 (announcement-icons 등)

2. **DB에 파일명만 저장**
   - 형식: `파일명.svg` (예: `housing.svg`, `young_man.svg`)
   - ❌ 경로 포함 금지: `/icons/housing.svg` ❌
   - ❌ URL 저장 금지: `https://...` ❌

3. **MediaResolver로 자동 분기**
   - 로컬 asset 확인 → 존재하면 로컬 사용
   - 로컬 없으면 → Storage URL 생성

**예시 코드**:
```dart
// ✅ 데이터 연동형 아이콘 사용 (Benefit Icons)
final iconUrl = await resolveIconUrl(category.iconUrl);

if (iconUrl.startsWith('asset://')) {
  return SvgPicture.asset(iconUrl.replaceFirst('asset://', ''));
} else {
  return SvgPicture.network(iconUrl);
}

// ✅ 데이터 연동형 아이콘 사용 (Age Icons)
final ageIconUrl = await resolveAgeIconUrl(ageCategory.iconUrl);

if (ageIconUrl.startsWith('asset://')) {
  return SvgPicture.asset(ageIconUrl.replaceFirst('asset://', ''));
} else {
  return SvgPicture.network(ageIconUrl);
}
```

---

## 🔧 III. 핵심 수정 사항 (v9.9.5)

### 1. placeholder.svg 등록

**파일**: `packages/pickly_design_system/pubspec.yaml`

```yaml
flutter:
  assets:
    - packages/pickly_design_system/assets/icons/
    - packages/pickly_design_system/assets/icons/placeholder.svg  # 신규 추가
```

**용도**:
- icon_url이 null일 때 fallback
- 로컬 asset 로드 실패 시 fallback
- Storage URL 생성 실패 시 fallback

---

### 2. fire.svg → popular.svg 전면 교체

**변경 이유**:
- PRD v9.9.1에서 `fire.svg` → `popular.svg`로 명명 변경
- 일부 코드에서 여전히 `fire.svg` 참조 중

**수정 파일**:
- `packages/pickly_design_system/lib/widgets/images/category_icon.dart`
- `apps/pickly_mobile/lib/features/home/widgets/*`
- 기타 모든 fire.svg 참조

**Migration 적용**:
```bash
# fire.svg → popular.svg 일괄 변경
grep -rl "fire.svg" apps/pickly_mobile packages/pickly_design_system | \
  xargs sed -i '' 's/fire.svg/popular.svg/g'
```

---

### 3. CategoryIcon MediaResolver 통합

**Before (v9.9.4)**:
```dart
// CategoryIcon이 iconUrl을 직접 네트워크 URL로 처리
if (iconUrl != null && iconUrl!.isNotEmpty) {
  return SvgPicture.network(iconUrl!);  // ❌ 문제: 파일명만 있으면 에러
}
```

**After (v9.9.5)**:
```dart
// CategoryIcon이 MediaResolver를 사용하도록 수정
Future<Widget> _buildDynamicIcon() async {
  String bucket = 'benefit-icons';

  // icon type에 따라 bucket 선택
  if (iconType == 'age') {
    bucket = 'age-icons';
  }

  final resolvedUrl = await resolveMediaUrl(iconUrl, bucket: bucket);

  if (resolvedUrl.startsWith('asset://')) {
    return SvgPicture.asset(resolvedUrl.replaceFirst('asset://', ''));
  } else {
    return SvgPicture.network(resolvedUrl);
  }
}
```

---

### 4. MediaResolver 최종 버전 (v9.9.5)

**파일**: `apps/pickly_mobile/lib/core/utils/media_resolver.dart`

```dart
/// Unified Media Resolver — 다중 버킷 지원
Future<String> resolveMediaUrl(
  String? filename, {
  String bucket = 'benefit-icons',
}) async {
  // 1. Null/Empty 처리
  if (filename == null || filename.isEmpty) {
    return 'asset://packages/pickly_design_system/assets/icons/placeholder.svg';
  }

  // 2. 파일명 정규화 (경로 제거)
  final cleanFilename = filename.split('/').last;

  // 3. 로컬 asset 확인
  final assetPath = 'packages/pickly_design_system/assets/icons/$cleanFilename';

  try {
    await rootBundle.load(assetPath);
    return 'asset://$assetPath';  // 로컬 asset 발견
  } catch (e) {
    // 4. Supabase Storage URL 생성
    try {
      final storageUrl = Supabase.instance.client.storage
          .from(bucket)
          .getPublicUrl(cleanFilename);
      return storageUrl;
    } catch (storageError) {
      // 5. 최종 fallback
      return 'asset://packages/pickly_design_system/assets/icons/placeholder.svg';
    }
  }
}

/// Benefit Icons 편의 메서드
Future<String> resolveIconUrl(String? filename) async {
  return resolveMediaUrl(filename, bucket: 'benefit-icons');
}

/// Age Icons 편의 메서드
Future<String> resolveAgeIconUrl(String? filename) async {
  return resolveMediaUrl(filename, bucket: 'age-icons');
}
```

---

## 🗂️ IV. Storage Bucket 구조

### benefit-icons Bucket

**용도**: 혜택 카테고리 아이콘 저장

**파일 예시**:
```
benefit-icons/
├── housing.svg       (주거)
├── education.svg     (교육)
├── health.svg        (건강)
├── transportation.svg (교통)
├── welfare.svg       (복지)
├── employment.svg    (취업)
├── support.svg       (지원)
├── culture.svg       (문화)
└── popular.svg       (인기)
```

---

### age-icons Bucket

**용도**: 연령대 카테고리 아이콘 저장

**파일 예시**:
```
age-icons/
├── young_man.svg   (청년)
├── bride.svg       (신혼부부)
├── baby.svg        (유아)
├── kinder.svg      (어린이)
├── old_man.svg     (노년)
└── wheelchair.svg  (장애인)
```

---

## 📊 V. 아이콘 로딩 플로우

### Design Static Icons (고정형)

```mermaid
Flutter App → Design System Package → SVG Asset → Render
```

**특징**:
- 빌드 시 포함됨
- 네트워크 요청 없음
- 100% 오프라인 작동

---

### Dynamic Managed Icons (동적)

```mermaid
Flutter App → MediaResolver → Check Local Asset
                              ├─ Found → Use Local
                              └─ Not Found → Supabase Storage → Render
```

**특징**:
- 로컬 asset 우선
- Storage fallback
- placeholder.svg 최종 fallback

---

## 🧪 VI. 테스트 시나리오

### Scenario 1: 혜택 카테고리 아이콘 로딩

**Given**: 혜택 카테고리 `housing` 선택
**When**: BenefitsScreen 렌더링
**Then**:
1. MediaResolver가 `resolveIconUrl('housing.svg')` 호출
2. 로컬 asset 확인: `packages/pickly_design_system/assets/icons/housing.svg`
3. 로컬 존재 → `asset://...` 반환
4. SvgPicture.asset으로 렌더링 ✅

---

### Scenario 2: Age 카테고리 아이콘 로딩 (Storage)

**Given**: Age 카테고리 `young_man` 선택
**When**: AgeCategoryScreen 렌더링
**Then**:
1. MediaResolver가 `resolveAgeIconUrl('young_man.svg')` 호출
2. 로컬 asset 확인: 존재하지 않음
3. Storage URL 생성: `http://127.0.0.1:54321/storage/v1/object/public/age-icons/young_man.svg`
4. SvgPicture.network으로 렌더링 ✅

---

### Scenario 3: Fallback to placeholder.svg

**Given**: icon_url이 null 또는 잘못된 파일명
**When**: MediaResolver 호출
**Then**:
1. icon_url null 체크 실패
2. placeholder.svg 경로 반환
3. Placeholder 아이콘 표시 ✅

---

## ✅ VII. Verification Checklist

### 디자인 고정형 아이콘
- [x] placeholder.svg 파일 생성
- [ ] placeholder.svg pubspec.yaml 등록
- [ ] fire.svg → popular.svg 전면 교체
- [ ] search.svg, filter.svg, bookmark.svg 등 Design System에 존재 확인

### 데이터 연동형 아이콘
- [x] benefit-icons bucket 생성
- [x] age-icons bucket 생성
- [x] MediaResolver 확장 (resolveAgeIconUrl, resolveIconUrl)
- [x] BenefitsScreen FutureBuilder 적용
- [x] AgeCategoryScreen FutureBuilder 적용
- [ ] CategoryIcon MediaResolver 통합

### 에러 해결
- [ ] Age Icons "No host specified in URI" 에러 해결
- [ ] placeholder.svg "Unable to load asset" 에러 해결
- [ ] fire.svg "Unable to load asset" 에러 해결
- [ ] Invalid SVG data (Storage) 에러 회피

---

## 🚀 VIII. 운영 가이드

### Admin에서 새 아이콘 업로드

1. **Admin 로그인**
2. **혜택 카테고리 관리** 또는 **연령대 관리** 선택
3. **SVG 파일 업로드**
   - 파일명: `category_name.svg` (예: `housing.svg`)
   - Storage bucket 자동 선택: `benefit-icons` 또는 `age-icons`
4. **DB에 파일명 저장**
   - `icon_url` 필드에 `파일명.svg`만 저장
5. **Flutter 앱 자동 반영**
   - Realtime subscription으로 즉시 반영
   - MediaResolver가 Storage URL 자동 생성

---

### 로컬 asset 추가 (개발자용)

1. **SVG 파일 준비**
2. **Design System에 추가**
   - 경로: `packages/pickly_design_system/assets/icons/`
3. **pubspec.yaml 업데이트** (필요 시)
4. **Flutter 앱 재빌드**
   ```bash
   flutter pub get
   flutter run
   ```

---

## 📚 IX. 메타데이터

- **작성일**: 2025-11-10
- **버전**: v9.9.5
- **작성자**: Pickly Team
- **파일 경로**: `/docs/prd/PRD_v9.9.5_Icon_System_Full_Stabilization.md`
- **참조 문서**:
  - PRD v9.9.4 (Age Icons Integration)
  - PRD v9.9.3 (Full System Integration)
  - PRD v9.9.1 (Icon Asset Management Policy)
  - PRD v9.9.2 (CircleTab Dynamic Binding)

---

## 🔄 X. 변경 이력

- **2025-11-10 (v9.9.5)**:
  - Design Static Icons 정책 확립
  - placeholder.svg pubspec 등록
  - fire.svg → popular.svg 전면 교체
  - CategoryIcon MediaResolver 통합
  - 아이콘 시스템 최종 안정화
