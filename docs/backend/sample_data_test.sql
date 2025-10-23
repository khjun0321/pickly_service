-- =============================================================================
-- Benefit System Sample Data Test
-- Purpose: Insert sample data and verify system functionality
-- =============================================================================

BEGIN;

-- =============================================================================
-- 1. INSERT SAMPLE HOUSING ANNOUNCEMENT
-- =============================================================================

-- Insert main announcement
INSERT INTO benefit_announcements (
    category_id,
    title,
    subtitle,
    organization,
    application_period_start,
    application_period_end,
    announcement_date,
    status,
    is_featured,
    summary,
    tags
) VALUES (
    (SELECT id FROM benefit_categories WHERE slug = 'housing'),
    '2024년 행복주택 입주자 모집',
    '청년 및 신혼부부 대상',
    'LH 한국토지주택공사',
    '2024-11-01',
    '2024-11-15',
    '2024-10-23',
    'published',
    TRUE,
    '청년 및 신혼부부를 위한 행복주택 입주자를 모집합니다. 서울시 강남구 역삼동 소재 행복주택으로 교통이 편리하고 주변 인프라가 잘 갖춰져 있습니다.',
    ARRAY['청년', '신혼부부', '임대주택', '행복주택', '강남구']
) RETURNING id as announcement_id;

-- Save the ID for subsequent inserts
\gset

-- Insert unit types
INSERT INTO announcement_unit_types (
    announcement_id,
    unit_type,
    exclusive_area,
    supply_area,
    unit_count,
    deposit_amount,
    monthly_rent,
    room_layout,
    display_order
) VALUES
    (:announcement_id, '36㎡', 36.00, 46.00, 50, 3000000, 250000, '1Bay', 1),
    (:announcement_id, '45㎡', 45.00, 55.00, 80, 5000000, 350000, '2Bay', 2),
    (:announcement_id, '59㎡', 59.00, 79.00, 100, 7000000, 450000, '3Bay', 3);

-- Insert eligibility section
INSERT INTO announcement_sections (
    announcement_id,
    section_type,
    title,
    content,
    structured_data,
    display_order
) VALUES (
    :announcement_id,
    'eligibility',
    '신청자격',
    '다음 조건을 모두 충족하는 무주택 세대구성원',
    '{
        "requirements": [
            {
                "category": "청년",
                "conditions": [
                    "만 19세 이상 39세 이하",
                    "무주택 세대구성원",
                    "월평균소득이 전년도 도시근로자 가구당 월평균소득의 100% 이하",
                    "자산 보유 기준 충족"
                ]
            },
            {
                "category": "신혼부부",
                "conditions": [
                    "혼인기간 7년 이내",
                    "무주택 세대구성원",
                    "부부 합산 월평균소득이 전년도 도시근로자 가구당 월평균소득의 120% 이하",
                    "자산 보유 기준 충족"
                ]
            }
        ]
    }'::jsonb,
    1
);

-- Insert documents section
INSERT INTO announcement_sections (
    announcement_id,
    section_type,
    title,
    content,
    structured_data,
    display_order
) VALUES (
    :announcement_id,
    'documents',
    '제출서류',
    '입주신청 시 다음 서류를 준비하세요',
    '{
        "common_documents": [
            {"name": "주민등록등본", "required": true, "notes": "주민센터 발급"},
            {"name": "가족관계증명서", "required": true, "notes": "주민센터 발급"},
            {"name": "혼인관계증명서", "required": false, "notes": "신혼부부만 해당"},
            {"name": "소득증빙서류", "required": true, "notes": "재직증명서, 소득금액증명원 등"}
        ],
        "asset_documents": [
            {"name": "자산보유확인서", "required": true, "notes": "은행 잔액증명서 등"},
            {"name": "부채확인서", "required": false, "notes": "해당자만"}
        ]
    }'::jsonb,
    2
);

-- Insert schedule section
INSERT INTO announcement_sections (
    announcement_id,
    section_type,
    title,
    content,
    structured_data,
    display_order
) VALUES (
    :announcement_id,
    'schedule',
    '주요 일정',
    '입주자 모집 및 선정 일정',
    '{
        "timeline": [
            {"date": "2024-11-01", "event": "입주자 모집공고"},
            {"date": "2024-11-01 ~ 2024-11-15", "event": "청약 접수 기간"},
            {"date": "2024-11-20", "event": "당첨자 발표"},
            {"date": "2024-11-25 ~ 2024-11-30", "event": "계약 체결"},
            {"date": "2025-01-15", "event": "입주 시작 (예정)"}
        ]
    }'::jsonb,
    3
);

-- Insert benefits section
INSERT INTO announcement_sections (
    announcement_id,
    section_type,
    title,
    content,
    structured_data,
    display_order
) VALUES (
    :announcement_id,
    'benefits',
    '주요 혜택',
    '행복주택 입주 시 받을 수 있는 혜택',
    '{
        "benefits": [
            {"title": "저렴한 임대료", "description": "주변 시세 대비 60~80% 수준"},
            {"title": "최장 6년 거주", "description": "청년 최장 6년, 신혼부부 최장 6년 거주 가능"},
            {"title": "우수한 입지", "description": "대중교통 접근성 우수, 역세권 위치"},
            {"title": "편의시설 완비", "description": "커뮤니티시설, 주차장, 보안시스템 완비"}
        ]
    }'::jsonb,
    4
);

-- =============================================================================
-- 2. INSERT SAMPLE WELFARE ANNOUNCEMENT
-- =============================================================================

INSERT INTO benefit_announcements (
    category_id,
    title,
    subtitle,
    organization,
    application_period_start,
    application_period_end,
    status,
    is_featured,
    summary,
    tags
) VALUES (
    (SELECT id FROM benefit_categories WHERE slug = 'welfare'),
    '2024년 청년 생활안정 지원금',
    '월 최대 50만원 지원',
    '서울시',
    '2024-10-25',
    '2024-12-31',
    'published',
    TRUE,
    '취업준비 중인 청년에게 생활안정자금을 지원합니다. 최대 6개월간 월 50만원을 지원하여 안정적인 취업준비를 돕습니다.',
    ARRAY['청년', '생활지원', '취업준비', '서울시']
) RETURNING id as welfare_announcement_id;

\gset

-- Insert eligibility for welfare
INSERT INTO announcement_sections (
    announcement_id,
    section_type,
    title,
    content,
    structured_data,
    display_order
) VALUES (
    :welfare_announcement_id,
    'eligibility',
    '지원대상',
    '다음 요건을 모두 충족하는 청년',
    '{
        "requirements": [
            "만 19세 이상 34세 이하의 서울시 거주 청년",
            "미취업 상태로 구직활동 중인 자",
            "가구소득이 중위소득 150% 이하",
            "최근 2년 이내 정규직 취업 이력이 없는 자"
        ]
    }'::jsonb,
    1
);

-- =============================================================================
-- 3. INSERT SAMPLE EDUCATION ANNOUNCEMENT
-- =============================================================================

INSERT INTO benefit_announcements (
    category_id,
    title,
    organization,
    application_period_start,
    application_period_end,
    status,
    summary,
    tags
) VALUES (
    (SELECT id FROM benefit_categories WHERE slug = 'education'),
    '대학생 학자금 대출 이자 지원사업',
    '한국장학재단',
    '2024-11-01',
    '2024-11-30',
    'published',
    '저소득층 대학생의 학자금 대출 이자를 전액 또는 일부 지원합니다.',
    ARRAY['대학생', '학자금', '이자지원', '장학금']
);

COMMIT;

-- =============================================================================
-- 4. VERIFICATION QUERIES
-- =============================================================================

-- Check inserted announcements
SELECT
    a.title,
    c.name as category,
    a.status,
    a.is_featured,
    array_length(a.tags, 1) as tag_count
FROM benefit_announcements a
JOIN benefit_categories c ON a.category_id = c.id
ORDER BY a.created_at DESC;

-- Check unit types
SELECT
    a.title,
    u.unit_type,
    u.exclusive_area,
    u.monthly_rent,
    u.deposit_amount
FROM announcement_unit_types u
JOIN benefit_announcements a ON u.announcement_id = a.id
ORDER BY a.title, u.display_order;

-- Check sections
SELECT
    a.title,
    s.section_type,
    s.title as section_title,
    LENGTH(s.content) as content_length
FROM announcement_sections s
JOIN benefit_announcements a ON s.announcement_id = a.id
ORDER BY a.title, s.display_order;

-- Test full-text search
SELECT
    title,
    subtitle,
    organization,
    ts_rank(search_vector, plainto_tsquery('simple', '청년')) as rank
FROM benefit_announcements
WHERE search_vector @@ plainto_tsquery('simple', '청년')
ORDER BY rank DESC;

-- Test views
SELECT * FROM v_published_announcements;
SELECT * FROM v_featured_announcements;
SELECT * FROM v_announcement_stats;

-- =============================================================================
-- 5. PERFORMANCE TEST
-- =============================================================================

-- Test index usage (EXPLAIN ANALYZE)
EXPLAIN ANALYZE
SELECT * FROM benefit_announcements
WHERE status = 'published'
AND '청년' = ANY(tags)
ORDER BY published_at DESC
LIMIT 10;

EXPLAIN ANALYZE
SELECT * FROM benefit_announcements
WHERE search_vector @@ plainto_tsquery('simple', '주거 지원')
ORDER BY ts_rank(search_vector, plainto_tsquery('simple', '주거 지원')) DESC
LIMIT 10;

-- =============================================================================
-- 6. CLEANUP (Optional - Uncomment to remove test data)
-- =============================================================================

/*
BEGIN;

-- Delete test announcements (CASCADE will delete related records)
DELETE FROM benefit_announcements
WHERE title IN (
    '2024년 행복주택 입주자 모집',
    '2024년 청년 생활안정 지원금',
    '대학생 학자금 대출 이자 지원사업'
);

COMMIT;
*/

-- =============================================================================
-- TEST COMPLETE
-- =============================================================================

SELECT 'Sample data insertion and verification complete!' as status;
