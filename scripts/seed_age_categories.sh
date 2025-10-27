#!/usr/bin/env bash
# ==========================================================
# 🚀 Pickly Service - Supabase 기본 연령 카테고리 시드 스크립트
# ==========================================================

set -e
cd ~/Desktop/pickly_service || exit

echo "==============================================="
echo "🏷️ Pickly - 기본 연령 카테고리 시드 데이터 등록"
echo "==============================================="

# Supabase 로그인 상태 확인
if ! supabase projects list &>/dev/null; then
  echo "⚠️ Supabase 로그인 필요. 실행 전 'supabase login' 입력해주세요."
  exit 1
fi

# 프로젝트 링크 확인
if [ ! -f "supabase/config.toml" ]; then
  echo "⚠️ Supabase 프로젝트 링크 필요. 실행 전 'supabase link --project-ref vymxxpjxrorpywfmqpuk' 입력해주세요."
  exit 1
fi

# 시드 SQL 생성
mkdir -p supabase/seeds

cat > supabase/seeds/seed_age_categories.sql <<'SQL'
-- =============================================
-- 🏷️ Pickly v7.2 기본 연령 카테고리 초기 세팅
-- =============================================

-- 기존 데이터 초기화
delete from age_categories;

-- 기본 카테고리 삽입
insert into age_categories (id, name, description, min_age, max_age)
values
(1, '청년', '(만 19세~39세) 대학생, 취업준비생, 직장인', 19, 39),
(2, '신혼부부·예비부부', '결혼 예정 또는 결혼 7년 이내', null, null),
(3, '육아중인 부모', '영유아~초등 자녀 양육 중', null, null),
(4, '다자녀 가구', '자녀 2명 이상 양육 중', null, null),
(5, '어르신', '만 65세 이상', 65, null),
(6, '장애인', '장애인 등록 대상', null, null);

-- 확인용 출력
select * from age_categories order by id;
SQL

# 로컬 Supabase DB에 적용
echo "📦 로컬 Supabase DB에 시드 적용 중..."
psql postgresql://postgres:postgres@localhost:54322/postgres \
  -f supabase/seed_age_categories.sql || {
  echo "❌ 시드 적용 실패. Supabase가 실행 중인지 확인하세요."
  echo "   실행 명령: supabase start"
  exit 1
}

echo ""
echo "✅ 시드 데이터 등록 완료!"
echo "🧩 확인 명령: psql postgresql://postgres:postgres@localhost:54322/postgres -c 'SELECT * FROM age_categories ORDER BY id;'"
echo "==============================================="
