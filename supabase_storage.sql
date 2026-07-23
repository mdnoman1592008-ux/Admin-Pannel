-- Supabase Storage RLS Security Policies for Ether Cinema Bucket ('ether-cinema')

-- 1. Enable Public Read Access for CDN Media Assets (Posters, Banners, Avatars)
CREATE POLICY "Public Read CDN Access"
ON storage.objects FOR SELECT
USING ( bucket_id = 'ether-cinema' );

-- 2. Authenticated Admin Upload Access
CREATE POLICY "Admin Upload Media Access"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'ether-cinema' AND
  (auth.jwt() ->> 'role' = 'admin' OR auth.jwt() ->> 'role' = 'super_admin' OR auth.jwt() ->> 'role' = 'editor')
);

-- 3. Admin Delete Objects Access
CREATE POLICY "Admin Delete Objects Access"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'ether-cinema' AND
  (auth.jwt() ->> 'role' = 'admin' OR auth.jwt() ->> 'role' = 'super_admin')
);
