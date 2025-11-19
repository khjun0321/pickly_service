#!/bin/bash

# ================================================
# Pickly Service - Local Development Environment Stop Script
# ================================================
# 목적: Admin + Supabase 로컬 환경을 안전하게 종료
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

echo ""
log_info "================================"
log_info "개발 환경 종료 중..."
log_info "================================"
echo ""

# 1. Admin dev 서버 종료 (포트 5190, 5180)
log_info "Admin dev 서버 종료 중..."
KILLED_ADMIN=false
for PORT in 5190 5180; do
    if lsof -ti :$PORT > /dev/null 2>&1; then
        log_warning "포트 $PORT에서 실행 중인 프로세스 종료..."
        lsof -ti :$PORT | xargs kill -9 2>/dev/null || true
        KILLED_ADMIN=true
    fi
done

if [ "$KILLED_ADMIN" = true ]; then
    log_success "Admin dev 서버 종료 완료"
else
    log_info "실행 중인 Admin dev 서버가 없습니다."
fi

# 2. Supabase 종료
log_info "Supabase 종료 중..."
if supabase status > /dev/null 2>&1; then
    supabase stop
    log_success "Supabase 종료 완료"
else
    log_info "실행 중인 Supabase가 없습니다."
fi

# 3. 백그라운드 npm 프로세스 종료
log_info "백그라운드 npm 프로세스 확인 중..."
if pgrep -f "npm run dev" > /dev/null 2>&1; then
    log_warning "백그라운드 npm 프로세스 종료 중..."
    pkill -f "npm run dev" || true
    log_success "백그라운드 프로세스 종료 완료"
fi

echo ""
log_success "================================"
log_success "✨ 모든 개발 환경이 종료되었습니다!"
log_success "================================"
echo ""
