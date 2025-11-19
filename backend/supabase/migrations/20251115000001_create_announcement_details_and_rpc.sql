-- ============================================
-- Migration: Create announcement_details table and complete RPC function
-- PRD v9.15.0 - Benefit Announcement Details
-- Purpose: Store floor plan images, PDFs, and descriptions
-- Date: 2025-11-15
-- ============================================

-- ============================================
-- 1️⃣ Create announcement_details table
-- ============================================

CREATE TABLE IF NOT EXISTS public.announcement_details (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  announcement_id UUID NOT NULL REFERENCES announcements(id) ON DELETE CASCADE,
  field_key TEXT NOT NULL,         -- e.g. "floor_plan_image", "announcement_pdf", "description"
  field_value TEXT NOT NULL,       -- URL or description text
  field_type TEXT NOT NULL,        -- e.g. "link" | "text"
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_announcement_details_announcement_id
  ON public.announcement_details (announcement_id);

-- ============================================
-- 2️⃣ Create complete RPC function with details handling
-- ============================================

CREATE OR REPLACE FUNCTION public.save_announcement_with_details(
  p_announcement JSONB,
  p_details JSONB[]
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
  v_announcement_id UUID;
  v_tags TEXT[];
  v_detail_count INTEGER := 0;
BEGIN
  -- Extract announcement ID
  v_announcement_id := (p_announcement->>'id')::UUID;

  -- Convert JSONB array to TEXT[] for tags
  IF p_announcement->'tags' IS NOT NULL THEN
    SELECT ARRAY(SELECT jsonb_array_elements_text(p_announcement->'tags'))
    INTO v_tags;
  ELSE
    v_tags := ARRAY[]::TEXT[];
  END IF;

  -- Insert or update main announcement
  INSERT INTO public.announcements (
    id, title, subtitle, category_id, subcategory_id, organization,
    status, content, thumbnail_url, external_url, detail_url, link_type,
    region, application_start_date, application_end_date, deadline_date,
    tags, is_featured, is_home_visible, is_priority, display_priority, views_count
  )
  SELECT
    v_announcement_id,
    (p_announcement->>'title')::TEXT,
    (p_announcement->>'subtitle')::TEXT,
    (p_announcement->>'category_id')::UUID,
    (p_announcement->>'subcategory_id')::UUID,
    (p_announcement->>'organization')::TEXT,
    (p_announcement->>'status')::TEXT,
    (p_announcement->>'content')::TEXT,
    (p_announcement->>'thumbnail_url')::TEXT,
    (p_announcement->>'external_url')::TEXT,
    (p_announcement->>'detail_url')::TEXT,
    (p_announcement->>'link_type')::TEXT,
    (p_announcement->>'region')::TEXT,
    (p_announcement->>'application_start_date')::TIMESTAMPTZ,
    (p_announcement->>'application_end_date')::TIMESTAMPTZ,
    (p_announcement->>'deadline_date')::DATE,
    v_tags,
    COALESCE((p_announcement->>'is_featured')::BOOLEAN, false),
    COALESCE((p_announcement->>'is_home_visible')::BOOLEAN, false),
    COALESCE((p_announcement->>'is_priority')::BOOLEAN, false),
    COALESCE((p_announcement->>'display_priority')::INTEGER, 0),
    COALESCE((p_announcement->>'views_count')::INTEGER, 0)
  ON CONFLICT (id) DO UPDATE SET
    title = EXCLUDED.title,
    subtitle = EXCLUDED.subtitle,
    category_id = EXCLUDED.category_id,
    subcategory_id = EXCLUDED.subcategory_id,
    organization = EXCLUDED.organization,
    status = EXCLUDED.status,
    content = EXCLUDED.content,
    thumbnail_url = EXCLUDED.thumbnail_url,
    external_url = EXCLUDED.external_url,
    detail_url = EXCLUDED.detail_url,
    link_type = EXCLUDED.link_type,
    region = EXCLUDED.region,
    application_start_date = EXCLUDED.application_start_date,
    application_end_date = EXCLUDED.application_end_date,
    deadline_date = EXCLUDED.deadline_date,
    tags = EXCLUDED.tags,
    is_featured = EXCLUDED.is_featured,
    is_home_visible = EXCLUDED.is_home_visible,
    is_priority = EXCLUDED.is_priority,
    display_priority = EXCLUDED.display_priority,
    views_count = EXCLUDED.views_count,
    updated_at = NOW();

  -- Delete old details
  DELETE FROM public.announcement_details
  WHERE announcement_id = v_announcement_id;

  -- Insert new details if provided
  IF p_details IS NOT NULL AND array_length(p_details, 1) > 0 THEN
    INSERT INTO public.announcement_details (announcement_id, field_key, field_value, field_type)
    SELECT
      v_announcement_id,
      (d->>'field_key')::TEXT,
      (d->>'field_value')::TEXT,
      (d->>'field_type')::TEXT
    FROM unnest(p_details) AS d
    WHERE d IS NOT NULL
      AND d->>'field_key' IS NOT NULL
      AND d->>'field_value' IS NOT NULL
      AND d->>'field_type' IS NOT NULL;

    GET DIAGNOSTICS v_detail_count = ROW_COUNT;
  END IF;

  RETURN v_announcement_id;
EXCEPTION
  WHEN OTHERS THEN
    RAISE EXCEPTION 'Failed to save announcement: %', SQLERRM;
END;
$$;

-- ============================================
-- ✅ Migration Complete
-- ============================================

DO $$
BEGIN
  RAISE NOTICE '==============================================';
  RAISE NOTICE '✅ Announcement Details Migration Complete';
  RAISE NOTICE '==============================================';
  RAISE NOTICE '📦 Table: announcement_details';
  RAISE NOTICE '   - Columns: id, announcement_id, field_key, field_value, field_type, created_at';
  RAISE NOTICE '   - Foreign key: announcement_id -> announcements(id) ON DELETE CASCADE';
  RAISE NOTICE '   - Index: idx_announcement_details_announcement_id';
  RAISE NOTICE '';
  RAISE NOTICE '🔧 RPC Function: save_announcement_with_details';
  RAISE NOTICE '   - Parameters: p_announcement JSONB, p_details JSONB[]';
  RAISE NOTICE '   - Returns: UUID';
  RAISE NOTICE '   - Features: UPSERT main announcement + replace all details';
  RAISE NOTICE '==============================================';
END $$;
