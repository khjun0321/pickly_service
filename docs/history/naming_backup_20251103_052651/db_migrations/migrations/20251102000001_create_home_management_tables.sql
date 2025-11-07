-- Migration: Create Home Management Tables
-- PRD v9.6 Section 4.1 - Home Management
-- Date: 2025-11-02

-- =====================================================
-- 1. home_sections table
-- =====================================================
CREATE TABLE IF NOT EXISTS home_sections (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  section_type text NOT NULL,  -- 'community' | 'featured' | 'announcements'
  description text,
  sort_order integer NOT NULL DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),

  CONSTRAINT home_sections_section_type_check
    CHECK (section_type IN ('community', 'featured', 'announcements'))
);

-- =====================================================
-- 2. featured_contents table
-- =====================================================
CREATE TABLE IF NOT EXISTS featured_contents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  section_id uuid NOT NULL,
  title text NOT NULL,
  subtitle text,
  image_url text NOT NULL,
  link_url text,
  link_type text DEFAULT 'internal',  -- 'internal' | 'external' | 'none'
  sort_order integer NOT NULL DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),

  CONSTRAINT featured_contents_section_id_fkey
    FOREIGN KEY (section_id) REFERENCES home_sections(id) ON DELETE CASCADE,

  CONSTRAINT featured_contents_link_type_check
    CHECK (link_type IN ('internal', 'external', 'none'))
);

-- =====================================================
-- 3. Indexes
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_home_sections_active
  ON home_sections(is_active) WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_home_sections_sort
  ON home_sections(sort_order ASC);

CREATE INDEX IF NOT EXISTS idx_featured_contents_section
  ON featured_contents(section_id);

CREATE INDEX IF NOT EXISTS idx_featured_contents_active
  ON featured_contents(is_active) WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_featured_contents_sort
  ON featured_contents(section_id, sort_order ASC);

-- =====================================================
-- 4. RLS Policies
-- =====================================================
ALTER TABLE home_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE featured_contents ENABLE ROW LEVEL SECURITY;

-- Public read access for active sections
CREATE POLICY "Public read access for active sections"
  ON home_sections FOR SELECT
  USING (is_active = true);

-- Public read access for active featured contents
CREATE POLICY "Public read access for active featured contents"
  ON featured_contents FOR SELECT
  USING (is_active = true);

-- Authenticated users (admins) can manage sections
CREATE POLICY "Authenticated users can manage home sections"
  ON home_sections FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Authenticated users (admins) can manage featured contents
CREATE POLICY "Authenticated users can manage featured contents"
  ON featured_contents FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- =====================================================
-- 5. Triggers
-- =====================================================
-- Update updated_at timestamp on home_sections
CREATE OR REPLACE FUNCTION update_home_sections_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_home_sections_updated_at
  BEFORE UPDATE ON home_sections
  FOR EACH ROW
  EXECUTE FUNCTION update_home_sections_updated_at();

-- Update updated_at timestamp on featured_contents
CREATE OR REPLACE FUNCTION update_featured_contents_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_featured_contents_updated_at
  BEFORE UPDATE ON featured_contents
  FOR EACH ROW
  EXECUTE FUNCTION update_featured_contents_updated_at();

-- =====================================================
-- 6. Seed Data
-- =====================================================
-- Insert default home sections
INSERT INTO home_sections (title, section_type, description, sort_order, is_active)
VALUES
  ('인기 커뮤니티', 'community', '자동으로 인기 커뮤니티 글을 표시합니다', 1, true),
  ('추천 콘텐츠', 'featured', '운영진이 직접 선정한 추천 콘텐츠', 2, true),
  ('인기 공고', 'announcements', 'is_priority가 true인 인기 공고 자동 노출', 3, true)
ON CONFLICT DO NOTHING;

-- Insert sample featured content (for testing)
INSERT INTO featured_contents (
  section_id,
  title,
  subtitle,
  image_url,
  link_url,
  link_type,
  sort_order,
  is_active
)
SELECT
  id,
  '환영합니다! Pickly와 함께 혜택을 찾아보세요',
  '청년 주거, 취업, 교육 혜택을 한눈에',
  'https://placehold.co/600x400/e3f2fd/1976d2?text=Welcome+to+Pickly',
  '/benefits/manage/housing',
  'internal',
  1,
  true
FROM home_sections
WHERE section_type = 'featured'
LIMIT 1
ON CONFLICT DO NOTHING;

-- =====================================================
-- 7. Comments
-- =====================================================
COMMENT ON TABLE home_sections IS 'Home screen section management - PRD v9.6 Section 4.1';
COMMENT ON TABLE featured_contents IS 'Featured content items for home screen sections';

COMMENT ON COLUMN home_sections.section_type IS 'Type of section: community (auto), featured (manual), announcements (auto)';
COMMENT ON COLUMN home_sections.sort_order IS 'Display order on home screen (lower = higher priority)';
COMMENT ON COLUMN featured_contents.link_type IS 'Link destination type: internal (app route), external (URL), none';
COMMENT ON COLUMN featured_contents.sort_order IS 'Display order within section';
