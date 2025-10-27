-- ================================================
-- Pickly Benefit Management System - Backoffice Extensions
-- Migration: 20251024100000_benefit_management_phase1.sql
-- ================================================

-- This migration extends the existing benefit system with backoffice features

-- ================================================
-- 1. ADD CUSTOM FIELDS TO EXISTING BENEFIT_CATEGORIES
-- ================================================
-- Add custom_fields column to benefit_categories if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'benefit_categories'
        AND column_name = 'custom_fields'
    ) THEN
        ALTER TABLE public.benefit_categories
        ADD COLUMN custom_fields JSONB DEFAULT '{}';

        RAISE NOTICE 'Added custom_fields column to benefit_categories';
    END IF;
END $$;

-- ================================================
-- 2. ADD BACKOFFICE FIELDS TO BENEFIT_ANNOUNCEMENTS
-- ================================================
-- Add display_order column for drag-and-drop ordering
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'benefit_announcements'
        AND column_name = 'display_order'
    ) THEN
        ALTER TABLE public.benefit_announcements
        ADD COLUMN display_order INTEGER NOT NULL DEFAULT 0;

        RAISE NOTICE 'Added display_order column to benefit_announcements';
    END IF;
END $$;

-- Add custom_data column for flexible category-specific data
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'benefit_announcements'
        AND column_name = 'custom_data'
    ) THEN
        ALTER TABLE public.benefit_announcements
        ADD COLUMN custom_data JSONB DEFAULT '{}';

        RAISE NOTICE 'Added custom_data column to benefit_announcements';
    END IF;
END $$;

-- Add content column for rich HTML content
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'benefit_announcements'
        AND column_name = 'content'
    ) THEN
        ALTER TABLE public.benefit_announcements
        ADD COLUMN content TEXT;

        RAISE NOTICE 'Added content column to benefit_announcements';
    END IF;
END $$;

-- ================================================
-- 3. CREATE ANNOUNCEMENT FILES TABLE
-- ================================================
CREATE TABLE IF NOT EXISTS public.announcement_files (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    announcement_id UUID NOT NULL REFERENCES public.benefit_announcements(id) ON DELETE CASCADE,
    file_name VARCHAR(500) NOT NULL,
    file_url VARCHAR(1000) NOT NULL,
    file_type VARCHAR(100),
    file_size BIGINT,
    display_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for file ordering
CREATE INDEX IF NOT EXISTS idx_announcement_files_order
ON public.announcement_files(announcement_id, display_order);

COMMENT ON TABLE public.announcement_files IS 'File attachments for benefit announcements';

-- ================================================
-- 4. CREATE DISPLAY ORDER HISTORY TABLE (Audit Trail)
-- ================================================
CREATE TABLE IF NOT EXISTS public.display_order_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID NOT NULL REFERENCES public.benefit_categories(id) ON DELETE CASCADE,
    announcement_id UUID NOT NULL REFERENCES public.benefit_announcements(id) ON DELETE CASCADE,
    old_order INTEGER NOT NULL,
    new_order INTEGER NOT NULL,
    changed_by UUID,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for history queries
CREATE INDEX IF NOT EXISTS idx_order_history_announcement
ON public.display_order_history(announcement_id, changed_at DESC);

CREATE INDEX IF NOT EXISTS idx_order_history_category
ON public.display_order_history(category_id, changed_at DESC);

COMMENT ON TABLE public.display_order_history IS 'Audit trail for announcement display order changes';

-- ================================================
-- 5. FUNCTIONS
-- ================================================

-- Function to update display orders (for drag-and-drop reordering in backoffice)
CREATE OR REPLACE FUNCTION update_display_orders(
    p_category_id UUID,
    p_announcement_ids UUID[]
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_announcement_id UUID;
    v_index INTEGER;
    v_old_order INTEGER;
BEGIN
    -- Loop through announcement IDs and update their display orders
    FOREACH v_announcement_id IN ARRAY p_announcement_ids
    LOOP
        v_index := array_position(p_announcement_ids, v_announcement_id) - 1;

        -- Get current order for audit
        SELECT display_order INTO v_old_order
        FROM public.benefit_announcements
        WHERE id = v_announcement_id;

        -- Update display order
        UPDATE public.benefit_announcements
        SET display_order = v_index,
            updated_at = NOW()
        WHERE id = v_announcement_id
          AND category_id = p_category_id;

        -- Record in audit history
        IF v_old_order IS NOT NULL AND v_old_order != v_index THEN
            INSERT INTO public.display_order_history (
                category_id,
                announcement_id,
                old_order,
                new_order,
                changed_at
            ) VALUES (
                p_category_id,
                v_announcement_id,
                v_old_order,
                v_index,
                NOW()
            );
        END IF;
    END LOOP;
END;
$$;

COMMENT ON FUNCTION update_display_orders IS 'Updates announcement display order and logs changes to audit trail';

-- ================================================
-- 6. ROW LEVEL SECURITY (RLS) - BACKOFFICE EXTENSIONS
-- ================================================

-- Enable RLS on new tables (existing tables already have RLS enabled)
ALTER TABLE public.announcement_files ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.display_order_history ENABLE ROW LEVEL SECURITY;

-- RLS Policies for announcement_files
-- Public can view files of published announcements
CREATE POLICY "Public can view files of published announcements"
    ON public.announcement_files
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.benefit_announcements
            WHERE id = announcement_id
            AND status = 'published'
        )
    );

-- Authenticated users can manage files (for backoffice)
-- Note: In production, you should restrict this to admin users only
CREATE POLICY "Authenticated users can manage announcement files"
    ON public.announcement_files
    FOR ALL
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- RLS Policies for display_order_history
-- Only authenticated users can view audit history (for backoffice)
CREATE POLICY "Authenticated users can view order history"
    ON public.display_order_history
    FOR SELECT
    USING (auth.role() = 'authenticated');

-- ================================================
-- 7. UPDATE EXISTING DATA WITH CUSTOM FIELDS
-- ================================================

-- Update '주거' (housing) category with custom fields for housing-specific data
UPDATE public.benefit_categories
SET custom_fields = '{
    "housing_type": ["원룸", "투룸", "쓰리룸"],
    "region_categories": ["서울", "경기", "인천", "부산", "대구", "광주", "대전", "울산", "세종"],
    "age_categories": ["청년(19-39세)", "신혼부부", "고령자(65세 이상)"],
    "income_limit": true,
    "asset_limit": true,
    "family_size": ["1인", "2인", "3인", "4인 이상"]
}'::jsonb
WHERE slug = 'housing';

-- Update other categories with relevant custom fields
UPDATE public.benefit_categories
SET custom_fields = '{
    "program_type": ["현금지원", "바우처", "현물지원", "서비스제공"],
    "target_group": ["저소득층", "장애인", "한부모가정", "다문화가정", "노인"],
    "income_limit": true
}'::jsonb
WHERE slug = 'welfare';

UPDATE public.benefit_categories
SET custom_fields = '{
    "education_level": ["초등", "중등", "고등", "대학", "평생교육"],
    "support_type": ["학비지원", "장학금", "교육프로그램", "교재지원"],
    "income_limit": true
}'::jsonb
WHERE slug = 'education';

UPDATE public.benefit_categories
SET custom_fields = '{
    "job_type": ["정규직", "계약직", "인턴", "아르바이트"],
    "program_type": ["취업지원", "직업훈련", "창업지원", "자격증지원"],
    "target_group": ["청년", "경력단절여성", "중장년", "장애인"]
}'::jsonb
WHERE slug = 'employment';

UPDATE public.benefit_categories
SET custom_fields = '{
    "service_type": ["건강검진", "의료비지원", "예방접종", "건강교육"],
    "target_group": ["영유아", "아동", "청소년", "성인", "노인"],
    "income_limit": true
}'::jsonb
WHERE slug = 'health';

UPDATE public.benefit_categories
SET custom_fields = '{
    "activity_type": ["공연", "전시", "체육", "여가", "도서"],
    "support_type": ["이용권", "할인", "무료이용", "프로그램"],
    "target_group": ["전체", "청소년", "성인", "노인", "장애인"]
}'::jsonb
WHERE slug = 'culture';

-- ================================================
-- 8. CREATE INDEXES FOR NEW COLUMNS
-- ================================================

-- Index for display_order on benefit_announcements
CREATE INDEX IF NOT EXISTS idx_announcements_display_order
ON public.benefit_announcements(category_id, display_order, created_at);

-- GIN index for custom_data JSONB search
CREATE INDEX IF NOT EXISTS idx_announcements_custom_data
ON public.benefit_announcements USING GIN(custom_data);

-- GIN index for custom_fields on categories
CREATE INDEX IF NOT EXISTS idx_categories_custom_fields
ON public.benefit_categories USING GIN(custom_fields);

-- ================================================
-- 9. MIGRATION COMPLETION LOG
-- ================================================

DO $$
BEGIN
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Migration 20251024100000_benefit_management_phase1.sql completed';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Schema Extensions:';
    RAISE NOTICE '  - Added custom_fields column to benefit_categories';
    RAISE NOTICE '  - Added display_order, custom_data, content columns to benefit_announcements';
    RAISE NOTICE '  - Created announcement_files table for attachments';
    RAISE NOTICE '  - Created display_order_history table for audit trail';
    RAISE NOTICE '';
    RAISE NOTICE 'Functions:';
    RAISE NOTICE '  - Created update_display_orders() for drag-and-drop reordering';
    RAISE NOTICE '';
    RAISE NOTICE 'Indexes:';
    RAISE NOTICE '  - idx_announcements_display_order';
    RAISE NOTICE '  - idx_announcements_custom_data (GIN)';
    RAISE NOTICE '  - idx_categories_custom_fields (GIN)';
    RAISE NOTICE '  - idx_announcement_files_order';
    RAISE NOTICE '  - idx_order_history_announcement';
    RAISE NOTICE '';
    RAISE NOTICE 'RLS Policies:';
    RAISE NOTICE '  - Public read access for published announcement files';
    RAISE NOTICE '  - Authenticated user access for backoffice management';
    RAISE NOTICE '================================================';
END $$;
