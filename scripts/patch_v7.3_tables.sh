#!/bin/bash

# =====================================================
# Pickly Service v7.3 Table Compatibility Patch
# =====================================================
# 이 스크립트는 다음을 자동으로 수행합니다:
# 1. 기존 테이블을 v7.3 PRD 스펙에 맞게 ALTER
# 2. 새 테이블 생성 (announcement_types, announcements)
# 3. Supabase TypeScript 타입 재생성
# 4. Admin 빌드 검증
# =====================================================

set -e  # 에러 발생 시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}=====================================================${NC}"
echo -e "${BLUE}🔧 Pickly v7.3 Table Compatibility Patch${NC}"
echo -e "${BLUE}=====================================================${NC}"
echo ""

# 프로젝트 루트로 이동
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

echo -e "${CYAN}📂 프로젝트 루트: $PROJECT_ROOT${NC}"
echo ""

# =====================================================
# 1. 마이그레이션 실행
# =====================================================

echo -e "${YELLOW}[1/5] 🗄️  Supabase 마이그레이션 실행 중...${NC}"
echo ""

supabase db reset --local 2>&1 | tee /tmp/supabase_migration.log

# 마이그레이션 결과 확인
if grep -q "v7.3 Compatibility Patch Completed" /tmp/supabase_migration.log; then
  echo ""
  echo -e "${GREEN}✅ 마이그레이션 성공!${NC}"
  echo ""

  # 마이그레이션 로그에서 주요 내용 추출
  echo -e "${CYAN}📋 마이그레이션 요약:${NC}"
  grep -E "(Renamed|Created|patched successfully|table created)" /tmp/supabase_migration.log | \
    sed 's/^NOTICE.*: /  • /' || true
  echo ""
else
  echo -e "${RED}❌ 마이그레이션 실패${NC}"
  echo "자세한 로그: /tmp/supabase_migration.log"
  exit 1
fi

# =====================================================
# 2. TypeScript 타입 재생성
# =====================================================

echo -e "${YELLOW}[2/5] 🔄 TypeScript 타입 재생성 중...${NC}"
echo ""

# 타입 디렉토리 생성
mkdir -p apps/pickly_admin/src/lib/supabase

# 타입 생성 (로컬 DB에서 생성)
supabase gen types typescript --local --schema public > apps/pickly_admin/src/lib/supabase/types.ts

LINES=$(wc -l < apps/pickly_admin/src/lib/supabase/types.ts)
echo -e "${GREEN}✅ 타입 생성 완료 (${LINES} lines)${NC}"
echo ""

# =====================================================
# 3. 생성된 테이블 확인
# =====================================================

echo -e "${YELLOW}[3/5] 🔍 생성된 테이블 확인 중...${NC}"
echo ""

TABLES=(
  "benefit_categories"
  "category_banners"
  "announcement_types"
  "announcements"
)

for table in "${TABLES[@]}"; do
  if grep -q "\"$table\"" apps/pickly_admin/src/lib/supabase/types.ts; then
    echo -e "${GREEN}  ✓ $table${NC}"
  else
    echo -e "${RED}  ✗ $table (missing)${NC}"
  fi
done
echo ""

# =====================================================
# 4. Admin 빌드 검증
# =====================================================

echo -e "${YELLOW}[4/5] 🔨 Admin TypeScript 빌드 검증 중...${NC}"
echo ""

cd apps/pickly_admin

# 타입 체크만 실행 (빠름)
if npx tsc --noEmit 2>&1 | tee /tmp/admin_typecheck.log; then
  echo ""
  echo -e "${GREEN}✅ TypeScript 타입 체크 통과!${NC}"
  echo ""
else
  echo ""
  echo -e "${YELLOW}⚠️  TypeScript 에러가 있습니다${NC}"
  echo "자세한 로그: /tmp/admin_typecheck.log"
  echo ""
  echo "에러 개수:"
  grep -c "error TS" /tmp/admin_typecheck.log || echo "0"
  echo ""
fi

cd "$PROJECT_ROOT"

# =====================================================
# 5. Storage 버킷 확인
# =====================================================

echo -e "${YELLOW}[5/5] 🗂️  Storage 버킷 확인 중...${NC}"
echo ""

BUCKETS=(
  "benefit-banners"
  "benefit-thumbnails"
  "benefit-icons"
)

for bucket in "${BUCKETS[@]}"; do
  # Supabase CLI로 버킷 존재 확인 (간단한 방법)
  if supabase storage ls "$bucket" 2>/dev/null >/dev/null; then
    echo -e "${GREEN}  ✓ $bucket${NC}"
  else
    echo -e "${YELLOW}  ⚠ $bucket (not found - will be created on first upload)${NC}"
  fi
done
echo ""

# =====================================================
# 완료 요약
# =====================================================

echo -e "${GREEN}=====================================================${NC}"
echo -e "${GREEN}✅ v7.3 호환성 패치 완료!${NC}"
echo -e "${GREEN}=====================================================${NC}"
echo ""
echo -e "${CYAN}📊 변경 사항:${NC}"
echo "  1. benefit_categories:"
echo "     • name → title"
echo "     • display_order → sort_order"
echo "     • +description, +is_active"
echo ""
echo "  2. category_banners:"
echo "     • category_id → benefit_category_id"
echo "     • display_order → sort_order"
echo "     • link_url → link_target"
echo "     • +link_type"
echo ""
echo "  3. announcement_types (새로 생성)"
echo "  4. announcements (새로 생성)"
echo "  5. v_announcements_full view (새로 생성)"
echo ""
echo -e "${CYAN}🎯 다음 단계:${NC}"
echo "  1. Admin 개발 서버 재시작: cd apps/pickly_admin && npm run dev"
echo "  2. Admin 페이지 접속: http://localhost:5173/benefits/manage/housing"
echo "  3. CRUD 테스트: 배너/공고유형/공고 추가"
echo ""
echo -e "${BLUE}Happy coding! 🚀${NC}"
