-- ============================================
-- Pickly Service - Announcement Types & Custom Content
-- PRD Phase 1 - 공고 유형별 정보 + 커스텀 섹션
-- 생성일: 2025-10-27
-- 작성자: Database Architect Agent
-- ============================================

-- ============================================
-- 1. 공고 유형별 정보 테이블
-- ============================================
-- 목적: 각 공고의 평형별(유형별) 보증금/월세 정보 관리
-- 예: "16A 청년" → 보증금 2,000만원, 월세 150,000원

CREATE TABLE announcement_types (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  announcement_id uuid REFERENCES announcements(id) ON DELETE CASCADE NOT NULL,

  -- 유형 정보
  type_name text NOT NULL,                    -- "16A 청년", "26B 신혼부부" 등

  -- 비용 정보 (필수)
  deposit bigint,                              -- 보증금 (원 단위)
  monthly_rent integer,                        -- 월세 (원 단위)

  -- 자격 조건 (선택)
  eligible_condition text,                     -- 자격 조건 텍스트

  -- 순서 및 메타
  order_index integer NOT NULL DEFAULT 0,

  -- 첨부 파일 (선택)
  icon_url text,                               -- 아이콘 URL (있으면 표시)
  pdf_url text,                                -- 관련 PDF URL

  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),

  -- 제약 조건
  CONSTRAINT unique_announcement_type UNIQUE(announcement_id, type_name)
);

-- ============================================
-- 2. 커스텀 섹션 지원 (announcement_sections 확장)
-- ============================================
-- 기존 섹션 타입 외에도 "커스텀" 섹션 추가 가능
-- 백오피스에서 자유롭게 섹션 추가/수정

ALTER TABLE announcement_sections
  DROP CONSTRAINT IF EXISTS announcement_sections_section_type_check;

ALTER TABLE announcement_sections
  ADD CONSTRAINT announcement_sections_section_type_check
  CHECK (section_type IN (
    'basic_info',      -- 기본 정보
    'schedule',        -- 일정
    'eligibility',     -- 신청 자격
    'housing_info',    -- 단지 정보
    'location',        -- 위치
    'attachments',     -- 첨부 파일
    'custom'           -- 🆕 커스텀 섹션
  ));

-- 커스텀 섹션을 위한 컬럼 추가
ALTER TABLE announcement_sections
  ADD COLUMN IF NOT EXISTS is_custom boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS custom_content jsonb;

-- 커스텀 섹션 체크: is_custom=true면 section_type='custom' 이어야 함
ALTER TABLE announcement_sections
  ADD CONSTRAINT check_custom_section
  CHECK (
    (is_custom = false) OR
    (is_custom = true AND section_type = 'custom')
  );

-- ============================================
-- 3. 인덱스 추가
-- ============================================

-- announcement_types 조회 최적화
CREATE INDEX idx_announcement_types_announcement
  ON announcement_types(announcement_id, order_index);

-- 커스텀 섹션 필터링
CREATE INDEX idx_announcement_sections_custom
  ON announcement_sections(announcement_id, is_custom)
  WHERE is_custom = true;

-- ============================================
-- 4. RLS (Row Level Security)
-- ============================================

ALTER TABLE announcement_types ENABLE ROW LEVEL SECURITY;

-- 모든 사용자 읽기 가능
CREATE POLICY "Public read access"
  ON announcement_types FOR SELECT
  USING (true);

-- 관리자만 쓰기 (추후 구현)
-- CREATE POLICY "Admin write access"
--   ON announcement_types FOR ALL
--   USING (auth.role() = 'admin');

-- ============================================
-- 5. 트리거 (updated_at 자동 갱신)
-- ============================================

CREATE TRIGGER update_announcement_types_updated_at
  BEFORE UPDATE ON announcement_types
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 6. 샘플 데이터 (테스트용)
-- ============================================

-- 예시: 공고 ID가 있다면 유형별 정보 추가
-- INSERT INTO announcement_types (announcement_id, type_name, deposit, monthly_rent, order_index)
-- SELECT
--   a.id,
--   '16A 청년',
--   20000000,  -- 보증금 2,000만원
--   150000,    -- 월세 15만원
--   1
-- FROM announcements a
-- WHERE a.title LIKE '%행복주택%'
-- LIMIT 1;

-- ============================================
-- 7. 헬퍼 뷰 (선택)
-- ============================================

-- 공고 + 유형별 정보 조인 뷰
CREATE OR REPLACE VIEW v_announcements_with_types AS
SELECT
  a.*,
  json_agg(
    json_build_object(
      'id', at.id,
      'type_name', at.type_name,
      'deposit', at.deposit,
      'monthly_rent', at.monthly_rent,
      'eligible_condition', at.eligible_condition,
      'order_index', at.order_index,
      'icon_url', at.icon_url,
      'pdf_url', at.pdf_url
    ) ORDER BY at.order_index
  ) FILTER (WHERE at.id IS NOT NULL) as types
FROM announcements a
LEFT JOIN announcement_types at ON a.id = at.announcement_id
GROUP BY a.id;

-- ============================================
-- 8. 코멘트 (문서화)
-- ============================================

COMMENT ON TABLE announcement_types IS
  '공고별 유형 정보 (보증금/월세) - 16A 청년, 26B 신혼부부 등';

COMMENT ON COLUMN announcement_types.type_name IS
  '유형명 (예: 16A 청년, 26B 신혼부부)';

COMMENT ON COLUMN announcement_types.deposit IS
  '보증금 (원 단위, bigint)';

COMMENT ON COLUMN announcement_types.monthly_rent IS
  '월세 (원 단위, integer)';

COMMENT ON COLUMN announcement_sections.is_custom IS
  '커스텀 섹션 여부 (true면 백오피스에서 자유롭게 작성)';

COMMENT ON COLUMN announcement_sections.custom_content IS
  '커스텀 섹션 내용 (JSONB, 자유 형식)';

-- ============================================
-- 완료!
-- ============================================

COMMENT ON SCHEMA public IS 'Pickly Service Schema - v1.1 (Types + Custom Content)';
