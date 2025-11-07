-- =========================================================
-- Migration: 20251109000001_create_age_icons_bucket.sql
-- Purpose: Create age-icons storage bucket with public access
-- PRD: v9.9.4 - Age Icons Integration
-- =========================================================

-- 1️⃣ Create age-icons storage bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('age-icons', 'age-icons', true)
ON CONFLICT (id) DO NOTHING;

-- 2️⃣ Enable public read access
CREATE POLICY "Public can read age icons"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'age-icons');

-- 3️⃣ Allow authenticated users to upload (Admin uploads)
CREATE POLICY "Authenticated can insert age icons"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'age-icons'
    AND auth.role() = 'authenticated'
  );

-- 4️⃣ Allow authenticated users to update/delete
CREATE POLICY "Authenticated can update age icons"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'age-icons'
    AND auth.role() = 'authenticated'
  );

CREATE POLICY "Authenticated can delete age icons"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'age-icons'
    AND auth.role() = 'authenticated'
  );

-- 5️⃣ Add age_categories to realtime publication (if not already added)
DO $$
BEGIN
  -- Check if table is already in publication
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
    AND schemaname = 'public'
    AND tablename = 'age_categories'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.age_categories;
  END IF;
END $$;

-- 6️⃣ Normalize existing age_categories icon_url to filename-only format
UPDATE public.age_categories
SET icon_url = SUBSTRING(icon_url FROM '[^/]+$')
WHERE icon_url IS NOT NULL
  AND icon_url LIKE '%/%';

-- Verification
SELECT 'age-icons bucket created successfully' AS status;
