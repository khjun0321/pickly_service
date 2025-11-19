-- ================================================================
-- RPC Function: save_announcement_tabs
-- Purpose: Atomically save/update tabs for a specific announcement
-- ================================================================
-- This function handles:
--   1. Deletes all existing tabs for the announcement (CASCADE deletes contents/images)
--   2. Inserts new tabs with their contents and images
--   3. Maintains referential integrity across all 3 tables
-- ================================================================

create or replace function public.save_announcement_tabs(
  p_announcement_id uuid,
  p_tabs jsonb
)
returns void
language plpgsql
as $$
declare
  v_tab jsonb;
  v_content jsonb;
  v_image jsonb;
  v_tab_id uuid;
begin
  -- Delete all existing tabs for this announcement
  -- CASCADE will automatically delete related contents and images
  delete from public.announcement_tabs where announcement_id = p_announcement_id;

  -- Loop through each tab in the input array
  for v_tab in select * from jsonb_array_elements(p_tabs)
  loop
    -- Insert the tab and get its ID
    -- Note: Using tab_name and display_order to match existing schema
    insert into public.announcement_tabs(announcement_id, tab_name, display_order)
    values(
      p_announcement_id,
      v_tab->>'title',
      coalesce((v_tab->>'sort_order')::int, 0)
    )
    returning id into v_tab_id;

    -- Insert tab contents (if any)
    if v_tab->'contents' is not null then
      for v_content in select * from jsonb_array_elements(v_tab->'contents')
      loop
        insert into public.announcement_tab_contents(tab_id, section_title, section_body, sort_order)
        values(
          v_tab_id,
          v_content->>'section_title',
          v_content->>'section_body',
          coalesce((v_content->>'sort_order')::int, 0)
        );
      end loop;
    end if;

    -- Insert tab images (if any)
    if v_tab->'images' is not null then
      for v_image in select * from jsonb_array_elements(v_tab->'images')
      loop
        insert into public.announcement_tab_images(tab_id, image_url, caption, sort_order)
        values(
          v_tab_id,
          v_image->>'image_url',
          v_image->>'caption',
          coalesce((v_image->>'sort_order')::int, 0)
        );
      end loop;
    end if;
  end loop;
end;
$$;

-- Grant execute permission to authenticated users (Admin only)
grant execute on function public.save_announcement_tabs(uuid, jsonb) to authenticated;
grant execute on function public.save_announcement_tabs(uuid, jsonb) to service_role;
