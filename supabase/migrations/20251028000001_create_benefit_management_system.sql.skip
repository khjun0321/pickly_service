-- =====================================================
-- Pickly Service v7.3: Benefit Management System
-- =====================================================
-- Migration: 20251028000001
-- Description: Create benefit categories, banners, announcement types, and announcements tables
-- Author: Claude Code (Pickly Project)
-- Date: 2025-10-28
-- =====================================================

-- Enable UUID extension (if not already enabled)
create extension if not exists "uuid-ossp";

-- =====================================================
-- 1. benefit_categories 테이블
-- =====================================================
-- 혜택 카테고리 (인기, 주거, 교육, 건강, 교통, 복지, 취업, 지원, 문화)
create table if not exists public.benefit_categories (
    id uuid primary key default uuid_generate_v4(),
    title text not null unique,
    icon_url text,
    sort_order integer not null default 0,
    is_active boolean not null default true,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Indexes for benefit_categories
create index idx_benefit_categories_sort_order on public.benefit_categories(sort_order);
create index idx_benefit_categories_is_active on public.benefit_categories(is_active);

-- Trigger for updated_at
create or replace function public.update_benefit_categories_updated_at()
returns trigger as $$
begin
    new.updated_at = timezone('utc'::text, now());
    return new;
end;
$$ language plpgsql;

create trigger trigger_benefit_categories_updated_at
    before update on public.benefit_categories
    for each row
    execute function public.update_benefit_categories_updated_at();

-- =====================================================
-- 2. category_banners 테이블
-- =====================================================
-- 카테고리별 배너 (각 혜택 페이지 상단 캐러셀)
create table if not exists public.category_banners (
    id uuid primary key default uuid_generate_v4(),
    benefit_category_id uuid not null references public.benefit_categories(id) on delete cascade,
    title text not null,
    subtitle text,
    image_url text not null,
    link_type text not null default 'none' check (link_type in ('internal', 'external', 'none')),
    link_target text,
    sort_order integer not null default 0,
    is_active boolean not null default true,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Indexes for category_banners
create index idx_category_banners_benefit_category on public.category_banners(benefit_category_id);
create index idx_category_banners_sort_order on public.category_banners(sort_order);
create index idx_category_banners_is_active on public.category_banners(is_active);

-- Trigger for updated_at
create or replace function public.update_category_banners_updated_at()
returns trigger as $$
begin
    new.updated_at = timezone('utc'::text, now());
    return new;
end;
$$ language plpgsql;

create trigger trigger_category_banners_updated_at
    before update on public.category_banners
    for each row
    execute function public.update_category_banners_updated_at();

-- =====================================================
-- 3. announcement_types 테이블
-- =====================================================
-- 공고 유형 (청년, 신혼부부, 고령자 등 - 필터 탭 역할)
create table if not exists public.announcement_types (
    id uuid primary key default uuid_generate_v4(),
    benefit_category_id uuid not null references public.benefit_categories(id) on delete cascade,
    title text not null,
    description text,
    sort_order integer not null default 0,
    is_active boolean not null default true,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
    constraint unique_title_per_category unique (benefit_category_id, title)
);

-- Indexes for announcement_types
create index idx_announcement_types_benefit_category on public.announcement_types(benefit_category_id);
create index idx_announcement_types_sort_order on public.announcement_types(sort_order);
create index idx_announcement_types_is_active on public.announcement_types(is_active);

-- Trigger for updated_at
create or replace function public.update_announcement_types_updated_at()
returns trigger as $$
begin
    new.updated_at = timezone('utc'::text, now());
    return new;
end;
$$ language plpgsql;

create trigger trigger_announcement_types_updated_at
    before update on public.announcement_types
    for each row
    execute function public.update_announcement_types_updated_at();

-- =====================================================
-- 4. announcements 테이블
-- =====================================================
-- 개별 공고 (LH, SH, GH 등의 정책 공고)
create table if not exists public.announcements (
    id uuid primary key default uuid_generate_v4(),
    type_id uuid not null references public.announcement_types(id) on delete cascade,
    title text not null,
    organization text not null,
    region text,
    thumbnail_url text,
    posted_date date,
    status text not null default 'active' check (status in ('active', 'closed', 'upcoming')),
    is_priority boolean not null default false,
    detail_url text,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Indexes for announcements
create index idx_announcements_type_id on public.announcements(type_id);
create index idx_announcements_status on public.announcements(status);
create index idx_announcements_is_priority on public.announcements(is_priority);
create index idx_announcements_posted_date on public.announcements(posted_date desc);
create index idx_announcements_organization on public.announcements(organization);

-- Composite index for filtering by type and status
create index idx_announcements_type_status on public.announcements(type_id, status);

-- Trigger for updated_at
create or replace function public.update_announcements_updated_at()
returns trigger as $$
begin
    new.updated_at = timezone('utc'::text, now());
    return new;
end;
$$ language plpgsql;

create trigger trigger_announcements_updated_at
    before update on public.announcements
    for each row
    execute function public.update_announcements_updated_at();

-- =====================================================
-- 5. RLS Policies (Public Read Access)
-- =====================================================

-- Enable RLS
alter table public.benefit_categories enable row level security;
alter table public.category_banners enable row level security;
alter table public.announcement_types enable row level security;
alter table public.announcements enable row level security;

-- Public read policies
create policy "benefit_categories: public read access"
    on public.benefit_categories for select
    using (true);

create policy "category_banners: public read access"
    on public.category_banners for select
    using (true);

create policy "announcement_types: public read access"
    on public.announcement_types for select
    using (true);

create policy "announcements: public read access"
    on public.announcements for select
    using (true);

-- =====================================================
-- 6. Seed Data - Default Benefit Categories
-- =====================================================

insert into public.benefit_categories (title, sort_order, is_active)
values
    ('인기', 1, true),
    ('주거', 2, true),
    ('교육', 3, true),
    ('건강', 4, true),
    ('교통', 5, true),
    ('복지', 6, true),
    ('취업', 7, true),
    ('지원', 8, true),
    ('문화', 9, true)
on conflict (title) do nothing;

-- =====================================================
-- 7. Views for Efficient Queries
-- =====================================================

-- View: Announcements with type and category info
create or replace view public.v_announcements_full as
select
    a.id,
    a.title,
    a.organization,
    a.region,
    a.thumbnail_url,
    a.posted_date,
    a.status,
    a.is_priority,
    a.detail_url,
    a.created_at,
    a.updated_at,
    at.id as type_id,
    at.title as type_title,
    bc.id as category_id,
    bc.title as category_title
from public.announcements a
join public.announcement_types at on a.type_id = at.id
join public.benefit_categories bc on at.benefit_category_id = bc.id;

-- =====================================================
-- 8. Comments for Documentation
-- =====================================================

comment on table public.benefit_categories is '혜택 카테고리 (인기/주거/교육 등)';
comment on table public.category_banners is '카테고리별 배너 이미지';
comment on table public.announcement_types is '공고 유형 (청년/신혼부부/고령자 등)';
comment on table public.announcements is '개별 정책 공고';

comment on column public.category_banners.link_type is 'internal: 앱 내 페이지, external: 외부 URL, none: 클릭 불가';
comment on column public.announcements.status is 'active: 모집중, closed: 마감, upcoming: 예정';
comment on column public.announcements.is_priority is '우선 표시 여부 (상단 고정)';
