-- ================================================
-- Pickly v9.14.0 — Organizations Migration
-- 목표: organizations 추가 + announcements에 organization_id 연결
--       기존 benefit_subcategories / subcategory_id 그대로 사용
-- ================================================
-- 작성일: 2025-11-13
-- 작성자: Claude Code
-- ================================================

-- 1) 기관 테이블 생성 (없으면)
create table if not exists public.organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  type text,
  region text,
  logo_url text,
  description text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- 2) announcements에 organization_id 추가 (없을 때만)
alter table public.announcements
  add column if not exists organization_id uuid
    references public.organizations(id) on delete set null;

-- 3) 기존 organization(text) → organizations로 이관
--    ✅ trim(lower()) 정규화로 중복 방지
insert into public.organizations(name)
select distinct trim(lower(organization))
from public.announcements
where organization is not null
  and trim(organization) <> ''
on conflict(name) do nothing;

-- 4) FK 매핑: 정규화된 이름으로 연결
update public.announcements a
set organization_id = o.id
from public.organizations o
where a.organization is not null
  and trim(lower(a.organization)) = o.name
  and a.organization_id is null;

-- 5) 인덱스 (조인/필터 성능 최적화)
create index if not exists idx_ann_org_id on public.announcements(organization_id);
create index if not exists idx_ann_subcat on public.announcements(subcategory_id);
create index if not exists idx_ann_status on public.announcements(status);
create index if not exists idx_org_name on public.organizations(name);

-- 6) Admin 필터용 복합 인덱스
create index if not exists idx_ann_admin_filter
on public.announcements(organization_id, category_id, subcategory_id, status);

-- 7) 리스트 조회용 커버링 인덱스
create index if not exists idx_ann_list_covering
on public.announcements(subcategory_id, status, created_at)
include (id, title, thumbnail_url, organization_id);

-- 8) 리스트 카드 전용 View (선택적 - Flutter에서 직접 JOIN 권장)
create or replace view public.v_announcement_cards as
select
  a.id,
  a.thumbnail_url,
  o.name as organization_name,
  a.title,
  a.status,
  a.subcategory_id,
  bs.name as subcategory_name,
  a.created_at,
  -- 정렬 우선순위 컬럼 추가
  case
    when a.status = 'ongoing' then 1
    when a.status = 'upcoming' then 2
    else 3
  end as status_priority
from public.announcements a
left join public.organizations o on o.id = a.organization_id
left join public.benefit_subcategories bs on bs.id = a.subcategory_id;

-- 9) 코멘트 추가 (문서화)
comment on table public.organizations is '기관 정보 테이블 (LH, SH, GH 등)';
comment on column public.announcements.organization_id is '기관 외래키 (organizations 테이블 참조)';
comment on view public.v_announcement_cards is '리스트 카드 전용 View (Flutter에서 직접 JOIN 권장)';

-- ================================================
-- 완료 메시지
-- ================================================
do $$
declare
  org_count int;
  mapped_count int;
begin
  select count(*) into org_count from public.organizations;
  select count(*) into mapped_count from public.announcements where organization_id is not null;

  raise notice '✅ Organizations Migration 완료!';
  raise notice '📊 생성된 기관 수: %', org_count;
  raise notice '🔗 연결된 공고 수: %', mapped_count;
end $$;
