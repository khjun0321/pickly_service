# ⚡ 빠른 시작 명령어 모음

**Pickly Service v7.2 자동 배포를 위한 필수 명령어**

---

## 🔐 1단계: Supabase 설정 (최초 1회)

```bash
# Supabase 로그인
supabase login

# 프로젝트 연결 (DB 비밀번호 입력 필요)
cd ~/Desktop/pickly_service
supabase link --project-ref vymxxpjxrorpywfmqpuk

# 로컬 Supabase 시작
supabase start

# DB 마이그레이션 적용
supabase db reset
```

**예상 소요 시간**: 3-5분

---

## 🚀 2단계: 자동 배포 스크립트 실행

```bash
cd ~/Desktop/pickly_service
bash scripts/auto_release_v7.2_safe.sh
```

**스크립트 실행 내용**:
- ✅ Supabase 연결 확인
- ✅ DB 마이그레이션 검증
- ✅ Flutter 앱 빌드 (analyze + build apk)
- ✅ Admin 앱 빌드 (npm install + build)
- ✅ 결과 리포트 출력

**예상 소요 시간**: 5-10분

---

## ✅ 3단계: 검증

```bash
# Supabase 상태 확인
supabase status

# DB 테이블 확인
psql postgresql://postgres:postgres@localhost:54322/postgres \
  -c "\dt"

# announcement_types 테이블 확인
psql postgresql://postgres:postgres@localhost:54322/postgres \
  -c "SELECT COUNT(*) FROM announcement_types;"
```

---

## 🔄 일상 작업 명령어

### Supabase 관리

```bash
# 시작
supabase start

# 상태 확인
supabase status

# 중지
supabase stop

# DB 리셋 (마이그레이션 재적용)
supabase db reset

# 마이그레이션 생성
supabase migration new migration_name
```

### Flutter 개발

```bash
cd ~/Desktop/pickly_service/apps/pickly_mobile

# 의존성 설치
flutter pub get

# 코드 생성 (Riverpod)
dart run build_runner build --delete-conflicting-outputs

# 분석
flutter analyze

# 테스트
flutter test

# 앱 실행
flutter run
```

### Admin 개발

```bash
cd ~/Desktop/pickly_service/apps/pickly_admin

# 의존성 설치
npm install

# 개발 서버 실행
npm run dev
# http://localhost:5173

# 프로덕션 빌드
npm run build

# 빌드 미리보기
npm run preview
```

---

## 🧹 정리 명령어

```bash
# Supabase 완전 정리
supabase stop
docker system prune -a

# Flutter 캐시 정리
cd apps/pickly_mobile
flutter clean
rm -rf .dart_tool/

# Admin 캐시 정리
cd apps/pickly_admin
rm -rf node_modules/ dist/
```

---

## 🆘 문제 해결 명령어

### Supabase 연결 문제

```bash
# 재로그인
supabase logout
supabase login

# 재연결
supabase link --project-ref vymxxpjxrorpywfmqpuk

# Docker 재시작
supabase stop
docker restart $(docker ps -aq)
supabase start
```

### Flutter 빌드 문제

```bash
cd apps/pickly_mobile

# 완전 정리 후 재빌드
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

### Admin 빌드 문제

```bash
cd apps/pickly_admin

# 완전 재설치
rm -rf node_modules package-lock.json
npm install
npm run build
```

---

## 📦 전체 프로세스 (한 번에 복사)

```bash
# 1. Supabase 설정
supabase login
cd ~/Desktop/pickly_service
supabase link --project-ref vymxxpjxrorpywfmqpuk
supabase start
supabase db reset

# 2. 자동 배포
bash scripts/auto_release_v7.2_safe.sh

# 3. 검증
supabase status
psql postgresql://postgres:postgres@localhost:54322/postgres -c "\dt"
```

---

## 🎯 다음 단계

배포가 완료되면:

```bash
# GitHub PR 생성
gh pr create \
  --base main \
  --head feature/refactor-db-schema \
  --title "feat: PRD v7.2 - Announcement Detail TabBar UI & Admin Enhancements" \
  --body-file docs/prd/PR_DESCRIPTION.md

# Release Tag 생성
git tag -a v7.2.0 -m "Release v7.2.0"
git push origin v7.2.0
```

---

**🤖 Generated with Claude Code**
**Co-Authored-By: Claude <noreply@anthropic.com>**
