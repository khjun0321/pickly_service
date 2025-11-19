-- Phase 1.2: Rename fire.svg to popular.svg
-- PRD v9.9.2: CircleTab Dynamic Binding Implementation

-- Update all fire.svg references to popular.svg
UPDATE public.benefit_categories
SET icon_url = 'popular.svg'
WHERE icon_url IN ('fire.svg', 'flame.svg', 'hot.svg');

-- Verification
DO $$
DECLARE
  fire_count INTEGER;
  popular_count INTEGER;
BEGIN
  -- Check for remaining fire variants
  SELECT COUNT(*) INTO fire_count
  FROM public.benefit_categories
  WHERE icon_url IN ('fire.svg', 'flame.svg', 'hot.svg');

  -- Count popular.svg entries
  SELECT COUNT(*) INTO popular_count
  FROM public.benefit_categories
  WHERE icon_url = 'popular.svg';

  IF fire_count > 0 THEN
    RAISE EXCEPTION 'Still found % rows with fire.svg variants', fire_count;
  END IF;

  RAISE NOTICE '✅ fire.svg → popular.svg migration complete';
  RAISE NOTICE '   Total popular.svg entries: %', popular_count;
END $$;
