-- ================================================================
-- Migration: 20251110_create_mapping_config.sql
-- Description: Create mapping_config table for API mapping system
-- PRD: v9.8.0 — Pickly API Mapping System
-- Date: 2025-11-07
-- ================================================================

BEGIN;

-- 1️⃣ Create mapping_config table
CREATE TABLE IF NOT EXISTS public.mapping_config (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source_id uuid REFERENCES public.api_sources(id) ON DELETE CASCADE,
  mapping_rules jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- 2️⃣ Indexes
CREATE INDEX IF NOT EXISTS idx_mapping_config_source_id
  ON public.mapping_config(source_id);

-- 3️⃣ Trigger for updated_at
CREATE OR REPLACE FUNCTION public.update_mapping_config_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_mapping_config_timestamp
BEFORE UPDATE ON public.mapping_config
FOR EACH ROW EXECUTE FUNCTION public.update_mapping_config_updated_at();

COMMIT;

-- ================================================================
-- ✅ Validation
-- SELECT * FROM public.mapping_config LIMIT 5;
-- ================================================================
