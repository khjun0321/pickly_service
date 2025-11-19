# 🔐 Supabase 설정 가이드

**목적**: Pickly Service v7.2 자동 배포를 위한 Supabase 연결 설정

---

## 📋 준비 사항

### 1. Supabase CLI 설치 확인

```bash
supabase --version
# 출력 예: 1.x.x
```

만약 설치되어 있지 않다면:
```bash
brew install supabase/tap/supabase
```

---

## 🚀 설정 단계

### STEP 1️⃣: Supabase 로그인

```bash
supabase login
```

**실행 결과**:
- 브라우저가 자동으로 열립니다
- Supabase 계정으로 로그인합니다
- 터미널에 "Logged in" 메시지가 표시됩니다

**검증**:
```bash
supabase projects list
# 프로젝트 목록이 표시되어야 함
```

---

### STEP 2️⃣: 프로젝트 링크

```bash
cd ~/Desktop/pickly_service
supabase link --project-ref vymxxpjxrorpywfmqpuk
```

**프롬프트가 나타나면**:
- Database password 입력 (프로젝트 생성 시 설정한 비밀번호)
- 비밀번호를 모르는 경우: Supabase Dashboard → Settings → Database → Reset password

**실행 결과**:
```
Linked pickly_service to project vymxxpjxrorpywfmqpuk
```

**검증**:
```bash
ls -la .supabase/
# .supabase 디렉토리가 생성되어 있어야 함
```

---

### STEP 3️⃣: 로컬 Supabase 시작

```bash
supabase start
```

**실행 결과**:
- Docker 컨테이너가 시작됩니다
- API URL, DB URL 등이 표시됩니다
- 약 1-2분 소요

**출력 예시**:
```
Started supabase local development setup.

         API URL: http://127.0.0.1:54321
     GraphQL URL: http://127.0.0.1:54321/graphql/v1
          DB URL: postgresql://postgres:postgres@127.0.0.1:54322/postgres
      Studio URL: http://127.0.0.1:54323
    Inbucket URL: http://127.0.0.1:54324
      JWT secret: super-secret-jwt-token-with-at-least-32-characters-long
        anon key: ...
service_role key: ...
```

**검증**:
```bash
supabase status
# 모든 서비스가 "running" 상태여야 함
```

---

### STEP 4️⃣: 마이그레이션 적용

```bash
supabase db reset
```

**실행 결과**:
- 로컬 데이터베이스가 초기화됩니다
- `supabase/migrations/` 폴더의 모든 마이그레이션이 순차 적용됩니다
- `supabase/seed.sql` 시드 데이터가 로드됩니다

**검증**:
```bash
# announcement_types 테이블이 생성되었는지 확인
psql postgresql://postgres:postgres@localhost:54322/postgres \
  -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'announcement_types';"

# 결과: 1 (테이블이 존재)
```

---

## ✅ 설정 완료 확인

모든 단계가 완료되면:

```bash
# 1. Supabase 로그인 확인
supabase projects list

# 2. 프로젝트 링크 확인
ls -la .supabase/

# 3. 로컬 서비스 실행 확인
supabase status

# 4. DB 마이그레이션 확인
psql postgresql://postgres:postgres@localhost:54322/postgres \
  -c "\dt"
```

**예상 출력**:
- ✅ 프로젝트 목록에 pickly_service가 표시됨
- ✅ .supabase 디렉토리 존재
- ✅ 모든 Supabase 서비스가 "running"
- ✅ 테이블 목록에 announcements, announcement_types, age_categories 등이 표시됨

---

## 🚀 자동 배포 스크립트 실행

설정이 완료되면 자동 배포 스크립트를 실행할 수 있습니다:

```bash
cd ~/Desktop/pickly_service
bash scripts/auto_release_v7.2_safe.sh
```

**스크립트가 자동으로 처리하는 작업**:
1. ✅ Supabase 로그인 상태 확인
2. ✅ 프로젝트 링크 확인
3. ✅ Supabase 서비스 시작
4. ✅ DB 마이그레이션 적용 및 검증
5. ✅ Flutter 앱 빌드 및 분석
6. ✅ Admin 앱 빌드 및 검증
7. ✅ 결과 리포트 출력

---

## 🆘 문제 해결

### 문제 1: "Cannot use automatic login flow inside non-TTY environments"

**원인**: 스크립트 내에서 `supabase login` 자동 실행 불가

**해결**:
```bash
# 터미널에서 직접 실행
supabase login
```

---

### 문제 2: "Failed to link project"

**원인**: 잘못된 프로젝트 ref 또는 비밀번호

**해결**:
```bash
# 1. 올바른 프로젝트 ref 확인
supabase projects list

# 2. 비밀번호 확인/재설정
# Supabase Dashboard → Settings → Database → Reset password

# 3. 다시 링크
supabase link --project-ref vymxxpjxrorpywfmqpuk
```

---

### 문제 3: "Docker daemon not running"

**원인**: Docker가 실행 중이지 않음

**해결**:
```bash
# 1. Docker Desktop 실행
open -a Docker

# 2. Docker 상태 확인
docker ps

# 3. Supabase 재시작
supabase start
```

---

### 문제 4: "Port already in use"

**원인**: 기존 Supabase 인스턴스가 실행 중

**해결**:
```bash
# 1. 기존 인스턴스 중지
supabase stop

# 2. 모든 컨테이너 확인
docker ps -a | grep supabase

# 3. 필요시 강제 정리
docker stop $(docker ps -aq --filter "name=supabase")
docker rm $(docker ps -aq --filter "name=supabase")

# 4. 재시작
supabase start
```

---

### 문제 5: "Migration failed"

**원인**: SQL 구문 오류 또는 종속성 문제

**해결**:
```bash
# 1. 마이그레이션 파일 확인
ls -la supabase/migrations/

# 2. 문제가 있는 마이그레이션 확인
supabase db reset --debug

# 3. 수동 마이그레이션 테스트
psql postgresql://postgres:postgres@localhost:54322/postgres \
  -f supabase/migrations/20251027000002_add_announcement_types_and_custom_content.sql
```

---

## 📚 참고 자료

- **Supabase CLI 문서**: https://supabase.com/docs/guides/cli
- **로컬 개발 가이드**: https://supabase.com/docs/guides/cli/local-development
- **마이그레이션 가이드**: https://supabase.com/docs/guides/cli/managing-environments

---

## 🎯 빠른 참조

**로그인**:
```bash
supabase login
```

**링크**:
```bash
supabase link --project-ref vymxxpjxrorpywfmqpuk
```

**시작**:
```bash
supabase start
```

**리셋**:
```bash
supabase db reset
```

**상태 확인**:
```bash
supabase status
```

**중지**:
```bash
supabase stop
```

---

**🤖 Generated with Claude Code**
**Co-Authored-By: Claude <noreply@anthropic.com>**
