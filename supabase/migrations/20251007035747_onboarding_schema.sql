-- 사용자 프로필 (통합)
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) UNIQUE,
  
  -- 001: 개인정보
  name TEXT,
  age INTEGER,
  gender TEXT,
  
  -- 002: 지역
  region_sido TEXT,
  region_sigungu TEXT,
  
  -- 003: 연령/세대
  selected_categories UUID[],
  
  -- 004: 소득
  income_level TEXT,
  
  -- 005: 관심 정책
  interest_policies UUID[],
  
  -- 메타
  onboarding_completed BOOLEAN DEFAULT false,
  onboarding_step INTEGER DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 연령/세대 카테고리 (003)
CREATE TABLE IF NOT EXISTS age_categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  icon_component TEXT NOT NULL,
  icon_url TEXT,
  min_age INTEGER,
  max_age INTEGER,
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 자동 업데이트 트리거
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER age_categories_updated
  BEFORE UPDATE ON age_categories
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER user_profiles_updated
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE age_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own profile"
  ON user_profiles FOR ALL
  USING (auth.uid() = user_id);

CREATE POLICY "Anyone views active categories"
  ON age_categories FOR SELECT
  USING (is_active = true);

-- Permissive policy for development (allows all operations)
CREATE POLICY "Admins manage categories"
  ON age_categories FOR ALL
  TO public
  USING (true)
  WITH CHECK (true);

-- 초기 데이터
INSERT INTO age_categories (title, description, icon_component, min_age, max_age, sort_order) VALUES
('청년', '(만 19세-39세) 대학생, 취업준비생, 직장인', 'young_man', 19, 39, 1),
('신혼부부·예비부부', '결혼 예정 또는 결혼 7년이내', 'bride', NULL, NULL, 2),
('육아중인 부모', '영유아~초등 자녀 양육 중', 'baby', NULL, NULL, 3),
('다자녀 가구', '자녀 2명 이상 양육중', 'kinder', NULL, NULL, 4),
('어르신', '만 65세 이상', 'old_man', 65, NULL, 5),
('장애인', '장애인 등록 대상', 'wheel_chair', NULL, NULL, 6)
ON CONFLICT DO NOTHING;
