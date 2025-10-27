# LH 공공임대 API 통합 가이드

## 📌 개요

한국토지주택공사(LH) 분양임대공고 API를 Pickly 서비스에 통합하여, 주거 카테고리 공고를 자동으로 수집하고 모바일 앱에 표시합니다.

---

## 🏗️ 구현 완료 사항

### 1. 데이터베이스 마이그레이션 ✅

**파일**: `backend/supabase/supabase/migrations/20251024000001_add_external_id_to_announcements.sql`

- `external_id` 컬럼 추가 (LH 공고번호 저장)
- 중복 방지를 위한 UNIQUE INDEX 생성

### 2. Supabase Edge Function ✅

**디렉토리**: `backend/supabase/supabase/functions/fetch-lh-announcements/`

**주요 기능**:
- LH API 호출 및 데이터 파싱
- '주거' 카테고리 자동 매핑
- 데이터 변환 및 저장 (upsert로 중복 방지)
- 공고 상태 자동 판단 (모집중/예정/마감)

**환경 변수**:
```env
LH_API_KEY=2464c0e93735b87e2a66f4439535c9207396d3991ce9bdff236cebe7a76af28b
LH_API_URL=https://apis.data.go.kr/B552555/lhLeaseNoticeInfo1
```

### 3. 백오피스 UI ✅

**파일**: `apps/pickly_admin/src/pages/benefits/BenefitAnnouncementList.tsx`

**추가된 기능**:
- "LH 공고 불러오기" 버튼
- 로딩 상태 표시
- 성공/실패 알림 (Toast)
- 자동 목록 새로고침

**API 함수**: `apps/pickly_admin/src/api/announcements.ts`
- `fetchLHAnnouncements()` 함수 추가

### 4. Flutter 모바일 앱 ✅

**구현된 파일들**:

#### 모델
- `lib/contexts/benefit/models/announcement.dart`
  - Freezed 기반 불변 모델
  - AnnouncementStatus enum (draft, recruiting, upcoming, closed)
  - 상태별 색상/이모지/라벨

#### Repository
- `lib/contexts/benefit/repositories/announcement_repository.dart`
  - 카테고리별 공고 조회
  - 공고 상세 조회
  - 실시간 스트림 구독
  - 검색 기능
  - 인기 공고 조회
  - 조회수 증가

#### Provider
- `lib/features/benefit/providers/announcement_provider.dart`
  - Riverpod 기반 상태 관리
  - 카테고리별 공고 Provider
  - 상세 공고 Provider
  - 검색 Provider
  - 인기 공고 Provider

#### 화면 & 위젯
- `lib/features/benefit/screens/announcement_list_screen.dart`
  - 공고 목록 화면
  - Pull-to-refresh
  - 로딩/에러 상태 처리

- `lib/features/benefit/screens/announcement_detail_screen.dart`
  - 공고 상세 화면
  - 조회수 자동 증가
  - 외부 링크 연결
  - 공유/북마크 버튼

- `lib/features/benefit/widgets/announcement_card.dart`
  - 공고 카드 UI
  - 스켈레톤 로딩 UI

---

## 🚀 사용 방법

### 1. 데이터베이스 마이그레이션 적용

```bash
cd backend/supabase/supabase
supabase db reset  # 로컬 개발 환경
```

### 2. Edge Function 배포

#### 로컬 테스트
```bash
cd backend/supabase/supabase
supabase functions serve fetch-lh-announcements --env-file ../.env.local
```

#### 테스트 호출
```bash
curl http://localhost:54321/functions/v1/fetch-lh-announcements \
  -H "Authorization: Bearer YOUR_ANON_KEY"
```

#### 프로덕션 배포
```bash
supabase functions deploy fetch-lh-announcements
```

### 3. 백오피스 사용

1. 백오피스 로그인
2. "혜택 공고" 메뉴 클릭
3. "LH 공고 불러오기" 버튼 클릭
4. 성공 메시지 확인
5. 목록에서 새 공고 확인

### 4. Flutter 앱 사용

#### 코드 생성 (필요 시)
```bash
cd apps/pickly_mobile
dart run build_runner build --delete-conflicting-outputs
```

#### 앱 실행
```bash
flutter run
```

#### 사용 예시
```dart
// 1. 카테고리별 공고 목록 화면
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => AnnouncementListScreen(
      categoryId: '주거_category_id',
      categoryName: '주거',
    ),
  ),
);

// 2. 실시간 스트림 사용
final announcementsStream = ref.watch(
  announcementsStreamProvider('주거_category_id'),
);

// 3. 인기 공고 조회
final popularAnnouncements = ref.watch(
  popularAnnouncementsProvider(
    categoryId: '주거_category_id',
    limit: 5,
  ),
);
```

---

## 📊 데이터 매핑

### LH API → Pickly DB

| LH API 필드 | Pickly DB 필드 | 비고 |
|------------|----------------|------|
| 공고번호 | external_id | UNIQUE 제약조건 |
| 공고명 | title | 필수 |
| 단지명 | subtitle | 선택 |
| - | organization | 'LH 한국토지주택공사' 고정 |
| 모집시작일 | application_period_start | 날짜 |
| 모집종료일 | application_period_end | 날짜 |
| 공고일자 | announcement_date | 날짜 |
| - | status | 날짜 기반 자동 판단 |
| 소재지 + 공급호수 | summary | 조합 |
| 상세URL | external_url | 링크 |
| 지역 | tags[0] | 배열 |

---

## 🧪 테스트 시나리오

### Edge Function 테스트

1. ✅ LH API 호출 성공
2. ✅ 데이터 파싱 정상 동작
3. ✅ '주거' 카테고리 ID 조회 성공
4. ✅ 데이터베이스 저장 성공
5. ✅ 중복 공고 upsert 동작
6. ✅ 상태 자동 판단 로직
7. ✅ 에러 핸들링 (네트워크 오류, DB 오류)

### 백오피스 테스트

1. ✅ "LH 공고 불러오기" 버튼 클릭
2. ✅ 로딩 상태 표시
3. ✅ 성공 메시지 Toast
4. ✅ 목록 자동 새로고침
5. ✅ 새 공고 표시 확인

### 모바일 앱 테스트

1. ✅ 공고 목록 표시
2. ✅ Pull-to-refresh
3. ✅ 공고 카드 탭하여 상세 화면 이동
4. ✅ 조회수 자동 증가
5. ✅ 외부 링크 열기
6. ✅ 로딩/에러 상태 처리

---

## 🔧 트러블슈팅

### 1. Edge Function 호출 실패

**증상**: 백오피스에서 "LH 공고 불러오기" 버튼 클릭 시 실패

**해결책**:
```bash
# 1. Edge Function 로그 확인
supabase functions logs fetch-lh-announcements

# 2. 환경 변수 확인
cat backend/supabase/.env.local

# 3. LH API 직접 테스트
curl "https://apis.data.go.kr/B552555/lhLeaseNoticeInfo1?serviceKey=YOUR_KEY&page=1&perPage=10"
```

### 2. '주거' 카테고리 없음

**증상**: "주거 카테고리를 찾을 수 없습니다" 에러

**해결책**:
```sql
-- Supabase Studio에서 실행
INSERT INTO benefit_categories (name, slug, description, is_active)
VALUES ('주거', 'housing', '주택, 임대, 분양 관련 혜택', true);
```

### 3. Flutter 코드 생성 오류

**증상**: `announcement.freezed.dart` 또는 `*.g.dart` 파일 없음

**해결책**:
```bash
cd apps/pickly_mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### 4. 조회수 증가 실패

**증상**: 공고 상세 화면 조회 시 조회수 증가 안 됨

**해결책**:
```sql
-- Supabase Studio에서 RPC 함수 생성
CREATE OR REPLACE FUNCTION increment_announcement_view_count(announcement_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE benefit_announcements
  SET views_count = views_count + 1
  WHERE id = announcement_id;
END;
$$ LANGUAGE plpgsql;
```

---

## 📈 향후 개선 사항

### 1. 자동 수집 스케줄러 (우선순위: 중)
```typescript
// Supabase Cron Job 또는 GitHub Actions
// 매일 자동으로 LH API 호출
```

### 2. 다른 API 추가 (우선순위: 낮)
- 복지 혜택 API
- 교육 지원 API
- 고용 정책 API

### 3. 알림 기능 (우선순위: 중)
- 새 공고 등록 시 푸시 알림
- 관심 공고 마감 임박 알림

### 4. AI 요약 기능 (우선순위: 낮)
- OpenAI API를 사용한 공고 내용 자동 요약
- 사용자 맞춤형 추천

---

## 📚 참고 자료

### 내부 문서
- [PRD](../PRD.md)
- [온보딩 아키텍처](../architecture/onboarding-architecture.md)

### 외부 문서
- [LH API 문서](https://www.data.go.kr/data/15050650/openapi.do)
- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)
- [Flutter Riverpod](https://riverpod.dev/)
- [Freezed](https://pub.dev/packages/freezed)

---

## 🤝 기여 가이드

버그 발견 또는 개선 제안 시:
1. GitHub Issues 등록
2. 상세한 재현 방법 작성
3. 예상 동작 vs 실제 동작 설명

---

## 📝 라이센스

이 프로젝트는 Pickly 서비스의 일부이며, 내부 문서입니다.

---

**마지막 업데이트**: 2024-10-24
**작성자**: Claude Code
**버전**: 1.0.0
