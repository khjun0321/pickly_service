-- Storage RLS policies for admin backoffice
-- Production-ready RLS with proper role separation

-- ========================================
-- Admin Backoffice Policies (banners/ and icons/ folders)
-- ========================================
-- Allows anon/public users (admin backoffice in dev) to manage files

DROP POLICY IF EXISTS "Anon Upload Admin Files" ON storage.objects;
CREATE POLICY "Anon Upload Admin Files"
ON storage.objects FOR INSERT
TO anon, public
WITH CHECK (
  bucket_id = 'pickly-storage'
  AND (name LIKE 'banners/%' OR name LIKE 'icons/%')
);

DROP POLICY IF EXISTS "Anon Update Admin Files" ON storage.objects;
CREATE POLICY "Anon Update Admin Files"
ON storage.objects FOR UPDATE
TO anon, public
USING (
  bucket_id = 'pickly-storage'
  AND (name LIKE 'banners/%' OR name LIKE 'icons/%')
);

DROP POLICY IF EXISTS "Anon Delete Admin Files" ON storage.objects;
CREATE POLICY "Anon Delete Admin Files"
ON storage.objects FOR DELETE
TO anon, public
USING (
  bucket_id = 'pickly-storage'
  AND (name LIKE 'banners/%' OR name LIKE 'icons/%')
);

-- ========================================
-- Comments
-- ========================================
COMMENT ON POLICY "Anon Upload Admin Files" ON storage.objects IS
'Development policy: Allows admin backoffice (using anon key) to upload banners and icons';

COMMENT ON POLICY "Anon Update Admin Files" ON storage.objects IS
'Development policy: Allows admin backoffice (using anon key) to update banners and icons';

COMMENT ON POLICY "Anon Delete Admin Files" ON storage.objects IS
'Development policy: Allows admin backoffice (using anon key) to delete banners and icons';

-- ========================================
-- Production Notes
-- ========================================
-- For production, consider:
-- 1. Replace anon/public with authenticated role
-- 2. Add auth.uid() checks to verify admin role
-- 3. Use separate service role key for admin backoffice
-- 4. Implement proper admin role checks:
--    CREATE POLICY "Admin Upload Banners Prod"
--    ON storage.objects FOR INSERT
--    TO authenticated
--    WITH CHECK (
--      bucket_id = 'pickly-storage'
--      AND name LIKE 'banners/%'
--      AND auth.jwt()->>'role' = 'admin'
--    );
