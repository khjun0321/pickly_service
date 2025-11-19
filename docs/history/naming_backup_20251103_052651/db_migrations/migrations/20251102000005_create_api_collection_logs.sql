-- Migration: Create API Collection Logs
-- PRD v9.6 Section 4.3.2 & 5.5
-- Purpose: Track API collection execution history and results

-- Create api_collection_logs table
CREATE TABLE IF NOT EXISTS public.api_collection_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  api_source_id uuid NOT NULL REFERENCES public.api_sources(id) ON DELETE CASCADE,
  status text NOT NULL CHECK (status IN ('running', 'success', 'partial', 'failed')),
  records_fetched integer DEFAULT 0,
  records_processed integer DEFAULT 0,
  records_failed integer DEFAULT 0,
  error_message text,
  error_summary jsonb,
  started_at timestamptz NOT NULL DEFAULT now(),
  completed_at timestamptz,
  created_at timestamptz DEFAULT now()
);

-- Create indexes for efficient querying
CREATE INDEX idx_api_collection_logs_api_source ON public.api_collection_logs(api_source_id);
CREATE INDEX idx_api_collection_logs_status ON public.api_collection_logs(status);
CREATE INDEX idx_api_collection_logs_started_at ON public.api_collection_logs(started_at DESC);

-- Enable RLS
ALTER TABLE public.api_collection_logs ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Allow public read access
CREATE POLICY "Allow public read access on api_collection_logs"
  ON public.api_collection_logs
  FOR SELECT
  USING (true);

-- RLS Policy: Allow authenticated insert
CREATE POLICY "Allow authenticated insert on api_collection_logs"
  ON public.api_collection_logs
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- RLS Policy: Allow authenticated update
CREATE POLICY "Allow authenticated update on api_collection_logs"
  ON public.api_collection_logs
  FOR UPDATE
  USING (auth.role() = 'authenticated');

-- RLS Policy: Allow authenticated delete
CREATE POLICY "Allow authenticated delete on api_collection_logs"
  ON public.api_collection_logs
  FOR DELETE
  USING (auth.role() = 'authenticated');

-- Insert sample collection logs for testing
INSERT INTO public.api_collection_logs (
  api_source_id,
  status,
  records_fetched,
  records_processed,
  records_failed,
  error_message,
  error_summary,
  started_at,
  completed_at
)
SELECT
  id,
  'success',
  150,
  145,
  5,
  NULL,
  '{"duplicate_records": 3, "invalid_dates": 2}'::jsonb,
  now() - interval '2 hours',
  now() - interval '2 hours' + interval '45 seconds'
FROM api_sources
WHERE name = 'Public Data Portal - Housing'
LIMIT 1;

INSERT INTO public.api_collection_logs (
  api_source_id,
  status,
  records_fetched,
  records_processed,
  records_failed,
  error_message,
  error_summary,
  started_at,
  completed_at
)
SELECT
  id,
  'failed',
  0,
  0,
  0,
  'Connection timeout: Unable to reach API endpoint',
  '{"error_code": "ETIMEDOUT", "retry_count": 3}'::jsonb,
  now() - interval '1 day',
  now() - interval '1 day' + interval '30 seconds'
FROM api_sources
WHERE name = 'Public Data Portal - Housing'
LIMIT 1;

INSERT INTO public.api_collection_logs (
  api_source_id,
  status,
  records_fetched,
  records_processed,
  records_failed,
  error_message,
  error_summary,
  started_at,
  completed_at
)
SELECT
  id,
  'running',
  75,
  70,
  0,
  NULL,
  NULL,
  now() - interval '5 minutes',
  NULL
FROM api_sources
WHERE name = 'Public Data Portal - Housing'
LIMIT 1;

-- Add comments for documentation
COMMENT ON TABLE public.api_collection_logs IS 'API collection execution logs (PRD v9.6 Section 4.3.2)';
COMMENT ON COLUMN public.api_collection_logs.api_source_id IS 'Foreign key to api_sources';
COMMENT ON COLUMN public.api_collection_logs.status IS 'Execution status: running, success, partial, failed';
COMMENT ON COLUMN public.api_collection_logs.records_fetched IS 'Number of records fetched from API';
COMMENT ON COLUMN public.api_collection_logs.records_processed IS 'Number of records successfully processed';
COMMENT ON COLUMN public.api_collection_logs.records_failed IS 'Number of records that failed processing';
COMMENT ON COLUMN public.api_collection_logs.error_message IS 'Error message if failed';
COMMENT ON COLUMN public.api_collection_logs.error_summary IS 'JSONB summary of errors';
COMMENT ON COLUMN public.api_collection_logs.started_at IS 'Collection start timestamp';
COMMENT ON COLUMN public.api_collection_logs.completed_at IS 'Collection completion timestamp (NULL if running)';
