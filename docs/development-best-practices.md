# 개발 중 캐스케이드 실패 최소화 가이드

## 🚨 문제: 하나를 고치면 다른 게 깨지는 이유

### 주요 원인
1. **데이터베이스 초기화 남용**: `supabase db reset`은 **모든 데이터를 삭제**합니다
2. **Migration 누락**: 변경사항이 migration으로 기록되지 않아 재시작 시 사라집니다
3. **테스트 데이터 미백업**: seed.sql이 최신 상태가 아니면 복구 불가능
4. **RLS 정책 충돌**: 여러 정책이 겹치거나 누락되면 권한 오류 발생

## ✅ 베스트 프랙티스

### 1. 데이터베이스 변경 시

#### ❌ 절대 하지 말 것
```bash
# 운영 중인 시스템에서 절대 사용 금지!
supabase db reset  # 모든 데이터 삭제됨
```

#### ✅ 올바른 방법
```bash
# 1. 새 migration 생성
supabase migration new add_feature_name

# 2. migration 파일 작성
# supabase/migrations/20251025120000_add_feature_name.sql

# 3. migration 적용 (데이터 유지)
supabase db push

# 4. 확인
supabase db diff
```

### 2. Storage 정책 변경 시

#### 체크리스트
- [ ] 기존 정책 확인
- [ ] 새 정책이 기존 기능에 영향 없는지 검증
- [ ] migration 파일로 기록
- [ ] 테스트 업로드 수행

```sql
-- ✅ 올바른 패턴: DROP IF EXISTS로 안전하게 교체
DROP POLICY IF EXISTS "Policy Name" ON storage.objects;
CREATE POLICY "Policy Name"
ON storage.objects FOR INSERT
TO anon, public
WITH CHECK (
  bucket_id = 'pickly-storage'
  AND (name LIKE 'banners/%' OR name LIKE 'icons/%')
);
```

### 3. 테스트 데이터 관리

#### seed.sql 최신 상태 유지
```bash
# 1. 현재 데이터 백업 (중요한 테스트 데이터가 있을 때)
docker exec supabase_db_pickly_service pg_dump -U postgres -d postgres \
  --data-only \
  --table=category_banners \
  --table=benefit_categories \
  > backup_$(date +%Y%m%d_%H%M%S).sql

# 2. seed.sql 업데이트
# supabase/seed.sql 파일에 중요한 테스트 데이터 추가

# 3. 검증
supabase db reset  # 이제 안전함 - seed.sql에 데이터 있음
```

### 4. 변경사항 적용 순서

```bash
# ✅ 안전한 순서
# 1. Migration 작성 및 적용
supabase migration new feature_name
# migration 파일 작성
supabase db push

# 2. 코드 변경 (Admin Panel / Mobile App)
# 변경사항 커밋

# 3. 테스트
# 각 기능 개별 테스트

# 4. 통합 테스트
# 전체 플로우 확인
```

### 5. RLS 정책 디버깅

```sql
-- 현재 적용된 정책 확인
SELECT
  policyname,
  cmd,
  roles,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'objects'
  AND schemaname = 'storage'
ORDER BY policyname;

-- 특정 역할의 권한 확인
SELECT
  bucket_id,
  name,
  id,
  metadata
FROM storage.objects
WHERE bucket_id = 'pickly-storage'
ORDER BY created_at DESC
LIMIT 10;
```

## 🔧 현재 시스템 복구 방법

### 배너 데이터 복구
```bash
# 1. 현재 benefit_categories 확인
docker exec supabase_db_pickly_service psql -U postgres -d postgres -c \
  "SELECT id, name, slug FROM benefit_categories ORDER BY display_order;"

# 2. 각 카테고리에 배너 재등록
# Admin Panel에서 수동으로 재등록하거나
# seed.sql에 INSERT 문 추가 후 재실행
```

### RLS 오류 발생 시
```bash
# 1. 브라우저 개발자 도구 > Network 탭 확인
# 실제 에러 메시지 확인 (403? 400? 401?)

# 2. Supabase 클라이언트 설정 확인
# apps/pickly_admin/src/lib/supabase.ts
# anon key 사용 확인

# 3. 정책 재적용
docker exec supabase_db_pickly_service psql -U postgres -d postgres \
  < supabase/migrations/20251025050000_storage_rls_for_admin.sql
```

## 📋 일상 개발 체크리스트

### 기능 추가/수정 전
- [ ] 현재 기능이 정상 동작하는지 확인
- [ ] 관련 테이블/정책 확인
- [ ] 변경 영향 범위 파악

### 개발 중
- [ ] Migration 파일로 스키마 변경 기록
- [ ] 코드 변경과 DB 변경 동기화
- [ ] 각 단계마다 테스트

### 개발 후
- [ ] 전체 플로우 테스트
- [ ] seed.sql 업데이트 (필요시)
- [ ] 변경사항 문서화
- [ ] 커밋 전 다른 기능 확인

## 🎯 핵심 원칙

1. **Migration으로 모든 DB 변경 기록**: 재현 가능하게
2. **절대 reset 금지 (운영 중)**: 데이터 보존
3. **seed.sql 최신화**: 안전한 reset를 위해
4. **단계별 테스트**: 문제 조기 발견
5. **백업 습관화**: 중요 데이터는 항상 백업

## 🚀 권장 워크플로우

```
계획 → Migration 작성 → DB 적용 → 코드 변경 → 테스트 → 커밋
     ↑                                              ↓
     └──────────── 문제 발생 시 여기서 되돌림 ────────┘
```

## 예시: 새 기능 추가

```bash
# 1. 브랜치 생성
git checkout -b feature/new-storage-folder

# 2. Migration 작성
supabase migration new add_documents_storage_policy
# SQL 작성

# 3. 적용
supabase db push

# 4. Admin 코드 수정
# 업로드 경로 추가

# 5. 테스트
# 파일 업로드 테스트

# 6. 다른 기능 확인
# 배너 업로드 여전히 동작?
# 아이콘 업로드 여전히 동작?

# 7. 모두 OK면 커밋
git add .
git commit -m "feat: add documents storage support"
```

이렇게 하면 **하나를 고쳐도 다른 게 안 깨집니다**.
