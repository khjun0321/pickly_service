# ✅ Phase 5.4 검증 가이드 — PRD v9.7.0

**날짜**: 2025-11-06
**버전**: PRD v9.7.0
**상태**: 검증 진행 중

---

## 🎯 검증 목표

RLS 비활성화 후 모든 시스템 기능이 정상 작동하는지 확인:
1. ✅ Admin CRUD 작동
2. ✅ 파일 업로드 작동
3. ✅ Flutter 앱 실시간 동기화 작동

---

## 📋 검증 체크리스트

### 1️⃣ Admin 페이지 — 연령 카테고리 관리

**URL**: http://localhost:5173/age-categories

#### ✅ 추가 (INSERT) 테스트
1. **"+ 카테고리 추가"** 버튼 클릭
2. 정보 입력:
   - 제목: "테스트 연령대"
   - 설명: "검증용 테스트 카테고리"
   - 아이콘: SVG 파일 업로드
   - 최소 나이: 20
   - 최대 나이: 30
   - 정렬 순서: 99
   - 활성화: ON
3. **"추가"** 버튼 클릭

**✅ 성공 조건:**
- [ ] 에러 없이 저장됨
- [ ] "저장되었습니다" 메시지 표시
- [ ] 목록에 새 항목이 바로 나타남
- [ ] 브라우저 콘솔에 RLS 에러 없음

#### ✅ 수정 (UPDATE) 테스트
1. 방금 추가한 항목의 **연필 아이콘(수정)** 클릭
2. 제목 변경: "수정된 테스트 연령대"
3. **"저장"** 버튼 클릭

**✅ 성공 조건:**
- [ ] 에러 없이 수정됨
- [ ] 변경된 내용이 목록에 반영됨
- [ ] 콘솔 에러 없음

#### ✅ 삭제 (DELETE) 테스트
1. 테스트 항목의 **휴지통 아이콘(삭제)** 클릭
2. 확인 대화상자에서 **"확인"** 클릭

**✅ 성공 조건:**
- [ ] 에러 없이 삭제됨
- [ ] 목록에서 항목이 사라짐
- [ ] 콘솔 에러 없음

---

### 2️⃣ Admin 페이지 — 혜택 카테고리 관리

**URL**: http://localhost:5173/benefit-categories

#### ✅ 추가/수정/삭제 테스트
위 **연령 카테고리**와 동일한 순서로 테스트:
1. 추가 → 저장 확인
2. 수정 → 변경 확인
3. 삭제 → 제거 확인

**✅ 성공 조건:**
- [ ] 모든 CRUD 작동
- [ ] 파일 업로드 성공 (아이콘)
- [ ] 콘솔 에러 없음

---

### 3️⃣ 파일 업로드 검증

#### ✅ SVG 아이콘 업로드
1. 카테고리 추가 시 **"SVG 업로드"** 버튼 클릭
2. 임의의 SVG 파일 선택 (1MB 미만)
3. 업로드 진행 확인

**✅ 성공 조건:**
- [ ] 업로드 성공 메시지
- [ ] 업로드된 파일 URL 확인 가능
- [ ] Storage bucket에 파일 존재 확인
- [ ] 콘솔 에러 없음

#### ✅ Storage 확인
**Supabase Studio**: http://localhost:54323

1. 왼쪽 사이드바 → **Storage** 클릭
2. `benefit-icons` 버킷 선택
3. 업로드된 파일 확인

**✅ 성공 조건:**
- [ ] 파일이 버킷에 존재
- [ ] Public URL로 접근 가능
- [ ] 파일 다운로드 가능

---

### 4️⃣ Flutter 앱 — 실시간 동기화 검증

#### ✅ 앱 화면 확인
1. Flutter 앱 실행 (시뮬레이터 또는 실제 기기)
2. 온보딩 화면 또는 홈 화면으로 이동
3. 연령대 선택 화면 확인

#### ✅ 실시간 동기화 테스트
1. **Admin 페이지**에서 연령 카테고리 추가
2. **Flutter 앱**에서 자동으로 업데이트되는지 확인 (새로고침 없이)

**✅ 성공 조건:**
- [ ] Admin에서 추가 → 앱에 바로 반영
- [ ] Admin에서 수정 → 앱에 바로 반영
- [ ] Admin에서 삭제 → 앱에서 사라짐
- [ ] 실시간 동기화 지연 < 2초

#### ✅ 앱 데이터 조회 확인
```dart
// Flutter 앱 콘솔 로그 확인
// Realtime subscription 작동 여부
```

**✅ 성공 조건:**
- [ ] Supabase Realtime 연결 성공
- [ ] 데이터 변경 이벤트 수신 확인
- [ ] UI 자동 업데이트 확인

---

### 5️⃣ Database 직접 확인

**Supabase Studio SQL Editor**: http://localhost:54323

```sql
-- 1. 모든 테이블 RLS 상태 확인
SELECT
  schemaname,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN (
  'age_categories',
  'benefit_categories',
  'announcements'
)
ORDER BY tablename;
```

**✅ 예상 결과:**
```
tablename           | rls_enabled
--------------------+------------
age_categories      | f
announcements       | f
benefit_categories  | f
```

```sql
-- 2. 데이터 확인
SELECT id, title, is_active, created_at
FROM age_categories
ORDER BY sort_order;
```

**✅ 성공 조건:**
- [ ] 모든 테이블 RLS = false
- [ ] 데이터 정상 조회 가능
- [ ] Admin에서 추가한 항목 존재 확인

---

### 6️⃣ Storage Buckets 확인

```sql
-- Storage buckets public 상태 확인
SELECT name, public FROM storage.buckets ORDER BY name;
```

**✅ 예상 결과:**
```
name                | public
--------------------+--------
benefit-banners     | t
benefit-icons       | t
benefit-thumbnails  | t
pickly-storage      | t
```

**✅ 성공 조건:**
- [ ] 모든 버킷 public = true
- [ ] Public URL로 파일 접근 가능

---

## 🐛 문제 발생 시 트러블슈팅

### Issue 1: Admin CRUD 에러

**증상**: "new row violates row-level security policy"

**원인**: RLS가 다시 활성화됨

**해결**:
```bash
cd /Users/kwonhyunjun/Desktop/pickly_service/backend
docker exec -i supabase_db_supabase psql -U postgres -d postgres < supabase/migrations/20251107_disable_all_rls.sql
```

---

### Issue 2: 파일 업로드 실패

**증상**: 403 Forbidden 또는 "Bucket not public"

**원인**: Storage bucket이 public이 아님

**해결**:
```sql
UPDATE storage.buckets SET public = true
WHERE name IN ('benefit-icons', 'benefit-banners', 'benefit-thumbnails', 'pickly-storage');
```

---

### Issue 3: Flutter 앱 동기화 안됨

**증상**: Admin 변경사항이 앱에 반영 안됨

**원인 1**: Realtime 연결 끊김
```dart
// Flutter 앱 재시작
flutter run -d [device]
```

**원인 2**: 앱이 inactive 데이터만 필터링
```dart
// Repository 코드 확인
// .eq('is_active', true) 조건 있는지 확인
```

**해결**: Admin에서 추가 시 **활성화(is_active)** 체크 확인

---

## ✅ 최종 검증 완료 조건

### 필수 항목 (All must pass)
- [ ] Admin 연령 카테고리 CRUD 완전 작동
- [ ] Admin 혜택 카테고리 CRUD 완전 작동
- [ ] 파일 업로드 성공
- [ ] Flutter 앱 실시간 동기화 작동
- [ ] 콘솔 에러 0건

### 성능 기준
- [ ] CRUD 응답 시간 < 1초
- [ ] 파일 업로드 시간 < 3초
- [ ] 실시간 동기화 지연 < 2초

### 문서 업데이트
- [ ] PRD_CURRENT.md → v9.7.0 업데이트
- [ ] 검증 보고서 작성 완료

---

## 📊 검증 결과 기록

### Test Run #1 (2025-11-06)

| 테스트 항목 | 상태 | 비고 |
|-----------|------|------|
| 연령 카테고리 추가 | ⏳ 대기 | |
| 연령 카테고리 수정 | ⏳ 대기 | |
| 연령 카테고리 삭제 | ⏳ 대기 | |
| 혜택 카테고리 추가 | ⏳ 대기 | |
| 혜택 카테고리 수정 | ⏳ 대기 | |
| 혜택 카테고리 삭제 | ⏳ 대기 | |
| 파일 업로드 | ⏳ 대기 | |
| Flutter 동기화 | ⏳ 대기 | |

**테스터**: (사용자 이름)
**완료 시간**: (시간 기록)
**총 소요 시간**: (분 단위)

---

## 🚀 다음 단계

검증 완료 후:
1. PRD_CURRENT.md 업데이트
2. 최종 검증 보고서 작성
3. Git commit & push
4. 팀 공유

---

**Last Updated**: 2025-11-06
**Author**: Claude Code
**Version**: PRD v9.7.0 Validation Guide
