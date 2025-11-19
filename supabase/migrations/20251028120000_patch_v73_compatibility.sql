-- Pickly Service v7.3 Compatibility Patch
-- ALTER existing tables to match v7.3 PRD specification

-- 1. Patch benefit_categories
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'benefit_categories' AND column_name = 'name') THEN
    ALTER TABLE public.benefit_categories RENAME COLUMN name TO title;
    RAISE NOTICE 'Renamed: name → title';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'benefit_categories' AND column_name = 'display_order') THEN
    ALTER TABLE public.benefit_categories RENAME COLUMN display_order TO sort_order;
    RAISE NOTICE 'Renamed: display_order → sort_order';
  END IF;
END $$;

ALTER TABLE public.benefit_categories ADD COLUMN IF NOT EXISTS description TEXT, ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
UPDATE public.benefit_categories SET is_active = true WHERE is_active IS NULL;
DROP INDEX IF EXISTS idx_benefit_categories_display_order;
CREATE INDEX IF NOT EXISTS idx_benefit_categories_sort_order ON public.benefit_categories(sort_order);
CREATE INDEX IF NOT EXISTS idx_benefit_categories_is_active ON public.benefit_categories(is_active);

-- 2. Patch category_banners - Rename columns
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'category_banners' AND column_name = 'category_id') THEN
    ALTER TABLE public.category_banners RENAME COLUMN category_id TO benefit_category_id;
    RAISE NOTICE 'Renamed: category_id → benefit_category_id';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'category_banners' AND column_name = 'display_order') THEN
    ALTER TABLE public.category_banners RENAME COLUMN display_order TO sort_order;
    RAISE NOTICE 'Renamed: display_order → sort_order';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'category_banners' AND column_name = 'action_url') THEN
    ALTER TABLE public.category_banners RENAME COLUMN action_url TO link_target;
    RAISE NOTICE 'Renamed: action_url → link_target';
  END IF;
END $$;

-- Add link_type column (outside DO block so UPDATE can see renamed columns)
ALTER TABLE public.category_banners ADD COLUMN IF NOT EXISTS link_type TEXT DEFAULT 'internal' CHECK (link_type IN ('internal', 'external', 'none'));

-- Update link_type based on link_target
UPDATE public.category_banners SET link_type = CASE
  WHEN link_target IS NULL OR link_target = '' THEN 'none'
  WHEN link_target LIKE 'http%' THEN 'external'
  ELSE 'internal'
END WHERE link_type IS NULL;

DO $$
BEGIN
  RAISE NOTICE 'Added link_type column and set values';
END $$;

DROP INDEX IF EXISTS idx_category_banners_display_order;
CREATE INDEX IF NOT EXISTS idx_category_banners_sort_order ON public.category_banners(sort_order);
CREATE INDEX IF NOT EXISTS idx_category_banners_benefit_category ON public.category_banners(benefit_category_id);

-- 3. Create announcement_types
CREATE TABLE IF NOT EXISTS public.announcement_types (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  benefit_category_id UUID NOT NULL REFERENCES public.benefit_categories(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  CONSTRAINT unique_title_per_category UNIQUE (benefit_category_id, title)
);

CREATE INDEX IF NOT EXISTS idx_announcement_types_benefit_category ON public.announcement_types(benefit_category_id);
CREATE INDEX IF NOT EXISTS idx_announcement_types_sort_order ON public.announcement_types(sort_order);
CREATE INDEX IF NOT EXISTS idx_announcement_types_is_active ON public.announcement_types(is_active);

CREATE OR REPLACE FUNCTION public.update_announcement_types_updated_at() RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = timezone('utc'::text, now()); RETURN NEW; END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_announcement_types_updated_at ON public.announcement_types;
CREATE TRIGGER trigger_announcement_types_updated_at BEFORE UPDATE ON public.announcement_types
  FOR EACH ROW EXECUTE FUNCTION public.update_announcement_types_updated_at();

ALTER TABLE public.announcement_types ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "announcement_types: public read access" ON public.announcement_types;
CREATE POLICY "announcement_types: public read access" ON public.announcement_types FOR SELECT USING (true);

-- 4. Rename existing announcements table and create new v7.3 announcements
DO $$
BEGIN
  -- Rename existing housing-specific announcements table
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'announcements') THEN
    ALTER TABLE public.announcements RENAME TO housing_announcements;
    RAISE NOTICE 'Renamed: announcements → housing_announcements';
  END IF;
END $$;

-- Create new v7.3 announcements table
CREATE TABLE public.announcements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  type_id UUID NOT NULL REFERENCES public.announcement_types(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  organization TEXT NOT NULL,
  region TEXT,
  thumbnail_url TEXT,
  posted_date DATE,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'closed', 'upcoming')),
  is_priority BOOLEAN NOT NULL DEFAULT false,
  detail_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE INDEX idx_announcements_type_id ON public.announcements(type_id);
CREATE INDEX idx_announcements_v73_status ON public.announcements(status);
CREATE INDEX idx_announcements_is_priority ON public.announcements(is_priority);
CREATE INDEX idx_announcements_posted_date ON public.announcements(posted_date DESC);
CREATE INDEX idx_announcements_organization ON public.announcements(organization);
CREATE INDEX idx_announcements_type_status ON public.announcements(type_id, status);

CREATE OR REPLACE FUNCTION public.update_announcements_updated_at() RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = timezone('utc'::text, now()); RETURN NEW; END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_announcements_updated_at ON public.announcements;
CREATE TRIGGER trigger_announcements_updated_at BEFORE UPDATE ON public.announcements
  FOR EACH ROW EXECUTE FUNCTION public.update_announcements_updated_at();

ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "announcements: public read access" ON public.announcements;
CREATE POLICY "announcements: public read access" ON public.announcements FOR SELECT USING (true);

-- 5. Create view
CREATE OR REPLACE VIEW public.v_announcements_full AS
SELECT a.id, a.title, a.organization, a.region, a.thumbnail_url, a.posted_date,
  a.status, a.is_priority, a.detail_url, a.created_at, a.updated_at,
  at.id as type_id, at.title as type_title,
  bc.id as category_id, bc.title as category_title
FROM public.announcements a
JOIN public.announcement_types at ON a.type_id = at.id
JOIN public.benefit_categories bc ON at.benefit_category_id = bc.id;

-- Summary
DO $$
BEGIN
  RAISE NOTICE '================================================';
  RAISE NOTICE '✅ v7.3 Compatibility Patch Completed';
  RAISE NOTICE '================================================';
END $$;
