-- ================================================
-- Pickly v9.15.0 Hotfix — RPC: save_announcement_with_details
-- 목표: organization_id UPDATE 문 제거 (프론트엔드 미전송)
-- ================================================
-- 작성일: 2025-11-14
-- 작성자: Claude Code
-- 이슈: Frontend에서 organization_id를 보내지 않아 RPC 오류 발생
-- 해결: UPDATE SET 절에서 organization_id 제거
-- ================================================

create or replace function public.save_announcement_with_details(
  p_announcement jsonb,
  p_details jsonb[] default array[]::jsonb[]
)
returns uuid
language plpgsql
security definer
as $$
declare
  v_id uuid;
begin
  -- 1) announcement upsert
  -- id가 있으면 update, 없으면 insert
  insert into public.announcements (
    id,
    title,
    subtitle,
    category_id,
    subcategory_id,
    organization,
    organization_id,
    status,
    content,
    thumbnail_url,
    external_url,
    detail_url,
    link_type,
    region,
    application_start_date,
    application_end_date,
    deadline_date,
    tags,
    is_featured,
    is_home_visible,
    is_priority,
    display_priority,
    views_count,
    search_vector
  )
  select
    (p_announcement->>'id')::uuid,
    p_announcement->>'title',
    p_announcement->>'subtitle',
    (p_announcement->>'category_id')::uuid,
    (p_announcement->>'subcategory_id')::uuid,
    p_announcement->>'organization',
    (p_announcement->>'organization_id')::uuid,
    p_announcement->>'status',
    p_announcement->>'content',
    p_announcement->>'thumbnail_url',
    p_announcement->>'external_url',
    p_announcement->>'detail_url',
    p_announcement->>'link_type',
    p_announcement->>'region',
    (p_announcement->>'application_start_date')::timestamptz,
    (p_announcement->>'application_end_date')::timestamptz,
    (p_announcement->>'deadline_date')::date,
    case
      when p_announcement->'tags' is null then null
      else array(select jsonb_array_elements_text(p_announcement->'tags'))
    end,
    (p_announcement->>'is_featured')::boolean,
    (p_announcement->>'is_home_visible')::boolean,
    (p_announcement->>'is_priority')::boolean,
    (p_announcement->>'display_priority')::integer,
    (p_announcement->>'views_count')::integer,
    null  -- search_vector는 트리거로 자동 생성
  on conflict (id) do update set
    -- ✅ HOTFIX: organization_id 제거 (Frontend에서 전송 안함)
    title = excluded.title,
    subtitle = excluded.subtitle,
    category_id = excluded.category_id,
    subcategory_id = excluded.subcategory_id,
    organization = excluded.organization,
    -- ❌ organization_id = excluded.organization_id,  -- REMOVED
    status = excluded.status,
    content = excluded.content,
    thumbnail_url = excluded.thumbnail_url,
    external_url = excluded.external_url,
    detail_url = excluded.detail_url,
    link_type = excluded.link_type,
    region = excluded.region,
    application_start_date = excluded.application_start_date,
    application_end_date = excluded.application_end_date,
    deadline_date = excluded.deadline_date,
    tags = excluded.tags,
    is_featured = excluded.is_featured,
    is_home_visible = excluded.is_home_visible,
    is_priority = excluded.is_priority,
    display_priority = excluded.display_priority,
    views_count = excluded.views_count,
    updated_at = now()
  returning id into v_id;

  -- id가 null이면 insert된 id를 가져옴
  if v_id is null then
    v_id := (p_announcement->>'id')::uuid;
    if v_id is null then
      -- insert 시 자동 생성된 id 가져오기
      select id into v_id
      from public.announcements
      order by created_at desc
      limit 1;
    end if;
  end if;

  -- 2) details 전체 교체
  delete from public.announcement_details
  where announcement_id = v_id;

  -- 3) details 일괄 삽입
  if array_length(p_details, 1) > 0 then
    insert into public.announcement_details (
      announcement_id,
      field_key,
      field_value,
      field_type
    )
    select
      v_id,
      d->>'field_key',
      case
        when (d->>'field_type') = 'number' then
          to_jsonb((d->>'field_value')::numeric)
        when (d->>'field_type') = 'date' then
          to_jsonb((d->>'field_value')::date)
        when (d->>'field_type') = 'json' then
          (d->'field_value')::jsonb
        else
          to_jsonb(d->>'field_value')
      end,
      d->>'field_type'
    from unnest(p_details) as d
    where d->>'field_key' is not null
      and d->>'field_key' != '';
  end if;

  return v_id;
end;
$$;

-- 코멘트 업데이트
comment on function public.save_announcement_with_details is
'공고 기본정보 + 확장필드를 단일 트랜잭션으로 저장. v9.15.0 Hotfix: organization_id UPDATE 제거';

-- 완료 메시지
do $$
begin
  raise notice '✅ save_announcement_with_details Hotfix 적용 완료';
  raise notice '🔧 변경사항: UPDATE SET 절에서 organization_id 제거';
  raise notice '📌 이유: Frontend에서 organization_id 미전송으로 인한 RPC 오류 방지';
  raise notice '✅ PRD v9.15.0 Hotfix: RPC 함수 수정 완료';
end $$;
