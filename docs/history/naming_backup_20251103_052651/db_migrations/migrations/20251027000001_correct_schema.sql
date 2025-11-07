-- ============================================
-- Pickly Service - 올바른 DB 스키마
-- PRD 기반 Phase 1 MVP
-- 생성일: 2025-10-27
-- ============================================

-- ============================================
-- 1. 혜택 카테고리 시스템
-- ============================================

-- 1-1. 혜택 카테고리 (주거, 교육, 건강...)
CREATE TABLE benefit_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name varchar(100) NOT NULL,
  slug varchar(100) UNIQUE NOT NULL,
  description text,
  icon_url text,
  display_order integer NOT NULL DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- 1-2. 서브 카테고리 (행복주택, 국민임대...)
CREATE TABLE benefit_subcategories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id uuid REFERENCES benefit_categories(id) ON DELETE CASCADE,
  name varchar(100) NOT NULL,
  slug varchar(100) NOT NULL,
  display_order integer NOT NULL DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  UNIQUE(category_id, slug)
);

-- ============================================
-- 2. 공고 시스템
-- ============================================

-- 2-1. 공고 기본 정보
CREATE TABLE announcements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  -- 기본 정보
  title text NOT NULL,
  subtitle text,
  organization text NOT NULL,

  -- 카테고리
  category_id uuid REFERENCES benefit_categories(id),
  subcategory_id uuid REFERENCES benefit_subcategories(id),

  -- 썸네일 (직접 업로드 or NULL = 기본 이미지)
  thumbnail_url text,

  -- 외부 링크
  external_url text,

  -- 상태
  status text NOT NULL DEFAULT 'recruiting' CHECK (status IN ('recruiting', 'closed', 'draft')),

  -- 노출 설정
  is_featured boolean DEFAULT false,       -- 인기 탭
  is_home_visible boolean DEFAULT false,   -- 홈 화면
  display_priority integer DEFAULT 0,

  -- 메타 데이터
  views_count integer DEFAULT 0,
  tags text[],
  search_vector tsvector,

  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- 2-2. 공고 섹션 (모듈식 구성)
CREATE TABLE announcement_sections (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  announcement_id uuid REFERENCES announcements(id) ON DELETE CASCADE,

  -- 섹션 타입
  section_type text NOT NULL CHECK (section_type IN (
    'basic_info',      -- 기본 정보
    'schedule',        -- 일정
    'eligibility',     -- 신청 자격
    'housing_info',    -- 단지 정보
    'location',        -- 위치
    'attachments'      -- 첨부 파일
  )),

  -- 제목
  title text,

  -- 내용 (JSON으로 유연하게)
  content jsonb NOT NULL,

  -- 순서
  display_order integer NOT NULL DEFAULT 0,
  is_visible boolean DEFAULT true,

  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- 2-3. 공고 탭 (평형/연령별 정보)
CREATE TABLE announcement_tabs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  announcement_id uuid REFERENCES announcements(id) ON DELETE CASCADE,

  -- 탭 정보
  tab_name text NOT NULL,                  -- "16A 청년", "신혼부부"
  age_category_id uuid REFERENCES age_categories(id),

  -- 평형 정보
  unit_type text,                           -- "16㎡", "26㎡"
  floor_plan_image_url text,                -- 평면도 (직접 업로드!)
  supply_count integer,                     -- 공급 호수

  -- 소득 조건 (JSON)
  income_conditions jsonb,
  -- 예: {"대학생": "3,284만원", "청년(소득)": "3,477만원"}

  -- 기타 정보
  additional_info jsonb,

  -- 순서
  display_order integer NOT NULL DEFAULT 0,

  created_at timestamp with time zone DEFAULT now()
);

-- ============================================
-- 3. 배너 시스템
-- ============================================

CREATE TABLE category_banners (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id uuid REFERENCES benefit_categories(id) ON DELETE CASCADE,

  -- 배너 정보
  title text NOT NULL,
  subtitle text,
  image_url text NOT NULL,
  link_url text,

  -- 노출 설정
  display_order integer NOT NULL DEFAULT 0,
  is_active boolean DEFAULT true,

  -- 기간 설정 (선택)
  start_date timestamp with time zone,
  end_date timestamp with time zone,

  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- ============================================
-- 4. 사용자 시스템 (기존 유지)
-- ============================================
-- age_categories, user_profiles는 이미 존재

-- ============================================
-- 5. 인덱스
-- ============================================

-- 공고 검색/필터
CREATE INDEX idx_announcements_category ON announcements(category_id);
CREATE INDEX idx_announcements_subcategory ON announcements(subcategory_id);
CREATE INDEX idx_announcements_status ON announcements(status);
CREATE INDEX idx_announcements_featured ON announcements(is_featured) WHERE is_featured = true;
CREATE INDEX idx_announcements_home ON announcements(is_home_visible) WHERE is_home_visible = true;
CREATE INDEX idx_announcements_priority ON announcements(display_priority DESC);
CREATE INDEX idx_announcements_search ON announcements USING gin(search_vector);

-- 섹션 정렬
CREATE INDEX idx_announcement_sections_order ON announcement_sections(announcement_id, display_order);

-- 탭 정렬
CREATE INDEX idx_announcement_tabs_order ON announcement_tabs(announcement_id, display_order);

-- 배너
CREATE INDEX idx_category_banners_category ON category_banners(category_id);
CREATE INDEX idx_category_banners_active ON category_banners(is_active) WHERE is_active = true;

-- ============================================
-- 6. RLS (Row Level Security)
-- ============================================

ALTER TABLE benefit_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE benefit_subcategories ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcement_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcement_tabs ENABLE ROW LEVEL SECURITY;
ALTER TABLE category_banners ENABLE ROW LEVEL SECURITY;

-- 모든 사용자 읽기 가능
CREATE POLICY "Public read access" ON benefit_categories FOR SELECT USING (true);
CREATE POLICY "Public read access" ON benefit_subcategories FOR SELECT USING (true);
CREATE POLICY "Public read access" ON announcements FOR SELECT USING (status != 'draft');
CREATE POLICY "Public read access" ON announcement_sections FOR SELECT USING (true);
CREATE POLICY "Public read access" ON announcement_tabs FOR SELECT USING (true);
CREATE POLICY "Public read access" ON category_banners FOR SELECT USING (is_active);

-- 관리자만 쓰기 (추후 구현)
-- CREATE POLICY "Admin write access" ON ... FOR ALL USING (auth.role() = 'admin');

-- ============================================
-- 7. 트리거 (updated_at 자동 갱신)
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_benefit_categories_updated_at BEFORE UPDATE ON benefit_categories
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_announcements_updated_at BEFORE UPDATE ON announcements
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_announcement_sections_updated_at BEFORE UPDATE ON announcement_sections
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_category_banners_updated_at BEFORE UPDATE ON category_banners
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 8. 초기 데이터 (샘플)
-- ============================================

-- 혜택 카테고리
INSERT INTO benefit_categories (name, slug, display_order, icon_url) VALUES
  ('인기', 'popular', 1, '/icons/popular.svg'),
  ('주거', 'housing', 2, '/icons/housing.svg'),
  ('교육', 'education', 3, '/icons/education.svg'),
  ('건강', 'health', 4, '/icons/health.svg'),
  ('교통', 'transportation', 5, '/icons/transportation.svg'),
  ('복지', 'welfare', 6, '/icons/welfare.svg'),
  ('취업', 'employment', 7, '/icons/employment.svg'),
  ('지원', 'support', 8, '/icons/support.svg'),
  ('문화', 'culture', 9, '/icons/culture.svg');

-- 주거 서브 카테고리
INSERT INTO benefit_subcategories (category_id, name, slug, display_order)
SELECT id, '전체공고', 'all', 1 FROM benefit_categories WHERE slug = 'housing'
UNION ALL
SELECT id, '행복주택', 'happy-housing', 2 FROM benefit_categories WHERE slug = 'housing'
UNION ALL
SELECT id, '국민임대주택', 'public-rental', 3 FROM benefit_categories WHERE slug = 'housing'
UNION ALL
SELECT id, '영구임대주택', 'permanent-rental', 4 FROM benefit_categories WHERE slug = 'housing';

-- ============================================
-- 완료!
-- ============================================

COMMENT ON SCHEMA public IS 'Pickly Service Schema - v1.0 (PRD Based)';
