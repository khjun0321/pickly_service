-- ============================================
-- Pickly Service - Rollback Migration
-- 공고 유형 및 커스텀 섹션 롤백
-- 생성일: 2025-10-27
-- ============================================

-- ⚠️ 주의: 이 마이그레이션은 데이터 손실을 발생시킵니다!
-- 실행 전 반드시 백업하세요.

-- ============================================
-- 1. 뷰 삭제
-- ============================================

DROP VIEW IF EXISTS v_announcements_with_types;

-- ============================================
-- 2. 테이블 삭제
-- ============================================

DROP TABLE IF EXISTS announcement_types CASCADE;

-- ============================================
-- 3. announcement_sections 원복
-- ============================================

-- 커스텀 컬럼 제거
ALTER TABLE announcement_sections
  DROP COLUMN IF EXISTS is_custom,
  DROP COLUMN IF EXISTS custom_content;

-- 제약 조건 원복 (custom 타입 제거)
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
    'attachments'      -- 첨부 파일
  ));

-- ============================================
-- 4. 인덱스 삭제
-- ============================================

DROP INDEX IF EXISTS idx_announcement_types_announcement;
DROP INDEX IF EXISTS idx_announcement_sections_custom;

-- ============================================
-- 완료
-- ============================================

COMMENT ON SCHEMA public IS 'Pickly Service Schema - v1.0 (Rollback Complete)';
