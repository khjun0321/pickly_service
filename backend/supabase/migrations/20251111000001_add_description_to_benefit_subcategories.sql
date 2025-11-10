-- ============================================
-- Add description column to benefit_subcategories
-- PRD v9.10.2: Enhanced Subcategory Filter UI
-- Created: 2025-11-11
-- ============================================

-- Add description column to benefit_subcategories table
-- This allows admins to provide additional context for each subcategory
-- Example: "행복주택 - 젊은 층을 위한 저렴한 임대 주택"
ALTER TABLE public.benefit_subcategories
  ADD COLUMN IF NOT EXISTS description TEXT;

-- Add comment for documentation
COMMENT ON COLUMN public.benefit_subcategories.description IS
  '서브카테고리 설명 - 어드민이 입력한 추가 정보 (예: "젊은 층을 위한 저렴한 임대 주택")';
