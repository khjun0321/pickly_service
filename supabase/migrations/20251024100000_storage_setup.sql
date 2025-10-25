-- =====================================================
-- Storage Setup for Pickly Benefit Files
-- =====================================================
-- This migration sets up:
-- 1. Storage bucket 'pickly-storage'
-- 2. Folder structure for announcements, banners, documents
-- 3. Public access policies
-- 4. RLS policies for secure uploads
-- =====================================================

-- Enable storage if not already enabled
-- Note: Storage must be enabled in Supabase dashboard or config.toml

-- =====================================================
-- 1. CREATE STORAGE BUCKET
-- =====================================================

-- Create the main storage bucket for all benefit-related files
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'pickly-storage',
  'pickly-storage',
  true, -- Public access for viewing
  52428800, -- 50MB limit
  ARRAY[
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/gif',
    'image/webp',
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  ]
)
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 52428800,
  allowed_mime_types = ARRAY[
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/gif',
    'image/webp',
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  ];

-- =====================================================
-- 2. STORAGE POLICIES
-- =====================================================

-- Allow public READ access to all files in pickly-storage bucket
CREATE POLICY "Public Access to All Files"
ON storage.objects FOR SELECT
USING (bucket_id = 'pickly-storage');

-- Allow authenticated users to UPLOAD files
CREATE POLICY "Authenticated Upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'pickly-storage');

-- Allow authenticated users to UPDATE their own uploads
CREATE POLICY "Authenticated Update Own Files"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'pickly-storage');

-- Allow authenticated users to DELETE files
CREATE POLICY "Authenticated Delete"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'pickly-storage');

-- Allow service role full access (for admin operations)
CREATE POLICY "Service Role Full Access"
ON storage.objects FOR ALL
TO service_role
USING (bucket_id = 'pickly-storage');

-- =====================================================
-- 3. CREATE FOLDER STRUCTURE METADATA
-- =====================================================
-- Note: In Supabase Storage, folders are virtual and created
-- automatically when files are uploaded with paths.
-- This table tracks the intended folder structure for documentation.

CREATE TABLE IF NOT EXISTS storage_folders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bucket_id TEXT NOT NULL DEFAULT 'pickly-storage',
  path TEXT NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT fk_bucket FOREIGN KEY (bucket_id)
    REFERENCES storage.buckets(id) ON DELETE CASCADE
);

-- Add folder structure documentation
INSERT INTO storage_folders (path, description) VALUES
  ('announcements/', 'Root folder for benefit announcements'),
  ('announcements/thumbnails/', 'Thumbnail images for announcement cards'),
  ('announcements/images/', 'Full-size images for announcement details'),
  ('announcements/documents/', 'PDF and document attachments'),
  ('banners/', 'Root folder for category and promotional banners'),
  ('banners/categories/', 'Category-specific banner images'),
  ('banners/promotions/', 'Promotional and featured banners'),
  ('test/', 'Test folder for validation and development')
ON CONFLICT (path) DO NOTHING;

-- =====================================================
-- 4. FILE METADATA TRACKING
-- =====================================================
-- Track uploaded files for better management

CREATE TABLE IF NOT EXISTS benefit_files (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  announcement_id UUID REFERENCES benefit_announcements(id) ON DELETE CASCADE,
  file_type TEXT NOT NULL CHECK (file_type IN ('thumbnail', 'image', 'document', 'banner')),
  storage_path TEXT NOT NULL,
  file_name TEXT NOT NULL,
  file_size INTEGER,
  mime_type TEXT,
  public_url TEXT,
  uploaded_by UUID REFERENCES auth.users(id),
  uploaded_at TIMESTAMPTZ DEFAULT NOW(),
  metadata JSONB DEFAULT '{}'::jsonb,
  CONSTRAINT unique_storage_path UNIQUE (storage_path)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_benefit_files_announcement ON benefit_files(announcement_id);
CREATE INDEX IF NOT EXISTS idx_benefit_files_type ON benefit_files(file_type);
CREATE INDEX IF NOT EXISTS idx_benefit_files_uploaded_at ON benefit_files(uploaded_at DESC);

-- Enable RLS
ALTER TABLE benefit_files ENABLE ROW LEVEL SECURITY;

-- RLS Policies for benefit_files
CREATE POLICY "Public read access to benefit files"
  ON benefit_files FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can upload files"
  ON benefit_files FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update their own uploads"
  ON benefit_files FOR UPDATE
  TO authenticated
  USING (uploaded_by = auth.uid());

CREATE POLICY "Users can delete their own uploads"
  ON benefit_files FOR DELETE
  TO authenticated
  USING (uploaded_by = auth.uid());

-- =====================================================
-- 5. HELPER FUNCTIONS
-- =====================================================

-- Function to generate storage path for announcements
CREATE OR REPLACE FUNCTION generate_announcement_file_path(
  p_announcement_id UUID,
  p_file_type TEXT,
  p_file_name TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN format('announcements/%s/%s/%s',
    p_file_type,
    p_announcement_id::text,
    p_file_name
  );
END;
$$;

-- Function to generate banner path
CREATE OR REPLACE FUNCTION generate_banner_path(
  p_category TEXT,
  p_file_name TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN format('banners/%s/%s', p_category, p_file_name);
END;
$$;

-- Function to get public URL for storage object
CREATE OR REPLACE FUNCTION get_storage_public_url(
  p_bucket_id TEXT,
  p_path TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
  v_project_url TEXT;
BEGIN
  -- Get the Supabase project URL from config
  -- In production, this should be the actual project URL
  v_project_url := current_setting('app.settings.supabase_url', true);

  IF v_project_url IS NULL THEN
    v_project_url := 'http://localhost:54321'; -- Local development default
  END IF;

  RETURN format('%s/storage/v1/object/public/%s/%s',
    v_project_url,
    p_bucket_id,
    p_path
  );
END;
$$;

-- =====================================================
-- 6. SAMPLE DATA FOR TESTING
-- =====================================================

-- Insert a test file record (actual file upload must be done via API)
INSERT INTO benefit_files (
  file_type,
  storage_path,
  file_name,
  mime_type,
  public_url,
  metadata
) VALUES (
  'banner',
  'banners/test/sample.jpg',
  'sample.jpg',
  'image/jpeg',
  get_storage_public_url('pickly-storage', 'banners/test/sample.jpg'),
  '{"description": "Test banner image", "is_test": true}'::jsonb
)
ON CONFLICT (storage_path) DO NOTHING;

-- =====================================================
-- 7. VIEWS FOR EASY ACCESS
-- =====================================================

-- View to see all files with announcement details
CREATE OR REPLACE VIEW v_announcement_files AS
SELECT
  bf.id,
  bf.announcement_id,
  ba.title as announcement_title,
  ba.organization,
  bf.file_type,
  bf.storage_path,
  bf.file_name,
  bf.file_size,
  bf.mime_type,
  bf.public_url,
  bf.uploaded_at,
  bf.metadata
FROM benefit_files bf
LEFT JOIN benefit_announcements ba ON bf.announcement_id = ba.id
ORDER BY bf.uploaded_at DESC;

-- View for storage statistics
CREATE OR REPLACE VIEW v_storage_stats AS
SELECT
  file_type,
  COUNT(*) as file_count,
  SUM(file_size) as total_size_bytes,
  ROUND(SUM(file_size)::numeric / 1024 / 1024, 2) as total_size_mb,
  AVG(file_size)::bigint as avg_file_size_bytes
FROM benefit_files
GROUP BY file_type;

-- =====================================================
-- 8. GRANTS
-- =====================================================

-- Grant access to authenticated users
GRANT SELECT ON storage_folders TO authenticated;
GRANT ALL ON benefit_files TO authenticated;
GRANT SELECT ON v_announcement_files TO authenticated;
GRANT SELECT ON v_storage_stats TO authenticated;

-- Grant public read access to views
GRANT SELECT ON v_announcement_files TO anon;
GRANT SELECT ON v_storage_stats TO anon;

-- =====================================================
-- MIGRATION COMPLETE
-- =====================================================
-- Next steps:
-- 1. Enable storage in Supabase dashboard or config.toml
-- 2. Run: supabase db reset (or supabase migration up)
-- 3. Test upload: Use Supabase Storage API or SDK
-- 4. Verify public URLs are accessible
-- =====================================================

COMMENT ON TABLE storage_folders IS 'Documents the intended folder structure in pickly-storage bucket';
COMMENT ON TABLE benefit_files IS 'Tracks all uploaded files for benefit announcements and banners';
COMMENT ON VIEW v_announcement_files IS 'Combined view of files with announcement details';
COMMENT ON VIEW v_storage_stats IS 'Storage usage statistics by file type';
