-- ================================================
-- Pickly v9.15.0 — Generic Announcement Details Table
-- 목표: 범용 공고 구조 - 카테고리별 특수 필드를 key-value로 저장
-- ================================================
-- 작성일: 2025-11-13
-- 작성자: Claude Code
-- ================================================

-- 1) announcement_details 테이블 생성
create table if not exists public.announcement_details (
  id uuid primary key default gen_random_uuid(),
  announcement_id uuid not null references public.announcements(id) on delete cascade,
  field_key text not null,
  field_value jsonb not null,
  field_type text not null check (field_type in ('text','number','date','link','json')),
  created_at timestamptz not null default now()
);

-- 2) 인덱스 최적화
-- 기본 인덱스 (announcement_id로 필터링)
create index if not exists idx_details_announcement
on public.announcement_details(announcement_id);

-- 필드 키 인덱스 (특정 필드 검색용)
create index if not exists idx_details_field_key
on public.announcement_details(field_key);

-- 복합 인덱스 (특정 공고의 특정 필드 조회)
create index if not exists idx_details_ann_key
on public.announcement_details(announcement_id, field_key);

-- GIN 인덱스 (JSONB 값 검색용)
create index if not exists idx_details_value_gin
on public.announcement_details using gin(field_value);

-- 3) 코멘트 (문서화)
comment on table public.announcement_details is
'범용 공고 확장 필드 - 카테고리별 특수 필드를 key-value-type으로 저장';

comment on column public.announcement_details.field_key is
'필드 키 (예: 지원금액, 교육기간, 카드유형 등)';

comment on column public.announcement_details.field_value is
'JSONB 형식의 필드 값 - 타입별로 자동 변환됨';

comment on column public.announcement_details.field_type is
'값 타입: text(문자열), number(숫자), date(날짜), link(URL), json(복잡한 객체)';

-- 4) 완료 메시지
do $$
begin
  raise notice '✅ announcement_details 테이블 생성 완료';
  raise notice '📊 인덱스 4개 생성됨 (announcement, field_key, ann_key, value_gin)';
  raise notice '🔗 FK: announcements(id) on delete cascade';
  raise notice '✅ PRD v9.15.0: 범용 공고 구조 1차 완료';
end $$;
