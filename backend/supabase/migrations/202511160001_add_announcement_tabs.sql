-- ================================================================
-- Migration: Add Announcement Floor Plan Tabs (Extension Only)
-- Version: v9.6.1
-- Purpose: Add optional tab-based structure for complex announcements
--          (e.g., LH housing with multiple floor plan types)
-- ================================================================
-- This migration adds 3 new tables:
--   1. announcement_tabs: Tab metadata (title, order)
--   2. announcement_tab_contents: Text content sections per tab
--   3. announcement_tab_images: Images per tab
-- ================================================================

-- Table 1: announcement_tabs
-- Stores tab information for announcements
create table if not exists public.announcement_tabs (
  id uuid primary key default gen_random_uuid(),
  announcement_id uuid not null references public.announcements(id) on delete cascade,
  title text not null,
  sort_order int default 0,
  created_at timestamptz default now()
);

-- Table 2: announcement_tab_contents
-- Stores text content sections for each tab
create table if not exists public.announcement_tab_contents (
  id uuid primary key default gen_random_uuid(),
  tab_id uuid not null references public.announcement_tabs(id) on delete cascade,
  section_title text,
  section_body text,
  sort_order int default 0,
  created_at timestamptz default now()
);

-- Table 3: announcement_tab_images
-- Stores images for each tab
create table if not exists public.announcement_tab_images (
  id uuid primary key default gen_random_uuid(),
  tab_id uuid not null references public.announcement_tabs(id) on delete cascade,
  image_url text not null,
  caption text,
  sort_order int default 0,
  created_at timestamptz default now()
);

-- Create indexes for better query performance
create index if not exists idx_announcement_tabs_announcement_id
  on public.announcement_tabs(announcement_id);

create index if not exists idx_announcement_tab_contents_tab_id
  on public.announcement_tab_contents(tab_id);

create index if not exists idx_announcement_tab_images_tab_id
  on public.announcement_tab_images(tab_id);

-- Enable Row Level Security (RLS)
alter table public.announcement_tabs enable row level security;
alter table public.announcement_tab_contents enable row level security;
alter table public.announcement_tab_images enable row level security;

-- RLS Policies: Allow all operations for authenticated users (Admin only)
create policy "Allow all for authenticated users"
  on public.announcement_tabs
  for all
  to authenticated
  using (true)
  with check (true);

create policy "Allow all for authenticated users"
  on public.announcement_tab_contents
  for all
  to authenticated
  using (true)
  with check (true);

create policy "Allow all for authenticated users"
  on public.announcement_tab_images
  for all
  to authenticated
  using (true)
  with check (true);

-- Grant permissions
grant all on public.announcement_tabs to authenticated;
grant all on public.announcement_tab_contents to authenticated;
grant all on public.announcement_tab_images to authenticated;

grant all on public.announcement_tabs to service_role;
grant all on public.announcement_tab_contents to service_role;
grant all on public.announcement_tab_images to service_role;
