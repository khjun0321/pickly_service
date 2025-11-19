-- Phase 1.3: Create trigger to enforce filename-only icon_url
-- PRD v9.9.2: CircleTab Dynamic Binding Implementation

-- Trigger function to normalize icon_url before insert/update
CREATE OR REPLACE FUNCTION enforce_icon_url_filename_only()
RETURNS TRIGGER AS $$
BEGIN
  -- If icon_url is NULL, allow it
  IF NEW.icon_url IS NULL THEN
    RETURN NEW;
  END IF;

  -- Extract filename from any path format
  NEW.icon_url := extract_filename(NEW.icon_url);

  -- Validate: No slashes, no http/https
  IF NEW.icon_url ~ '/' OR NEW.icon_url ~ '^http' THEN
    RAISE EXCEPTION 'icon_url must be filename only (no paths): %', NEW.icon_url;
  END IF;

  -- Validate: Must end with .svg (for now)
  IF NEW.icon_url !~ '\.svg$' THEN
    RAISE EXCEPTION 'icon_url must be SVG file: %', NEW.icon_url;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger to benefit_categories
DROP TRIGGER IF EXISTS trg_enforce_icon_url_filename ON public.benefit_categories;

CREATE TRIGGER trg_enforce_icon_url_filename
  BEFORE INSERT OR UPDATE OF icon_url
  ON public.benefit_categories
  FOR EACH ROW
  EXECUTE FUNCTION enforce_icon_url_filename_only();

-- Test trigger
DO $$
DECLARE
  test_id UUID;
  test_passed BOOLEAN := true;
BEGIN
  -- Get a test category ID
  SELECT id INTO test_id FROM public.benefit_categories LIMIT 1;

  IF test_id IS NULL THEN
    RAISE NOTICE '⚠️ No categories found for trigger testing';
    RETURN;
  END IF;

  -- Test 1: Filename should succeed
  BEGIN
    UPDATE public.benefit_categories
    SET icon_url = 'popular.svg'
    WHERE id = test_id;

    RAISE NOTICE '✅ Trigger test 1 passed: filename accepted';
  EXCEPTION WHEN OTHERS THEN
    RAISE EXCEPTION 'Trigger test 1 failed: valid filename rejected - %', SQLERRM;
  END;

  -- Test 2: Path should fail
  BEGIN
    UPDATE public.benefit_categories
    SET icon_url = '/icons/test.svg'
    WHERE id = test_id;

    RAISE EXCEPTION 'Trigger test 2 failed: path was accepted';
  EXCEPTION WHEN OTHERS THEN
    IF SQLERRM ~ 'icon_url must be filename only' THEN
      RAISE NOTICE '✅ Trigger test 2 passed: path rejected correctly';
    ELSE
      RAISE EXCEPTION 'Trigger test 2 failed with unexpected error: %', SQLERRM;
    END IF;
  END;

  -- Test 3: URL should fail
  BEGIN
    UPDATE public.benefit_categories
    SET icon_url = 'https://example.com/test.svg'
    WHERE id = test_id;

    RAISE EXCEPTION 'Trigger test 3 failed: URL was accepted';
  EXCEPTION WHEN OTHERS THEN
    IF SQLERRM ~ 'icon_url must be filename only' THEN
      RAISE NOTICE '✅ Trigger test 3 passed: URL rejected correctly';
    ELSE
      RAISE EXCEPTION 'Trigger test 3 failed with unexpected error: %', SQLERRM;
    END IF;
  END;

  RAISE NOTICE '✅ All trigger tests passed successfully';
END $$;
