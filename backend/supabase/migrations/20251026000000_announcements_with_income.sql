-- ============================================
-- LH 공고 시스템 - announcements 테이블
-- ============================================
-- 목표: LH API 데이터 저장 + 평형별 탭 + 소득 조건 지원

-- ============================================
-- 1. announcements 테이블 생성
-- ============================================
CREATE TABLE IF NOT EXISTS announcements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- 기본 정보
  title TEXT NOT NULL,
  subtitle TEXT,
  category TEXT NOT NULL,
  source TEXT NOT NULL,
  source_id TEXT UNIQUE NOT NULL,

  -- 원본 데이터 (LH API 원본 JSON)
  raw_data JSONB NOT NULL DEFAULT '{}'::jsonb,

  -- 공통 섹션 (모든 평형 공통)
  display_config JSONB NOT NULL DEFAULT '{"commonSections": []}'::jsonb,

  -- 평형별 탭 (소득 조건 포함)
  housing_types JSONB NOT NULL DEFAULT '[]'::jsonb,

  -- 상태
  status TEXT DEFAULT 'draft',

  -- 메타
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 2. 인덱스 생성
-- ============================================
CREATE INDEX IF NOT EXISTS idx_announcements_source_id ON announcements(source_id);
CREATE INDEX IF NOT EXISTS idx_announcements_status ON announcements(status);
CREATE INDEX IF NOT EXISTS idx_announcements_category ON announcements(category);

-- ============================================
-- 3. 샘플 데이터 삽입
-- ============================================
INSERT INTO announcements (
  title,
  subtitle,
  category,
  source,
  source_id,
  raw_data,
  display_config,
  housing_types,
  status
) VALUES (
  '하남미사 C3BL 행복주택',
  '공고 마감까지 3일 남았어요',
  '주거',
  'LH',
  '2024000001',
  '{
    "PAN_ID": "2024000001",
    "PAN_NM": "하남미사 C3BL 행복주택",
    "UPP_AIS_TP_CD_NM": "행복주택",
    "CNP_CD_NM": "경기도",
    "HSHLD_CO": "1492",
    "RCRIT_PBLANC_DE": "20250930",
    "SUBSCRPT_RCEPT_BGNDE": "20250930",
    "SUBSCRPT_RCEPT_ENDDE": "20251130",
    "PRZWNER_PRESNATN_DE": "20251225"
  }'::jsonb,
  '{
    "commonSections": [
      {
        "type": "basic_info",
        "title": "기본 정보",
        "icon": "info",
        "enabled": true,
        "order": 1,
        "fields": [
          {"key": "source", "label": "공급 기관", "value": "LH 행복 주택", "visible": true, "order": 1},
          {"key": "category", "label": "카테고리", "value": "행복주택", "visible": true, "order": 2}
        ]
      },
      {
        "type": "schedule",
        "title": "일정",
        "icon": "calendar_today",
        "enabled": true,
        "order": 2,
        "fields": [
          {"key": "apply_period", "label": "접수 기간", "value": "2025.09.30(월) - 2025.11.30(월)", "visible": true, "order": 1},
          {"key": "announcement_date", "label": "당첨자 발표", "value": "2025.12.25", "visible": true, "order": 2}
        ]
      },
      {
        "type": "property",
        "title": "단지 정보",
        "icon": "apartment",
        "enabled": true,
        "order": 3,
        "fields": [
          {"key": "name", "label": "단지명", "value": "하남미사 C3BL 행복주택", "visible": true, "order": 1},
          {"key": "address", "label": "주소", "value": "경기도 하남시 미사강변한강로 290-3", "visible": true, "order": 2},
          {"key": "total_supply", "label": "총 공급호수", "value": "1,492호", "visible": true, "order": 3}
        ]
      },
      {
        "type": "map",
        "title": "위치",
        "icon": "location_on",
        "enabled": true,
        "order": 4,
        "fields": [
          {"key": "address", "label": "주소", "value": "경기도 하남시 미사강변한강로 290-3", "visible": true, "order": 1}
        ]
      }
    ]
  }'::jsonb,
  '[
    {
      "id": "16m-type1a",
      "area": 16,
      "areaLabel": "16㎡ (약 5평)",
      "type": "타입 1A",
      "targetGroup": "청년",
      "tabLabel": "타입 1A",
      "order": 1,
      "floorPlanImage": "",
      "sections": [
        {
          "type": "eligibility",
          "title": "신청 자격",
          "icon": "person",
          "enabled": true,
          "order": 1,
          "fields": [
            {"key": "age", "label": "연령", "value": "만 19세 ~ 39세", "visible": true, "order": 1},
            {"key": "residence", "label": "거주", "value": "경기도 6개월 이상 거주", "visible": true, "order": 2},
            {"key": "housing", "label": "주택", "value": "무주택 / 사회초년생", "visible": true, "order": 3}
          ]
        },
        {
          "type": "income",
          "title": "소득 기준",
          "icon": "attach_money",
          "enabled": true,
          "order": 2,
          "description": "전년도 도시근로자 가구당 월평균 소득 기준",
          "fields": [
            {"key": "household_income", "label": "가구 소득", "value": "전년도 도시근로자 월평균 소득 100% 이하", "detail": "1인 가구: 4,445,807원", "visible": true, "order": 1},
            {"key": "personal_income", "label": "본인 소득", "value": "전년도 도시근로자 월평균 소득 70% 이하", "detail": "1인 가구: 3,112,065원", "visible": true, "order": 2},
            {"key": "asset", "label": "자산", "value": "총자산 2억 8,800만원 이하", "detail": "부동산, 금융자산 등 합산", "visible": true, "order": 3},
            {"key": "car", "label": "자동차", "value": "자동차 가액 3,683만원 이하", "detail": "차량 1대 기준", "visible": true, "order": 4}
          ]
        },
        {
          "type": "pricing",
          "title": "공급 조건",
          "icon": "home",
          "enabled": true,
          "order": 3,
          "fields": [
            {"key": "supply_count", "label": "공급호수", "value": "200호", "visible": true, "order": 1},
            {"key": "deposit_standard", "label": "임대보증금 (표준)", "value": "3,284만원", "detail": "30% 임대료", "visible": true, "order": 2},
            {"key": "monthly_rent_standard", "label": "월 임대료 (표준)", "value": "13.89만원", "visible": true, "order": 3}
          ]
        }
      ]
    }
  ]'::jsonb,
  'active'
) ON CONFLICT (source_id) DO NOTHING;

-- ============================================
-- 4. RLS (Row Level Security) 정책
-- ============================================
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;

-- 모든 사용자가 읽을 수 있음
CREATE POLICY "Anyone can view published announcements"
  ON announcements FOR SELECT
  USING (status = 'active');

-- 인증된 사용자만 삽입/수정/삭제 가능 (관리자용)
CREATE POLICY "Authenticated users can manage announcements"
  ON announcements FOR ALL
  USING (auth.role() = 'authenticated');

-- ============================================
-- 5. 업데이트 트리거 (updated_at 자동 갱신)
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_announcements_updated_at
  BEFORE UPDATE ON announcements
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
