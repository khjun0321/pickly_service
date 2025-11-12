-- Phase 1.1: Normalize icon_url to filename only (remove paths)
-- PRD v9.9.2: CircleTab Dynamic Binding Implementation

-- Function to extract filename from path
CREATE OR REPLACE FUNCTION extract_filename(path TEXT)
RETURNS TEXT AS $$
BEGIN
  -- Handle NULL
  IF path IS NULL THEN
    RETURN NULL;
  END IF;

  -- Remove leading slash
  path := LTRIM(path, '/');

  -- Extract filename after last slash
  IF path ~ '/' THEN
    RETURN SUBSTRING(path FROM '([^/]+)$');
  ELSE
    RETURN path;
  END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Update all icon_url to filename only
UPDATE public.benefit_categories
SET icon_url = extract_filename(icon_url)
WHERE icon_url IS NOT NULL
  AND icon_url != extract_filename(icon_url);

-- Verification query
DO $$
DECLARE
  invalid_count INTEGER;
  updated_count INTEGER;
BEGIN
  -- Count invalid entries
  SELECT COUNT(*) INTO invalid_count
  FROM public.benefit_categories
  WHERE icon_url IS NOT NULL
    AND (icon_url ~ '/' OR icon_url ~ '^http');

  IF invalid_count > 0 THEN
    RAISE EXCEPTION 'Found % rows with invalid icon_url (contains path)', invalid_count;
  END IF;

  -- Count total normalized entries
  SELECT COUNT(*) INTO updated_count
  FROM public.benefit_categories
  WHERE icon_url IS NOT NULL;

  RAISE NOTICE '✅ All icon_url values normalized to filename only';
  RAISE NOTICE '   Total entries processed: %', updated_count;
END $$;
