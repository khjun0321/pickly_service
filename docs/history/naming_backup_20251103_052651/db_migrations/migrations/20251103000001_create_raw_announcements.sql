-- =====================================================
-- Migration: Create raw_announcements Table
-- Version: 20251103000001
-- PRD: v9.6.1 Section 4.3.3 & 5.5
-- Phase: 4C Step 1 - Raw API Data Storage
-- Description: Stores raw API responses before processing
-- =====================================================

-- Drop existing objects if they exist (for clean re-run)
DROP TABLE IF EXISTS public.raw_announcements CASCADE;

-- =====================================================
-- Table: raw_announcements
-- Purpose: Store raw API responses before transformation
-- =====================================================

CREATE TABLE public.raw_announcements (
  -- Primary Key
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Foreign Keys
  api_source_id uuid NOT NULL REFERENCES public.api_sources(id) ON DELETE CASCADE,
  collection_log_id uuid REFERENCES public.api_collection_logs(id) ON DELETE SET NULL,

  -- Raw Data Storage
  raw_payload jsonb NOT NULL,

  -- Processing Status
  status text NOT NULL DEFAULT 'fetched'
    CHECK (status IN ('fetched', 'processed', 'error')),

  -- Error Tracking
  error_log text,

  -- Timestamps
  collected_at timestamptz NOT NULL DEFAULT now(),
  processed_at timestamptz,

  -- Active Flag
  is_active boolean NOT NULL DEFAULT true,

  -- Audit Timestamps
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- =====================================================
-- Indexes for Performance
-- =====================================================

-- Fast lookup by API source and collection time
CREATE INDEX idx_raw_announcements_api_source_collected
  ON public.raw_announcements(api_source_id, collected_at DESC);

-- Fast filtering by status
CREATE INDEX idx_raw_announcements_status
  ON public.raw_announcements(status)
  WHERE is_active = true;

-- Fast lookup by collection log
CREATE INDEX idx_raw_announcements_collection_log
  ON public.raw_announcements(collection_log_id)
  WHERE collection_log_id IS NOT NULL;

-- Fast lookup of unprocessed records
CREATE INDEX idx_raw_announcements_unprocessed
  ON public.raw_announcements(collected_at DESC)
  WHERE status = 'fetched' AND is_active = true;

-- GIN index for JSONB payload searches (optional but recommended)
CREATE INDEX idx_raw_announcements_payload_gin
  ON public.raw_announcements USING gin(raw_payload);

-- =====================================================
-- Triggers
-- =====================================================

-- Auto-update updated_at timestamp
CREATE TRIGGER set_raw_announcements_updated_at
  BEFORE UPDATE ON public.raw_announcements
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

-- =====================================================
-- Row Level Security (RLS)
-- =====================================================

-- Enable RLS
ALTER TABLE public.raw_announcements ENABLE ROW LEVEL SECURITY;

-- Policy 1: Public read access
CREATE POLICY "Allow public read access on raw_announcements"
  ON public.raw_announcements
  FOR SELECT
  USING (true);

-- Policy 2: Authenticated insert
CREATE POLICY "Allow authenticated insert on raw_announcements"
  ON public.raw_announcements
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- Policy 3: Authenticated update
CREATE POLICY "Allow authenticated update on raw_announcements"
  ON public.raw_announcements
  FOR UPDATE
  USING (auth.role() = 'authenticated');

-- Policy 4: Authenticated delete
CREATE POLICY "Allow authenticated delete on raw_announcements"
  ON public.raw_announcements
  FOR DELETE
  USING (auth.role() = 'authenticated');

-- =====================================================
-- Comments for Documentation
-- =====================================================

COMMENT ON TABLE public.raw_announcements IS
  'PRD v9.6.1 Phase 4C: Stores raw API responses before transformation into announcements';

COMMENT ON COLUMN public.raw_announcements.id IS
  'Primary key (UUID)';

COMMENT ON COLUMN public.raw_announcements.api_source_id IS
  'Foreign key to api_sources - which API this data came from';

COMMENT ON COLUMN public.raw_announcements.collection_log_id IS
  'Foreign key to api_collection_logs - execution log for this collection (nullable)';

COMMENT ON COLUMN public.raw_announcements.raw_payload IS
  'Raw JSON response from API endpoint (JSONB for efficient querying)';

COMMENT ON COLUMN public.raw_announcements.status IS
  'Processing status: fetched (new), processed (transformed), error (failed)';

COMMENT ON COLUMN public.raw_announcements.error_log IS
  'Error message if processing failed';

COMMENT ON COLUMN public.raw_announcements.collected_at IS
  'Timestamp when data was fetched from API';

COMMENT ON COLUMN public.raw_announcements.processed_at IS
  'Timestamp when data was successfully transformed (NULL if not yet processed)';

COMMENT ON COLUMN public.raw_announcements.is_active IS
  'Soft delete flag - false means data should be ignored';

-- =====================================================
-- Sample Data (for testing)
-- =====================================================

-- Insert sample raw announcement from housing API
INSERT INTO public.raw_announcements (
  api_source_id,
  collection_log_id,
  raw_payload,
  status,
  collected_at,
  is_active
)
SELECT
  (SELECT id FROM public.api_sources LIMIT 1), -- Use first API source
  NULL, -- No collection log for sample data
  '{
    "공고명": "2025년 행복주택 1차 입주자 모집",
    "신청시작일": "2025-11-10",
    "신청마감일": "2025-11-20",
    "지역": "서울특별시 강남구",
    "기관명": "서울주택도시공사",
    "연락처": "02-1234-5678",
    "모집세대수": 150,
    "전용면적": [
      {"평형": "30㎡", "세대수": 50, "보증금": 5000000, "월세": 150000},
      {"평형": "40㎡", "세대수": 100, "보증금": 7000000, "월세": 200000}
    ],
    "자격요건": "만 19세 이상 무주택자",
    "특이사항": "청년층 우선 공급"
  }'::jsonb,
  'fetched',
  now() - interval '2 hours',
  true
WHERE EXISTS (SELECT 1 FROM public.api_sources LIMIT 1);

-- Insert sample processed announcement
INSERT INTO public.raw_announcements (
  api_source_id,
  collection_log_id,
  raw_payload,
  status,
  error_log,
  collected_at,
  processed_at,
  is_active
)
SELECT
  (SELECT id FROM public.api_sources LIMIT 1),
  NULL,
  '{
    "공고명": "청년 취업 지원 프로그램",
    "신청시작일": "2025-11-01",
    "신청마감일": "2025-11-15",
    "지역": "전국",
    "기관명": "고용노동부",
    "연락처": "1350",
    "지원내용": "취업 교육 및 훈련비 지원"
  }'::jsonb,
  'processed',
  NULL,
  now() - interval '1 day',
  now() - interval '12 hours',
  true
WHERE EXISTS (SELECT 1 FROM public.api_sources LIMIT 1);

-- Insert sample error record
INSERT INTO public.raw_announcements (
  api_source_id,
  collection_log_id,
  raw_payload,
  status,
  error_log,
  collected_at,
  is_active
)
SELECT
  (SELECT id FROM public.api_sources LIMIT 1),
  NULL,
  '{
    "공고명": "Invalid Data Example",
    "신청시작일": "invalid-date",
    "신청마감일": null
  }'::jsonb,
  'error',
  'Date parsing failed: invalid-date is not a valid ISO 8601 date format',
  now() - interval '30 minutes',
  true
WHERE EXISTS (SELECT 1 FROM public.api_sources LIMIT 1);

-- =====================================================
-- Verification Queries
-- =====================================================

-- Verify table creation
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
    AND table_name = 'raw_announcements'
  ) THEN
    RAISE NOTICE '✅ Table raw_announcements created successfully';
  ELSE
    RAISE EXCEPTION '❌ Table raw_announcements was not created';
  END IF;
END $$;

-- Verify indexes
DO $$
DECLARE
  index_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO index_count
  FROM pg_indexes
  WHERE tablename = 'raw_announcements';

  IF index_count >= 5 THEN
    RAISE NOTICE '✅ All indexes created successfully (count: %)', index_count;
  ELSE
    RAISE WARNING '⚠️  Expected at least 5 indexes, found: %', index_count;
  END IF;
END $$;

-- Verify RLS policies
DO $$
DECLARE
  policy_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO policy_count
  FROM pg_policies
  WHERE tablename = 'raw_announcements';

  IF policy_count = 4 THEN
    RAISE NOTICE '✅ All 4 RLS policies created successfully';
  ELSE
    RAISE WARNING '⚠️  Expected 4 RLS policies, found: %', policy_count;
  END IF;
END $$;

-- Verify sample data
DO $$
DECLARE
  sample_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO sample_count
  FROM public.raw_announcements;

  IF sample_count >= 3 THEN
    RAISE NOTICE '✅ Sample data inserted successfully (count: %)', sample_count;
  ELSE
    RAISE WARNING '⚠️  Expected at least 3 sample records, found: %', sample_count;
  END IF;
END $$;

-- Display summary
SELECT
  COUNT(*) as total_records,
  COUNT(*) FILTER (WHERE status = 'fetched') as fetched,
  COUNT(*) FILTER (WHERE status = 'processed') as processed,
  COUNT(*) FILTER (WHERE status = 'error') as errors,
  COUNT(*) FILTER (WHERE is_active = true) as active
FROM public.raw_announcements;

-- =====================================================
-- Migration Complete
-- =====================================================
-- Phase 4C Step 1: raw_announcements table created
-- Next Step: Phase 4C Step 2 - API Collection Service
-- =====================================================
