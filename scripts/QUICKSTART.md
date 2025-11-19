# 🚀 Pickly Service - 빠른 시작 가이드

로컬 개발 환경을 **단 한 줄**로 시작하는 방법입니다.

---

## ⚡ 빠른 시작 (복붙용)

```bash
# 프로젝트 루트에서 실행
bash scripts/dev-start.sh
```

그게 전부입니다! 🎉

---

## 📋 사전 요구사항

### 필수 설치 항목
- ✅ **Docker Desktop** (macOS/Windows)
- ✅ **Node.js** v18+ (npm 포함)
- ✅ **Supabase CLI**

### 설치 확인
```bash
# Docker 확인
docker --version
# Docker version 24.0.0 이상

# Node.js 확인
node --version
# v18.0.0 이상

# Supabase CLI 확인
supabase --version
# 1.0.0 이상
```

### Supabase CLI 설치 (미설치 시)
```bash
# macOS (Homebrew)
brew install supabase/tap/supabase

# npm (모든 OS)
npm install -g supabase
```

---

## 🎯 첫 실행 가이드

### 1️⃣ 프로젝트 루트로 이동
```bash
cd /path/to/pickly_service
```

### 2️⃣ 스크립트 실행 권한 부여 (최초 1회만)
```bash
chmod +x scripts/dev-start.sh
chmod +x scripts/dev-stop.sh
chmod +x scripts/dev-reset.sh
```

### 3️⃣ 개발 환경 시작
```bash
bash scripts/dev-start.sh
```

### 4️⃣ 출력 예시 확인
```
ℹ️  프로젝트 루트 디렉토리 탐지 중...
✅ 프로젝트 루트: /Users/kwonhyunjun/Desktop/pickly_service
ℹ️  Docker 데몬 상태 확인 중...
✅ Docker 실행 중

================================
ℹ️  Supabase 로컬 환경 시작
================================

ℹ️  기존 Supabase 인스턴스 확인 중...
✅ 기존 인스턴스 중지 완료
ℹ️  포트 충돌 확인 중...
⚠️  포트 54322가 사용 중입니다. 프로세스 종료 시도 중...
✅ 포트 충돌 해결 완료
ℹ️  Supabase 시작 중... (최대 2분 소요)
✅ Supabase 로컬 환경 시작 완료!

         API URL: http://localhost:54321
     GraphQL URL: http://localhost:54321/graphql/v1
          DB URL: postgresql://postgres:postgres@localhost:54322/postgres
      Studio URL: http://localhost:54323
    Inbucket URL: http://localhost:54324
      JWT secret: super-secret-jwt-token-with-at-least-32-characters-long
        anon key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

================================
ℹ️  Pickly Admin 프론트엔드 시작
================================

⚠️  Admin 서버는 별도 터미널에서 실행됩니다.
ℹ️  중지하려면: Ctrl+C

✅ ================================
✨ 개발 환경 준비 완료!
✅ ================================

📍 접속 정보:
   Admin:    http://localhost:5190
   Supabase: http://localhost:54323
   API:      http://localhost:54321

📝 다음 명령어로 Admin 서버를 시작하세요:
   cd apps/pickly_admin && npm run dev

🔧 유용한 명령어:
   Supabase 상태:  supabase status
   DB 리셋:        supabase db reset
   Supabase 중지:  supabase stop

지금 Admin 서버를 시작하시겠습니까? (y/N):
```

### 5️⃣ Admin 서버 시작
프롬프트에서 **Y** 입력 또는:
```bash
cd apps/pickly_admin
npm run dev
```

---

## 🌐 접속 URL

| 서비스 | URL | 설명 |
|--------|-----|------|
| **Admin 대시보드** | http://localhost:5190 | React 관리자 페이지 |
| **Supabase Studio** | http://localhost:54323 | 데이터베이스 관리 UI |
| **Supabase API** | http://localhost:54321 | REST API 엔드포인트 |
| **GraphQL** | http://localhost:54321/graphql/v1 | GraphQL 엔드포인트 |
| **Inbucket (이메일)** | http://localhost:54324 | 로컬 이메일 테스트 |

---

## 🛑 종료 방법

### Admin 서버 종료
터미널에서 **Ctrl+C** 입력

### 전체 환경 종료
```bash
bash scripts/dev-stop.sh
```

---

## 🔄 일상적인 사용 패턴

### 매일 작업 시작 시
```bash
cd /path/to/pickly_service
bash scripts/dev-start.sh
# Y 입력 (Admin 서버 자동 시작)
```

### 작업 종료 시
```bash
# Admin 터미널에서 Ctrl+C
bash scripts/dev-stop.sh
```

### 문제 발생 시
```bash
bash scripts/dev-reset.sh
# 전체 환경 리셋 (DB 포함)
```

---

## 🐛 문제 해결

### 1. Docker 관련 오류

**증상:** `Docker daemon is not running`
```bash
# macOS
open -a Docker
# 30초 대기 후 스크립트 재실행
bash scripts/dev-start.sh
```

**증상:** `port is already allocated`
```bash
# 스크립트가 자동으로 해결하지만, 수동으로도 가능:
lsof -ti :54322 | xargs kill -9
bash scripts/dev-start.sh
```

---

### 2. Supabase 관련 오류

**증상:** `supabase start` 실패
```bash
# 1. 완전 중지
supabase stop

# 2. Docker 컨테이너 확인
docker ps -a | grep supabase

# 3. 재시작
bash scripts/dev-start.sh
```

**증상:** Migration 적용 오류
```bash
# DB 전체 리셋
bash scripts/dev-reset.sh
```

---

### 3. Admin 서버 관련 오류

**증상:** `Missing script: "dev"`
```bash
# 올바른 디렉토리 확인
pwd
# 출력: /Users/xxx/pickly_service/apps/pickly_admin

# 의존성 재설치
rm -rf node_modules package-lock.json
npm install
npm run dev
```

**증상:** 포트 5190 충돌
```bash
# 스크립트가 자동 해결하지만, 수동으로도 가능:
lsof -ti :5190 | xargs kill -9
cd apps/pickly_admin
npm run dev
```

---

### 4. 경로 관련 오류

**증상:** `프로젝트 루트를 찾을 수 없습니다`
```bash
# 올바른 위치에서 실행 중인지 확인
ls -la
# apps/, backend/, scripts/ 폴더가 보여야 함

# 정확한 경로로 이동
cd /Users/kwonhyunjun/Desktop/pickly_service
bash scripts/dev-start.sh
```

---

## 🎨 스크립트가 제공하는 기능

### ✅ 자동화된 작업들
1. **프로젝트 루트 자동 탐지**
   - 5단계 상위 디렉토리까지 자동 검색
   - apps/pickly_admin, backend/supabase 존재 확인

2. **Docker 상태 자동 관리**
   - Docker 실행 여부 확인
   - macOS에서 Docker Desktop 자동 실행 시도
   - 30초 대기 후 재확인

3. **포트 충돌 자동 해결**
   - Supabase 포트: 54321-54326
   - Admin 포트: 5190, 5180
   - 충돌 시 자동으로 프로세스 종료

4. **Supabase 환경 관리**
   - 기존 인스턴스 자동 중지
   - 새 인스턴스 시작
   - 상태 정보 출력

5. **에러 처리 및 안내**
   - 명확한 에러 메시지
   - 문제 해결 방법 자동 출력
   - 색상 코딩으로 가독성 향상

---

## 📂 스크립트 파일 구조

```
scripts/
├── dev-start.sh       # 🚀 개발 환경 시작 (이 가이드의 주인공)
├── dev-stop.sh        # 🛑 개발 환경 종료
├── dev-reset.sh       # 🔄 전체 환경 리셋
├── README.md          # 📚 상세 문서
└── QUICKSTART.md      # ⚡ 빠른 시작 가이드 (현재 문서)
```

---

## 💡 추가 팁

### 별도 터미널에서 Admin 실행
```bash
# 터미널 1: Supabase (백그라운드로 유지)
bash scripts/dev-start.sh
# N 입력 (Admin 시작 안 함)

# 터미널 2: Admin 서버
cd apps/pickly_admin
npm run dev
```

### VSCode에서 통합 터미널 사용
```bash
# 1. VSCode에서 프로젝트 열기
code /path/to/pickly_service

# 2. 통합 터미널 열기 (Ctrl+`)

# 3. 스크립트 실행
bash scripts/dev-start.sh
```

### tmux/screen 사용 (고급)
```bash
# tmux 세션 시작
tmux new -s pickly

# 창 분할 (Ctrl+B → ")
# 상단: Supabase
# 하단: Admin

# 상단 창에서
bash scripts/dev-start.sh

# 하단 창으로 이동 (Ctrl+B → 화살표)
cd apps/pickly_admin && npm run dev
```

---

## 🎯 다음 단계

이제 개발 환경이 준비되었습니다!

1. **Admin 로그인**
   - URL: http://localhost:5190/login
   - 계정: admin@pickly.com / admin123 (기본값)

2. **Supabase Studio 탐색**
   - URL: http://localhost:54323
   - 테이블 구조 확인
   - SQL 쿼리 실행

3. **API 테스트**
   - Postman/Insomnia로 API 테스트
   - Base URL: http://localhost:54321

---

## 🆘 도움이 필요하신가요?

1. **상세 문서**: `scripts/README.md` 확인
2. **스크립트 코드**: `scripts/dev-start.sh` 확인
3. **Supabase 상태**: `supabase status` 실행
4. **Docker 상태**: `docker ps` 실행

---

**작성일:** 2025-11-14
**버전:** 1.0.0
**작성자:** Claude Code

---

## 📌 핵심 요약

```bash
# 시작
bash scripts/dev-start.sh

# 종료
bash scripts/dev-stop.sh

# 리셋
bash scripts/dev-reset.sh
```

**그게 전부입니다!** 🎉
