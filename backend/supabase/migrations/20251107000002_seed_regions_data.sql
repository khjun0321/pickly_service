-- Migration: Seed regions table with 18 Korean regions
-- Version: PRD v9.8.2 (Phase 6.3)
-- Date: 2025-11-07
-- Purpose: Populate regions table with standard Korean administrative divisions
-- Source: RegionRepository.getMockRegions() from Flutter app

-- Insert 18 Korean regions in display order
INSERT INTO public.regions (code, name, sort_order, is_active) VALUES
  ('NATIONWIDE', '전국', 0, true),
  ('SEOUL', '서울', 1, true),
  ('GYEONGGI', '경기', 2, true),
  ('INCHEON', '인천', 3, true),
  ('GANGWON', '강원', 4, true),
  ('CHUNGNAM', '충남', 5, true),
  ('CHUNGBUK', '충북', 6, true),
  ('DAEJEON', '대전', 7, true),
  ('SEJONG', '세종', 8, true),
  ('GYEONGNAM', '경남', 9, true),
  ('GYEONGBUK', '경북', 10, true),
  ('DAEGU', '대구', 11, true),
  ('JEONNAM', '전남', 12, true),
  ('JEONBUK', '전북', 13, true),
  ('GWANGJU', '광주', 14, true),
  ('ULSAN', '울산', 15, true),
  ('BUSAN', '부산', 16, true),
  ('JEJU', '제주', 17, true)
ON CONFLICT (code) DO NOTHING;

-- Verify insertion
DO $$
DECLARE
  region_count integer;
BEGIN
  SELECT COUNT(*) INTO region_count FROM public.regions;
  RAISE NOTICE 'Successfully inserted % regions', region_count;
END $$;
