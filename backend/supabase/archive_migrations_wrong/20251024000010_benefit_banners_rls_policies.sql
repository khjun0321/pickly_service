-- Enable RLS on benefit_banners table
ALTER TABLE benefit_banners ENABLE ROW LEVEL SECURITY;

-- Allow all operations for authenticated users (admin panel)
CREATE POLICY "Enable all operations for authenticated users"
ON benefit_banners
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Allow read access for anon users (mobile app)
CREATE POLICY "Enable read access for anon users"
ON benefit_banners
FOR SELECT
TO anon
USING (is_active = true);
