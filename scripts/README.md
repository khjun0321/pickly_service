# Pickly Service - 개발 환경 스크립트

로컬 개발 환경을 쉽게 관리하기 위한 자동화 스크립트 모음입니다.

## 📋 스크립트 목록

### 1. `dev-start.sh` - 개발 환경 시작

Admin 프론트엔드와 Supabase 로컬 환경을 자동으로 시작합니다.

**사용법:**
```bash
bash scripts/dev-start.sh
```

**기능:**
- ✅ 프로젝트 루트 자동 탐지
- ✅ Docker 상태 확인 및 자동 실행 (macOS)
- ✅ 포트 충돌 자동 해결
- ✅ Supabase 로컬 환경 시작
- ✅ Admin 프론트엔드 시작 옵션 제공

**출력 예시:**
```
✅ 프로젝트 루트: /Users/xxx/pickly_service
✅ Docker 실행 중
✅ Supabase 로컬 환경 시작 완료!
✅ ================================
✨ 개발 환경 준비 완료!
================================

📍 접속 정보:
   Admin:    http://localhost:5190
   Supabase: http://localhost:54323
   API:      http://localhost:54321
```

---

### 2. `dev-stop.sh` - 개발 환경 종료

실행 중인 모든 개발 환경을 안전하게 종료합니다.

**사용법:**
```bash
bash scripts/dev-stop.sh
```

**기능:**
- ✅ Admin dev 서버 종료 (포트 5190, 5180)
- ✅ Supabase 로컬 환경 종료
- ✅ 백그라운드 npm 프로세스 종료

---

### 3. `dev-reset.sh` - 개발 환경 전체 리셋

DB를 포함한 전체 개발 환경을 깨끗하게 리셋합니다.

**사용법:**
```bash
bash scripts/dev-reset.sh
```

**기능:**
- ✅ 기존 환경 종료
- ✅ Supabase DB 리셋 (모든 마이그레이션 재적용)
- ✅ Admin 의존성 확인
- ✅ 개발 환경 재시작

**⚠️ 주의:**
- DB의 모든 데이터가 초기화됩니다
- 테스트 데이터는 사라집니다

---

## 🚀 빠른 시작 가이드

### 처음 시작할 때
```bash
# 1. 프로젝트 루트로 이동
cd /path/to/pickly_service

# 2. 개발 환경 시작
bash scripts/dev-start.sh

# 3. Admin 서버 시작 (자동 실행 또는 수동)
cd apps/pickly_admin
npm run dev
```

### 매일 작업 시작 시
```bash
bash scripts/dev-start.sh
```

### 작업 종료 시
```bash
bash scripts/dev-stop.sh
```

### 문제 발생 시
```bash
# 전체 리셋 후 재시작
bash scripts/dev-reset.sh
```

---

## 🔧 트러블슈팅

### Docker 관련 오류

**증상:** `Docker daemon is not running`
```bash
# macOS
open -a Docker
# Docker가 시작될 때까지 30초 대기 후 재시도
```

**증상:** `port is already allocated`
```bash
# 포트 충돌 수동 해결
lsof -ti :54322 | xargs kill -9
lsof -ti :5190 | xargs kill -9
```

### Supabase 관련 오류

**증상:** `supabase start` 실패
```bash
# 1. 기존 인스턴스 완전 중지
supabase stop

# 2. Docker 컨테이너 확인
docker ps -a | grep supabase

# 3. 재시작
supabase start
```

**증상:** Migration 오류
```bash
# DB 전체 리셋
bash scripts/dev-reset.sh
```

### Admin 서버 관련 오류

**증상:** `Missing script: "dev"`
```bash
# 올바른 디렉토리에서 실행 중인지 확인
pwd  # /path/to/pickly_service/apps/pickly_admin 여야 함

# 의존성 재설치
rm -rf node_modules package-lock.json
npm install
```

**증상:** 포트 충돌 (5190, 5180)
```bash
# 기존 프로세스 종료
lsof -ti :5190 | xargs kill -9
lsof -ti :5180 | xargs kill -9
```

---

## 📊 환경 정보

### 기본 포트
- **Admin Dev Server:** 5190 (fallback: 5180)
- **Supabase API:** 54321
- **Supabase DB:** 54322
- **Supabase Studio:** 54323
- **Supabase Inbucket (Mail):** 54324
- **Supabase Kong (Gateway):** 54325
- **Supabase Auth:** 54326

### 디렉토리 구조
```
pickly_service/
├── apps/
│   └── pickly_admin/          # React Admin 프론트엔드
│       ├── src/
│       ├── package.json
│       └── vite.config.ts
├── backend/
│   └── supabase/              # Supabase 로컬 환경
│       ├── migrations/
│       ├── seed.sql
│       └── config.toml
└── scripts/                   # 개발 환경 스크립트
    ├── dev-start.sh
    ├── dev-stop.sh
    ├── dev-reset.sh
    └── README.md
```

---

## 🎯 권장 워크플로우

### 일반 개발
1. `bash scripts/dev-start.sh` - 환경 시작
2. 코드 작업
3. `bash scripts/dev-stop.sh` - 환경 종료

### DB 스키마 변경 후
1. Migration 파일 생성
2. `bash scripts/dev-reset.sh` - DB 리셋 및 마이그레이션 적용
3. 테스트

### 문제 발생 시
1. `bash scripts/dev-stop.sh` - 모두 종료
2. `bash scripts/dev-reset.sh` - 전체 리셋
3. 문제 재현 시도

---

## 📝 추가 명령어

### Supabase 명령어
```bash
# 상태 확인
supabase status

# DB 리셋 (마이그레이션 재적용)
supabase db reset

# 로그 확인
supabase logs

# 새 마이그레이션 생성
supabase migration new <name>
```

### Docker 명령어
```bash
# Supabase 컨테이너 확인
docker ps | grep supabase

# 컨테이너 로그 확인
docker logs supabase_db_supabase
docker logs supabase_auth_supabase

# 볼륨 확인
docker volume ls | grep supabase
```

---

## 🐛 버그 리포트

스크립트에 문제가 있거나 개선 사항이 있다면:
1. 에러 메시지 전체 복사
2. 실행한 명령어
3. 환경 정보 (OS, Docker 버전 등)

위 정보와 함께 이슈를 생성해주세요.

---

**작성일:** 2025-11-14
**작성자:** Claude Code
**버전:** 1.0.0
