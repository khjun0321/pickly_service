-- ================================================
-- Pickly v9.14.0 — Organizations Rollback Script
-- 목표: 20251113000001_add_organizations.sql 완전 되돌리기
-- ================================================
-- 경고: 이 스크립트는 organizations 테이블과 모든 관련 데이터를 삭제합니다!
-- ================================================

-- 1) View 삭제
drop view if exists public.v_announcement_cards cascade;

-- 2) 인덱스 삭제
drop index if exists public.idx_ann_list_covering;
drop index if exists public.idx_ann_admin_filter;
drop index if exists public.idx_org_name;
drop index if exists public.idx_ann_status;
drop index if exists public.idx_ann_subcat;
drop index if exists public.idx_ann_org_id;

-- 3) FK 제약 조건 삭제
alter table public.announcements
  drop constraint if exists announcements_organization_id_fkey;

-- 4) 컬럼 삭제
alter table public.announcements
  drop column if exists organization_id;

-- 5) 테이블 삭제
drop table if exists public.organizations cascade;

-- ================================================
-- 완료 메시지
-- ================================================
do $$
begin
  raise notice '✅ Organizations Rollback 완료!';
  raise notice '⚠️  기존 organization(text) 필드는 그대로 유지되었습니다.';
end $$;
