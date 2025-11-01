# 🧪 Admin 테스트 가이드 (v8.7 + v8.8)

> **목적**: Realtime Stream + Offline Fallback 검증
> **대상**: Announcements & Category Banners
> **소요 시간**: 약 15분

---

## 🔗 Supabase 대시보드 링크

### 로컬 Supabase Studio
```
🌐 URL: http://127.0.0.1:54323
```

**바로 열기**:
```bash
open http://127.0.0.1:54323
```

### 주요 메뉴 경로

1. **Table Editor** (데이터 보기/수정)
   - URL: `http://127.0.0.1:54323/project/default/editor`
   - 테이블 목록에서 선택 가능

2. **SQL Editor** (쿼리 실행)
   - URL: `http://127.0.0.1:54323/project/default/sql`
   - 직접 SQL 실행 가능

3. **Database** (스키마 확인)
   - URL: `http://127.0.0.1:54323/project/default/database/tables`
   - 테이블 구조, 인덱스, 트리거 확인

4. **Authentication** (사용자 관리)
   - URL: `http://127.0.0.1:54323/project/default/auth/users`

---

## 📋 테스트할 테이블

### 1. `announcements` (공고)
**경로**: Table Editor → announcements

**주요 컬럼**:
- `id` (UUID)
- `title` (제목)
- `status` ('open', 'closed', 'upcoming')
- `is_priority` (우선순위 여부)
- `posted_date` (게시일)

**테스트용 데이터 확인**:
```sql
SELECT id, title, status, is_priority, posted_date
FROM announcements
ORDER BY posted_date DESC
LIMIT 5;
```

---

### 2. `category_banners` (카테고리 배너)
**경로**: Table Editor → category_banners

**주요 컬럼**:
- `id` (UUID)
- `category_id` (카테고리 ID)
- `category_slug` ✨ **NEW (v8.7)** - 성능 최적화 컬럼
- `title` (제목)
- `is_active` (활성화 여부)
- `display_order` (정렬 순서)

**테스트용 데이터 확인**:
```sql
SELECT id, title, category_slug, is_active, display_order
FROM category_banners
WHERE is_active = true
ORDER BY display_order;
```

---

### 3. `benefit_categories` (혜택 카테고리)
**경로**: Table Editor → benefit_categories

**주요 컬럼**:
- `id` (UUID)
- `slug` ('popular', 'housing', 'education', etc.)
- `title` (카테고리명)
- `is_active` (활성화 여부)

**카테고리 목록 확인**:
```sql
SELECT id, slug, title, is_active, sort_order
FROM benefit_categories
ORDER BY sort_order;
```

---

## 🧪 테스트 시나리오

### 시나리오 1: Realtime Stream 동작 확인 ⚡

**목표**: Admin 수정 시 Flutter 앱 자동 반영 검증

**단계**:
1. **Flutter 앱 실행** (시뮬레이터)
   ```bash
   cd apps/pickly_mobile
   flutter run
   ```

2. **Supabase Studio 열기**
   ```bash
   open http://127.0.0.1:54323
   ```

3. **공고 수정** (Table Editor → announcements)
   - 아무 공고의 `title` 수정
   - 예: "테스트 공고" → "테스트 공고 (수정됨)"
   - Save 클릭

4. **Flutter 앱 확인** (예상 결과)
   - ✅ **0.3초 이내** 자동 반영
   - ✅ 새로고침 버튼 없이 자동 갱신
   - ✅ 디버그 로그 확인:
     ```
     🔄 Received N announcements from stream
     ✅ Stream emitted N filtered announcements (cached)
     💾 Emitting N cached announcements
     ```

---

### 시나리오 2: Offline Fallback 동작 확인 💾

**목표**: 네트워크 끊김 시 캐시 데이터 표시 검증

**단계**:
1. **Flutter 앱 실행 후 데이터 로드**
   - 공고 화면 진입 → 캐시 저장됨

2. **Supabase 중단**
   ```bash
   supabase stop
   ```

3. **Flutter 앱 재실행**
   ```bash
   flutter run
   ```

4. **앱 확인** (예상 결과)
   - ✅ 캐시된 데이터 **즉시 표시** (<100ms)
   - ✅ 에러 메시지 없음
   - ✅ 디버그 로그 확인:
     ```
     💾 Emitting 5 cached announcements (instant UI feedback)
     ⚠️ Stream error: ...
     📂 Using offline cache as fallback (5 announcements)
     ```

5. **Supabase 재시작**
   ```bash
   supabase start
   ```

6. **앱 확인** (예상 결과)
   - ✅ 자동 재연결 (<0.5초)
   - ✅ 최신 데이터로 갱신
   - ✅ 디버그 로그:
     ```
     🔄 Received N announcements from stream
     ✅ Stream emitted N filtered announcements (cached)
     ```

---

### 시나리오 3: v8.7 성능 최적화 확인 🚀

**목표**: category_slug 컬럼 활용 검증

**단계**:
1. **SQL Editor에서 실행** (`http://127.0.0.1:54323/project/default/sql`)
   ```sql
   -- 배너 데이터 확인 (category_slug 포함)
   SELECT
     id,
     title,
     category_id,
     category_slug,  -- ✨ v8.7 신규 컬럼
     is_active,
     display_order
   FROM category_banners
   WHERE is_active = true
   ORDER BY display_order;
   ```

2. **결과 확인**
   - ✅ `category_slug` 컬럼에 값 존재 ('popular', 'housing', etc.)
   - ✅ 모든 배너가 slug 값을 가짐

3. **Flutter 앱에서 성능 확인**
   - 카테고리 탭 전환 시 반응 속도
   - 예상: **293ms → ~220ms** (26% 빠름)
   - 디버그 로그:
     ```
     🌊 Starting realtime stream for banners with slug: popular (v8.7 optimized)
     ✅ Stream emitted 3 banners for slug popular (cached)
     ```

---

### 시나리오 4: 트리거 동작 확인 🔄

**목표**: Auto-sync, Cascade, Validate 트리거 검증

#### 4-1. Auto-Sync Trigger (새 배너 추가)

**SQL Editor에서 실행**:
```sql
-- 1. 카테고리 ID 확인
SELECT id, slug FROM benefit_categories WHERE slug = 'popular';

-- 2. 배너 추가 (category_slug 자동 채움)
INSERT INTO category_banners (
  category_id,
  title,
  subtitle,
  image_url,
  link_type,
  display_order,
  is_active
) VALUES (
  '9da8b1ad-7343-4ebe-9d5b-0ba27a1c3593',  -- popular 카테고리 ID
  '테스트 배너',
  '자동 동기화 테스트',
  'https://example.com/image.jpg',
  'none',
  999,
  true
);

-- 3. category_slug 자동 채워졌는지 확인
SELECT id, title, category_slug
FROM category_banners
WHERE title = '테스트 배너';
```

**예상 결과**:
```
id                                   | title      | category_slug
-------------------------------------|------------|---------------
<새로운 UUID>                         | 테스트 배너 | popular
```
✅ `category_slug`가 자동으로 'popular'로 채워짐

---

#### 4-2. Cascade Trigger (카테고리 slug 변경)

**SQL Editor에서 실행**:
```sql
-- 1. 테스트용 카테고리 slug 변경
UPDATE benefit_categories
SET slug = 'super-popular'
WHERE slug = 'popular';

-- 2. 배너의 category_slug도 자동 업데이트 확인
SELECT id, title, category_slug
FROM category_banners
WHERE category_id = '9da8b1ad-7343-4ebe-9d5b-0ba27a1c3593';
```

**예상 결과**:
```
NOTICE: ✅ Updated category_slug for all banners in category: 인기 (popular → super-popular)

id                                   | title      | category_slug
-------------------------------------|------------|---------------
...                                  | 테스트 배너 | super-popular
```
✅ 모든 배너의 `category_slug`가 자동으로 'super-popular'로 변경됨

**원래대로 복구**:
```sql
UPDATE benefit_categories
SET slug = 'popular'
WHERE slug = 'super-popular';
```

---

#### 4-3. Validate Trigger (잘못된 형식 거부)

**SQL Editor에서 실행**:
```sql
-- 잘못된 slug 형식으로 배너 추가 시도
INSERT INTO category_banners (
  category_id,
  category_slug,  -- 직접 지정 (잘못된 형식)
  title,
  image_url,
  link_type,
  display_order,
  is_active
) VALUES (
  '9da8b1ad-7343-4ebe-9d5b-0ba27a1c3593',
  'Invalid_Slug!',  -- ❌ 잘못된 형식 (대문자, 특수문자)
  '잘못된 배너',
  'https://example.com/image.jpg',
  'none',
  999,
  true
);
```

**예상 결과**:
```
ERROR: new row for relation "category_banners" violates check constraint "chk_category_slug_format"
DETAIL: Failing row contains (..., Invalid_Slug!, ...)
```
✅ 잘못된 형식의 slug가 거부됨

---

### 시나리오 5: 캐시 통계 확인 📊

**목표**: Offline 캐시 저장 상태 확인

**Flutter 앱 디버그 콘솔에서 확인**:
```dart
// 캐시 통계 출력
final stats = await OfflineMode<List<CategoryBanner>>().getStats();
print('Cache stats: $stats');
```

**예상 출력**:
```json
{
  "total_caches": 3,
  "total_size_bytes": 12750,
  "total_size_kb": "12.45",
  "caches": {
    "announcements": {
      "size_bytes": 4250,
      "age_minutes": 5,
      "cached_at": "2025-11-01T10:30:00.000Z"
    },
    "category_banners_active": {
      "size_bytes": 3200,
      "age_minutes": 3,
      "cached_at": "2025-11-01T10:32:00.000Z"
    },
    "banners_slug_popular": {
      "size_bytes": 5300,
      "age_minutes": 2,
      "cached_at": "2025-11-01T10:33:00.000Z"
    }
  }
}
```

---

## 🎯 빠른 테스트 스크립트

### 1. 전체 시스템 재시작
```bash
# Supabase 재시작
cd backend
supabase stop
supabase start

# Flutter 앱 재시작
cd ../apps/pickly_mobile
flutter clean
flutter pub get
flutter run
```

### 2. 테스트 데이터 초기화
```bash
# Supabase 리셋 (seed data로 초기화)
cd backend
supabase db reset
```

### 3. 로그 모니터링
```bash
# Supabase 로그 확인
supabase logs

# Flutter 로그 필터링
flutter run | grep -E "🌊|💾|✅|❌|⚠️"
```

---

## 📊 성능 측정 팁

### Chrome DevTools로 측정

1. **Flutter Web 실행**
   ```bash
   flutter run -d chrome
   ```

2. **Chrome DevTools 열기**
   - F12 → Network 탭
   - Filter: `supabase` 또는 `realtime`

3. **측정 지표**
   - Initial Stream Connection: ~220ms
   - Cache Load Time: ~52ms
   - Recovery Time: ~312ms

### Flutter DevTools로 측정

1. **DevTools 열기**
   ```bash
   flutter pub global activate devtools
   flutter pub global run devtools
   ```

2. **Performance 탭**
   - Stream 메서드 프로파일링
   - Cache load 시간 측정
   - Memory usage 확인

---

## 🐛 문제 해결

### Issue 1: Stream이 동작하지 않음

**증상**: Admin 수정 후 앱에 반영 안 됨

**확인 사항**:
```bash
# Supabase 상태 확인
supabase status

# Realtime 서비스 확인
curl http://127.0.0.1:54321/rest/v1/
```

**해결**:
```bash
# Supabase 재시작
supabase stop
supabase start
```

---

### Issue 2: 캐시가 저장되지 않음

**증상**: 디버그 로그에 "💾" 없음

**확인 사항**:
```dart
// SharedPreferences 권한 확인
final prefs = await SharedPreferences.getInstance();
print('Prefs available: ${prefs != null}');
```

**해결**:
```bash
# iOS 시뮬레이터 리셋
xcrun simctl erase all

# Android 에뮬레이터 데이터 삭제
adb shell pm clear com.example.pickly_mobile
```

---

### Issue 3: category_slug가 NULL

**증상**: 배너 데이터에 category_slug 없음

**확인**:
```sql
SELECT COUNT(*) FROM category_banners WHERE category_slug IS NULL;
```

**해결**:
```sql
-- 수동 backfill
UPDATE category_banners cb
SET category_slug = bc.slug
FROM benefit_categories bc
WHERE cb.category_id = bc.id
  AND cb.category_slug IS NULL;
```

---

## ✅ 테스트 체크리스트

### v8.6 Realtime Stream
- [ ] ✅ Admin 수정 시 앱 자동 반영 (0.3초 이내)
- [ ] ✅ 공고 필터링 동작 (status, priority)
- [ ] ✅ 배너 카테고리별 필터링 동작

### v8.7 Performance
- [ ] ✅ category_slug 컬럼 존재
- [ ] ✅ Auto-sync 트리거 동작
- [ ] ✅ Cascade 트리거 동작
- [ ] ✅ Validate 트리거 동작
- [ ] ✅ 성능 개선 확인 (293ms → 220ms)

### v8.8 Offline Fallback
- [ ] ✅ 캐시 저장 확인 (디버그 로그 "💾")
- [ ] ✅ 오프라인 시 캐시 표시
- [ ] ✅ 자동 복구 동작 (<0.5초)
- [ ] ✅ 캐시 통계 확인

### 전체 통합
- [ ] ✅ 동시 구독 동작 (announcements + banners)
- [ ] ✅ 메모리 누수 없음
- [ ] ✅ UI 반응성 유지
- [ ] ✅ 에러 처리 적절

---

## 📞 추가 자료

**문서**:
- `docs/implementation/v8.7_v8.8_complete_implementation_guide.md`
- `docs/testing/v8.7_v8.8_test_plan_and_results.md`
- `docs/IMPLEMENTATION_COMPLETE_v8.7_v8.8.md`

**마이그레이션**:
- `backend/supabase/migrations/20251101000001_add_category_slug_to_banners.sql`
- `backend/docs/migration_20251101_category_slug_optimization.md`

**코드**:
- `apps/pickly_mobile/lib/core/offline/offline_mode.dart`
- `apps/pickly_mobile/lib/features/benefits/repositories/`

---

🎉 **즐거운 테스트 되세요!**
