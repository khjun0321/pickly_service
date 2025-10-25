-- =====================================================
-- Add SVG MIME Type Support to Storage Bucket
-- =====================================================
-- This migration adds image/svg+xml to allowed MIME types
-- for the pickly-storage bucket to support SVG icon uploads
-- =====================================================

-- Update bucket to allow SVG files
UPDATE storage.buckets
SET allowed_mime_types = ARRAY[
  'image/jpeg',
  'image/jpg',
  'image/png',
  'image/gif',
  'image/webp',
  'image/svg+xml',  -- ✅ Added for SVG support (icons, graphics)
  'application/pdf',
  'application/msword',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
]
WHERE id = 'pickly-storage';

-- =====================================================
-- MIGRATION COMPLETE
-- =====================================================
-- SVG files (.svg) can now be uploaded to pickly-storage bucket
-- Use case: Age category icons, benefit category icons
-- =====================================================
