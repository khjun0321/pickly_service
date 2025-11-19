#!/bin/bash

# ================================================
# Pickly Service - Development Environment Reset Script
# ================================================
# 목적: 전체 개발 환경을 깨끗하게 리셋
# 작성일: 2025-11-14
# ================================================

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# 프로젝트 루트 찾기
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo ""
log_warning "================================"
log_warning "⚠️  개발 환경 전체 리셋"
log_warning "================================"
echo ""
log_warning "다음 작업이 수행됩니다:"
echo "  1. Supabase 중지 및 DB 리셋"
echo "  2. Admin 프론트엔드 중지"
echo "  3. 마이그레이션 재적용"
echo "  4. 개발 환경 재시작"
echo ""

read -p "계속하시겠습니까? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "리셋이 취소되었습니다."
    exit 0
fi

echo ""
log_info "리셋 시작..."

# 1. 기존 환경 종료
log_info "1/4: 기존 환경 종료 중..."
bash "$SCRIPT_DIR/dev-stop.sh"

# 2. Supabase DB 리셋
log_info "2/4: Supabase DB 리셋 중..."
cd "$PROJECT_ROOT/backend/supabase"

if ! docker info > /dev/null 2>&1; then
    log_error "Docker가 실행되지 않았습니다. Docker Desktop을 실행해주세요."
    exit 1
fi

log_warning "Supabase 시작 및 DB 리셋 중... (최대 3분 소요)"
supabase start
supabase db reset --db-url postgresql://postgres:postgres@localhost:54322/postgres

log_success "DB 리셋 완료"

# 3. Admin node_modules 클린 (선택사항)
log_info "3/4: Admin 의존성 확인 중..."
cd "$PROJECT_ROOT/apps/pickly_admin"

if [ -d "node_modules" ]; then
    log_info "node_modules가 이미 존재합니다. (재설치하려면 수동으로 삭제하세요)"
else
    log_info "npm install 실행 중..."
    npm install
    log_success "의존성 설치 완료"
fi

# 4. 개발 환경 재시작
log_info "4/4: 개발 환경 정보 출력..."

echo ""
log_success "================================"
log_success "✨ 리셋 완료!"
log_success "================================"
echo ""
echo -e "${GREEN}📍 Supabase 상태:${NC}"
cd "$PROJECT_ROOT/backend/supabase"
supabase status
echo ""
echo -e "${YELLOW}📝 다음 명령어로 Admin 서버를 시작하세요:${NC}"
echo -e "   ${BLUE}cd apps/pickly_admin && npm run dev${NC}"
echo ""
echo -e "${YELLOW}🔧 또는 자동 시작 스크립트 사용:${NC}"
echo -e "   ${BLUE}bash scripts/dev-start.sh${NC}"
echo ""
