-- =====================================================
-- Supabase Storage SQL Reference - Pickly Service
-- =====================================================
-- Common SQL queries and operations for storage management
-- =====================================================

-- =====================================================
-- BUCKET MANAGEMENT
-- =====================================================

-- Check if bucket exists
SELECT id, name, public, created_at, updated_at
FROM storage.buckets
WHERE id = 'pickly-storage';

-- List all buckets
SELECT id, name, public, file_size_limit, allowed_mime_types
FROM storage.buckets
ORDER BY created_at DESC;

-- Update bucket settings
UPDATE storage.buckets
SET
  public = true,
  file_size_limit = 52428800,
  allowed_mime_types = ARRAY[
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/gif',
    'image/webp',
    'application/pdf'
  ]
WHERE id = 'pickly-storage';

-- =====================================================
-- FOLDER STRUCTURE
-- =====================================================

-- List all documented folders
SELECT path, description, created_at
FROM storage_folders
ORDER BY path;

-- Add new folder path
INSERT INTO storage_folders (path, description)
VALUES ('banners/featured/', 'Featured promotional banners')
ON CONFLICT (path) DO NOTHING;

-- =====================================================
-- FILE TRACKING
-- =====================================================

-- Insert file record after upload
INSERT INTO benefit_files (
  announcement_id,
  file_type,
  storage_path,
  file_name,
  file_size,
  mime_type,
  public_url,
  metadata
) VALUES (
  '123e4567-e89b-12d3-a456-426614174000',
  'thumbnail',
  'announcements/thumbnails/123e4567-e89b-12d3-a456-426614174000/thumb.jpg',
  'thumb.jpg',
  45678,
  'image/jpeg',
  'http://localhost:54321/storage/v1/object/public/pickly-storage/announcements/thumbnails/123e4567-e89b-12d3-a456-426614174000/thumb.jpg',
  '{"width": 800, "height": 600}'::jsonb
);

-- Get all files for an announcement
SELECT
  id,
  file_type,
  file_name,
  file_size,
  public_url,
  uploaded_at
FROM benefit_files
WHERE announcement_id = '123e4567-e89b-12d3-a456-426614174000'
ORDER BY uploaded_at DESC;

-- Get all thumbnails
SELECT
  bf.id,
  bf.file_name,
  bf.public_url,
  ba.title as announcement_title,
  ba.organization
FROM benefit_files bf
JOIN benefit_announcements ba ON bf.announcement_id = ba.id
WHERE bf.file_type = 'thumbnail'
ORDER BY bf.uploaded_at DESC
LIMIT 20;

-- Get files uploaded in last 24 hours
SELECT
  file_type,
  file_name,
  file_size,
  public_url,
  uploaded_at
FROM benefit_files
WHERE uploaded_at > NOW() - INTERVAL '24 hours'
ORDER BY uploaded_at DESC;

-- Get files by MIME type
SELECT
  file_name,
  file_size,
  mime_type,
  public_url
FROM benefit_files
WHERE mime_type LIKE 'image/%'
ORDER BY file_size DESC;

-- Find large files (> 10MB)
SELECT
  file_name,
  ROUND(file_size::numeric / 1024 / 1024, 2) as size_mb,
  mime_type,
  uploaded_at
FROM benefit_files
WHERE file_size > 10485760  -- 10MB in bytes
ORDER BY file_size DESC;

-- Delete file record (file must be deleted from storage separately)
DELETE FROM benefit_files
WHERE id = '123e4567-e89b-12d3-a456-426614174000';

-- =====================================================
-- STORAGE STATISTICS
-- =====================================================

-- Get storage stats by file type
SELECT * FROM v_storage_stats
ORDER BY total_size_mb DESC;

-- Total storage usage
SELECT
  COUNT(*) as total_files,
  SUM(file_size) as total_bytes,
  ROUND(SUM(file_size)::numeric / 1024 / 1024, 2) as total_mb,
  ROUND(AVG(file_size)::numeric, 2) as avg_file_size_bytes
FROM benefit_files;

-- Storage by announcement
SELECT
  ba.id,
  ba.title,
  ba.organization,
  COUNT(bf.id) as file_count,
  SUM(bf.file_size) as total_bytes,
  ROUND(SUM(bf.file_size)::numeric / 1024 / 1024, 2) as total_mb
FROM benefit_announcements ba
LEFT JOIN benefit_files bf ON ba.id = bf.announcement_id
GROUP BY ba.id, ba.title, ba.organization
HAVING COUNT(bf.id) > 0
ORDER BY total_bytes DESC
LIMIT 10;

-- Files uploaded per day (last 7 days)
SELECT
  DATE(uploaded_at) as upload_date,
  COUNT(*) as files_uploaded,
  SUM(file_size) as total_bytes,
  ROUND(SUM(file_size)::numeric / 1024 / 1024, 2) as total_mb
FROM benefit_files
WHERE uploaded_at > NOW() - INTERVAL '7 days'
GROUP BY DATE(uploaded_at)
ORDER BY upload_date DESC;

-- =====================================================
-- HELPER FUNCTIONS USAGE
-- =====================================================

-- Generate announcement file path
SELECT generate_announcement_file_path(
  '123e4567-e89b-12d3-a456-426614174000',
  'thumbnails',
  'image.jpg'
) as storage_path;

-- Generate banner path
SELECT generate_banner_path('housing', 'banner.jpg') as storage_path;

-- Generate public URL
SELECT get_storage_public_url(
  'pickly-storage',
  'banners/test/sample.jpg'
) as public_url;

-- Use helper in INSERT
INSERT INTO benefit_files (
  announcement_id,
  file_type,
  storage_path,
  file_name,
  file_size,
  mime_type,
  public_url
)
SELECT
  '123e4567-e89b-12d3-a456-426614174000'::uuid as announcement_id,
  'thumbnail' as file_type,
  generate_announcement_file_path(
    '123e4567-e89b-12d3-a456-426614174000',
    'thumbnails',
    'thumb.jpg'
  ) as storage_path,
  'thumb.jpg' as file_name,
  45678 as file_size,
  'image/jpeg' as mime_type,
  get_storage_public_url(
    'pickly-storage',
    generate_announcement_file_path(
      '123e4567-e89b-12d3-a456-426614174000',
      'thumbnails',
      'thumb.jpg'
    )
  ) as public_url;

-- =====================================================
-- VIEWS USAGE
-- =====================================================

-- Get all files with announcement details
SELECT
  announcement_id,
  announcement_title,
  organization,
  file_type,
  file_name,
  public_url,
  uploaded_at
FROM v_announcement_files
ORDER BY uploaded_at DESC
LIMIT 20;

-- Get thumbnails with announcement info
SELECT *
FROM v_announcement_files
WHERE file_type = 'thumbnail'
ORDER BY uploaded_at DESC;

-- =====================================================
-- RLS POLICY MANAGEMENT
-- =====================================================

-- List all storage policies
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE schemaname = 'storage' AND tablename = 'objects';

-- List benefit_files policies
SELECT
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'benefit_files';

-- Test RLS as anonymous user
SET ROLE anon;
SELECT * FROM benefit_files LIMIT 5;  -- Should work (public read)
RESET ROLE;

-- Test RLS as authenticated user
SET ROLE authenticated;
SELECT * FROM benefit_files LIMIT 5;  -- Should work
RESET ROLE;

-- =====================================================
-- MAINTENANCE
-- =====================================================

-- Find orphaned file records (announcement deleted but files remain)
SELECT
  bf.id,
  bf.announcement_id,
  bf.file_name,
  bf.storage_path
FROM benefit_files bf
LEFT JOIN benefit_announcements ba ON bf.announcement_id = ba.id
WHERE ba.id IS NULL AND bf.announcement_id IS NOT NULL;

-- Clean up orphaned records
DELETE FROM benefit_files
WHERE id IN (
  SELECT bf.id
  FROM benefit_files bf
  LEFT JOIN benefit_announcements ba ON bf.announcement_id = ba.id
  WHERE ba.id IS NULL AND bf.announcement_id IS NOT NULL
);

-- Find duplicate file paths
SELECT
  storage_path,
  COUNT(*) as duplicate_count
FROM benefit_files
GROUP BY storage_path
HAVING COUNT(*) > 1;

-- Update public URLs (if domain changed)
UPDATE benefit_files
SET public_url = REPLACE(
  public_url,
  'http://localhost:54321',
  'https://your-production-domain.com'
)
WHERE public_url LIKE 'http://localhost:54321%';

-- Recount file sizes (if needed)
SELECT
  SUM(file_size) as calculated_total_bytes,
  (SELECT SUM(file_size) FROM benefit_files) as stored_total_bytes
FROM benefit_files;

-- Vacuum and analyze for performance
VACUUM ANALYZE benefit_files;
VACUUM ANALYZE storage_folders;

-- =====================================================
-- BACKUP & EXPORT
-- =====================================================

-- Export file metadata as JSON
SELECT jsonb_agg(
  jsonb_build_object(
    'id', id,
    'announcement_id', announcement_id,
    'file_type', file_type,
    'storage_path', storage_path,
    'file_name', file_name,
    'file_size', file_size,
    'mime_type', mime_type,
    'public_url', public_url,
    'uploaded_at', uploaded_at,
    'metadata', metadata
  )
) as backup_data
FROM benefit_files;

-- Create backup table
CREATE TABLE benefit_files_backup AS
SELECT * FROM benefit_files;

-- Restore from backup
TRUNCATE benefit_files;
INSERT INTO benefit_files
SELECT * FROM benefit_files_backup;

-- =====================================================
-- MONITORING QUERIES
-- =====================================================

-- Storage growth over time
SELECT
  DATE_TRUNC('day', uploaded_at) as day,
  COUNT(*) as files_added,
  SUM(file_size) as bytes_added,
  ROUND(SUM(file_size)::numeric / 1024 / 1024, 2) as mb_added,
  SUM(COUNT(*)) OVER (ORDER BY DATE_TRUNC('day', uploaded_at)) as cumulative_files,
  ROUND(SUM(SUM(file_size)) OVER (ORDER BY DATE_TRUNC('day', uploaded_at))::numeric / 1024 / 1024, 2) as cumulative_mb
FROM benefit_files
GROUP BY DATE_TRUNC('day', uploaded_at)
ORDER BY day DESC;

-- File type distribution
SELECT
  file_type,
  COUNT(*) as count,
  ROUND(COUNT(*)::numeric * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM benefit_files
GROUP BY file_type
ORDER BY count DESC;

-- MIME type distribution
SELECT
  mime_type,
  COUNT(*) as count,
  SUM(file_size) as total_bytes,
  ROUND(SUM(file_size)::numeric / 1024 / 1024, 2) as total_mb
FROM benefit_files
GROUP BY mime_type
ORDER BY total_bytes DESC;

-- =====================================================
-- ADVANCED QUERIES
-- =====================================================

-- Get announcements with most files
SELECT
  ba.id,
  ba.title,
  COUNT(bf.id) as file_count,
  STRING_AGG(DISTINCT bf.file_type, ', ') as file_types,
  MAX(bf.uploaded_at) as last_upload
FROM benefit_announcements ba
JOIN benefit_files bf ON ba.id = bf.announcement_id
GROUP BY ba.id, ba.title
ORDER BY file_count DESC
LIMIT 10;

-- Get announcements missing thumbnails
SELECT
  ba.id,
  ba.title,
  ba.organization
FROM benefit_announcements ba
WHERE NOT EXISTS (
  SELECT 1
  FROM benefit_files bf
  WHERE bf.announcement_id = ba.id
  AND bf.file_type = 'thumbnail'
);

-- Get average files per announcement
SELECT
  ROUND(AVG(file_count), 2) as avg_files_per_announcement,
  MAX(file_count) as max_files,
  MIN(file_count) as min_files
FROM (
  SELECT
    announcement_id,
    COUNT(*) as file_count
  FROM benefit_files
  WHERE announcement_id IS NOT NULL
  GROUP BY announcement_id
) subquery;

-- =====================================================
-- PERFORMANCE OPTIMIZATION
-- =====================================================

-- Check index usage
SELECT
  schemaname,
  tablename,
  indexname,
  idx_scan as index_scans,
  idx_tup_read as tuples_read,
  idx_tup_fetch as tuples_fetched
FROM pg_stat_user_indexes
WHERE tablename = 'benefit_files'
ORDER BY idx_scan DESC;

-- Analyze query performance
EXPLAIN ANALYZE
SELECT * FROM v_announcement_files
WHERE announcement_id = '123e4567-e89b-12d3-a456-426614174000';

-- =====================================================
-- END OF SQL REFERENCE
-- =====================================================
