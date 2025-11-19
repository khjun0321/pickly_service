#!/bin/bash

# ================================================
# Pickly Service - Local Development Environment Startup Script
# ================================================
# 목적: Admin + Supabase 로컬 환경을 자동으로 시작
# 작성일: 2025-11-14
# ================================================

set -e  # 에러 발생 시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로깅 함수
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# ================================================
# 1. 프로젝트 루트 디렉토리 자동 탐지
# ================================================

log_info "프로젝트 루트 디렉토리 탐지 중..."

# 현재 스크립트 위치 기준으로 루트 찾기
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 검증: apps/pickly_admin과 backend/supabase 존재 확인
if [ ! -d "$PROJECT_ROOT/apps/pickly_admin" ] || [ ! -d "$PROJECT_ROOT/backend/supabase" ]; then
    log_error "프로젝트 루트를 찾을 수 없습니다."
    log_info "현재 위치: $PWD"
    log_info "예상 루트: $PROJECT_ROOT"

    # 상위 디렉토리 탐색 시도
    log_info "상위 디렉토리에서 프로젝트 루트 검색 중..."
    SEARCH_DIR="$PWD"
    FOUND=false

    for i in {1..5}; do
        if [ -d "$SEARCH_DIR/apps/pickly_admin" ] && [ -d "$SEARCH_DIR/backend/supabase" ]; then
            PROJECT_ROOT="$SEARCH_DIR"
            FOUND=true
            break
        fi
        SEARCH_DIR="$(dirname "$SEARCH_DIR")"
    done

    if [ "$FOUND" = false ]; then
        log_error "프로젝트 루트를 찾을 수 없습니다. 다음 위치에서 실행해주세요:"
        log_error "  cd /path/to/pickly_service && bash scripts/dev-start.sh"
        exit 1
    fi
fi

log_success "프로젝트 루트: $PROJECT_ROOT"
cd "$PROJECT_ROOT"

# ================================================
# 2. Docker 상태 확인
# ================================================

log_info "Docker 데몬 상태 확인 중..."

if ! docker info > /dev/null 2>&1; then
    log_error "Docker가 실행되지 않았습니다!"
    log_warning "Docker Desktop을 실행해주세요:"
    log_warning "  1. Docker Desktop 앱 실행"
    log_warning "  2. Docker가 완전히 시작될 때까지 대기 (약 10-30초)"
    log_warning "  3. 이 스크립트를 다시 실행"

    # macOS에서 자동으로 Docker 실행 시도
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log_info "Docker Desktop 자동 실행 시도 중..."
        open -a Docker
        log_warning "Docker가 시작될 때까지 30초 대기 중..."
        sleep 30

        if ! docker info > /dev/null 2>&1; then
            log_error "Docker가 여전히 실행되지 않습니다. 수동으로 Docker Desktop을 실행해주세요."
            exit 1
        fi
    else
        exit 1
    fi
fi

log_success "Docker 실행 중"

# ================================================
# 3. Supabase 로컬 환경 시작
# ================================================

log_info "================================"
log_info "Supabase 로컬 환경 시작"
log_info "================================"

cd "$PROJECT_ROOT/backend/supabase"

# 기존 Supabase 인스턴스 중지
log_info "기존 Supabase 인스턴스 확인 중..."
if supabase status > /dev/null 2>&1; then
    log_warning "실행 중인 Supabase 인스턴스 발견. 중지 중..."
    supabase stop
    log_success "기존 인스턴스 중지 완료"
fi

# 포트 충돌 확인 및 해결
log_info "포트 충돌 확인 중..."
PORTS=(54321 54322 54323 54324 54325 54326)
CONFLICTS=false

for PORT in "${PORTS[@]}"; do
    if lsof -ti :$PORT > /dev/null 2>&1; then
        log_warning "포트 $PORT가 사용 중입니다. 프로세스 종료 시도 중..."
        lsof -ti :$PORT | xargs kill -9 2>/dev/null || true
        CONFLICTS=true
    fi
done

if [ "$CONFLICTS" = true ]; then
    log_success "포트 충돌 해결 완료"
    sleep 2
fi

# Supabase 시작
log_info "Supabase 시작 중... (최대 2분 소요)"
if supabase start; then
    log_success "Supabase 로컬 환경 시작 완료!"
    echo ""
    supabase status
    echo ""
else
    log_error "Supabase 시작 실패!"
    log_warning "문제 해결 방법:"
    log_warning "  1. Docker Desktop이 정상 실행 중인지 확인"
    log_warning "  2. 디스크 공간 확인 (최소 5GB 필요)"
    log_warning "  3. 포트 충돌 확인: lsof -i :54321-54326"
    log_warning "  4. 전체 재설정: supabase stop && supabase start"
    exit 1
fi

# ================================================
# 4. Admin 프론트엔드 시작 (백그라운드)
# ================================================

log_info "================================"
log_info "Pickly Admin 프론트엔드 시작"
log_info "================================"

cd "$PROJECT_ROOT/apps/pickly_admin"

# package.json 존재 확인
if [ ! -f "package.json" ]; then
    log_error "package.json을 찾을 수 없습니다!"
    log_error "현재 위치: $PWD"
    exit 1
fi

# node_modules 확인 및 설치
if [ ! -d "node_modules" ]; then
    log_warning "node_modules가 없습니다. npm install 실행 중..."
    npm install
    log_success "npm install 완료"
fi

# 기존 dev 서버 중지 (포트 5190, 5180)
log_info "기존 dev 서버 확인 중..."
for PORT in 5190 5180; do
    if lsof -ti :$PORT > /dev/null 2>&1; then
        log_warning "포트 $PORT에서 실행 중인 프로세스 종료 중..."
        lsof -ti :$PORT | xargs kill -9 2>/dev/null || true
    fi
done

# Admin dev 서버 시작
log_info "Admin dev 서버 시작 중..."
log_warning "Admin 서버는 별도 터미널에서 실행됩니다."
log_info "중지하려면: Ctrl+C"

echo ""
log_success "================================"
log_success "✨ 개발 환경 준비 완료!"
log_success "================================"
echo ""
echo -e "${GREEN}📍 접속 정보:${NC}"
echo -e "   Admin:    ${BLUE}http://localhost:5190${NC}"
echo -e "   Supabase: ${BLUE}http://localhost:54323${NC}"
echo -e "   API:      ${BLUE}http://localhost:54321${NC}"
echo ""
echo -e "${YELLOW}📝 다음 명령어로 Admin 서버를 시작하세요:${NC}"
echo -e "   ${BLUE}cd apps/pickly_admin && npm run dev${NC}"
echo ""
echo -e "${YELLOW}🔧 유용한 명령어:${NC}"
echo -e "   Supabase 상태:  ${BLUE}supabase status${NC}"
echo -e "   DB 리셋:        ${BLUE}supabase db reset${NC}"
echo -e "   Supabase 중지:  ${BLUE}supabase stop${NC}"
echo ""

# 사용자에게 Admin 서버 시작 여부 물어보기
read -p "지금 Admin 서버를 시작하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "Admin dev 서버 시작 중..."
    npm run dev
else
    log_info "수동으로 Admin 서버를 시작하려면:"
    log_info "  cd apps/pickly_admin && npm run dev"
fi
