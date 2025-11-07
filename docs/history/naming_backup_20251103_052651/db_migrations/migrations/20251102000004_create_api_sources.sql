-- Migration: Create API Sources Management
-- PRD v9.6 Section 4.3 & 5.5
-- Purpose: Manage external API sources for benefit data collection

-- Create api_sources table
CREATE TABLE IF NOT EXISTS public.api_sources (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  endpoint_url text NOT NULL,
  auth_type text DEFAULT 'none' CHECK (auth_type IN ('none', 'api_key', 'bearer', 'oauth')),
  auth_key text,
  mapping_config jsonb DEFAULT '{}'::jsonb,
  collection_schedule text,
  is_active boolean DEFAULT true,
  last_collected_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),

  CONSTRAINT api_sources_name_unique UNIQUE (name)
);

-- Create index on is_active for filtering
CREATE INDEX idx_api_sources_is_active ON public.api_sources(is_active);

-- Create index on last_collected_at for monitoring
CREATE INDEX idx_api_sources_last_collected ON public.api_sources(last_collected_at);

-- Enable RLS
ALTER TABLE public.api_sources ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Allow public read access
CREATE POLICY "Allow public read access on api_sources"
  ON public.api_sources
  FOR SELECT
  USING (true);

-- RLS Policy: Allow authenticated insert
CREATE POLICY "Allow authenticated insert on api_sources"
  ON public.api_sources
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- RLS Policy: Allow authenticated update
CREATE POLICY "Allow authenticated update on api_sources"
  ON public.api_sources
  FOR UPDATE
  USING (auth.role() = 'authenticated');

-- RLS Policy: Allow authenticated delete
CREATE POLICY "Allow authenticated delete on api_sources"
  ON public.api_sources
  FOR DELETE
  USING (auth.role() = 'authenticated');

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_api_sources_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_api_sources_updated_at
  BEFORE UPDATE ON public.api_sources
  FOR EACH ROW
  EXECUTE FUNCTION update_api_sources_updated_at();

-- Insert sample API source for testing
INSERT INTO public.api_sources (name, description, endpoint_url, auth_type, mapping_config, is_active)
VALUES (
  'Public Data Portal - Housing',
  '공공데이터포털 - 주거복지 API',
  'https://api.odcloud.kr/api/housing/v1',
  'api_key',
  '{
    "fields": {
      "title": "공고명",
      "application_start": "신청시작일",
      "application_end": "신청마감일",
      "location": "지역",
      "organizer": "기관명"
    },
    "target_category": "housing"
  }'::jsonb,
  true
);

-- Add comments for documentation
COMMENT ON TABLE public.api_sources IS 'External API sources for benefit data collection (PRD v9.6 Section 4.3)';
COMMENT ON COLUMN public.api_sources.name IS 'API source name (unique)';
COMMENT ON COLUMN public.api_sources.endpoint_url IS 'API endpoint URL';
COMMENT ON COLUMN public.api_sources.auth_type IS 'Authentication type: none, api_key, bearer, oauth';
COMMENT ON COLUMN public.api_sources.auth_key IS 'API authentication key (encrypted in production)';
COMMENT ON COLUMN public.api_sources.mapping_config IS 'JSONB field mapping configuration';
COMMENT ON COLUMN public.api_sources.collection_schedule IS 'Cron expression for automated collection';
COMMENT ON COLUMN public.api_sources.is_active IS 'Enable/disable API source';
COMMENT ON COLUMN public.api_sources.last_collected_at IS 'Timestamp of last successful collection';
