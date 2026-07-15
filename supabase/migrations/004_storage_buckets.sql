-- Storage Buckets Setup for BuildScan
-- Insert buckets into storage.buckets table

INSERT INTO storage.buckets (id, name, public) 
VALUES 
  ('proformas', 'proformas', false),
  ('ai-suggestions', 'ai-suggestions', false),
  ('hardware-store-logos', 'hardware-store-logos', true),
  ('project-images', 'project-images', false)
ON CONFLICT (id) DO NOTHING;

-- RLS for Storage Buckets
-- (Assuming authenticated users can read/write their own objects)

-- 1. proformas (PDFs)
CREATE POLICY "Constructora can upload proformas"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'proformas');

CREATE POLICY "Authenticated users can read proformas"
ON storage.objects FOR SELECT TO authenticated
USING (bucket_id = 'proformas');

-- 2. ai-suggestions (Imágenes generadas por IA)
CREATE POLICY "Authenticated users can read and write AI suggestions"
ON storage.objects FOR ALL TO authenticated
USING (bucket_id = 'ai-suggestions')
WITH CHECK (bucket_id = 'ai-suggestions');

-- 3. hardware-store-logos (Público)
CREATE POLICY "Ferreteria can upload logo"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'hardware-store-logos');

CREATE POLICY "Anyone can read logos"
ON storage.objects FOR SELECT TO public
USING (bucket_id = 'hardware-store-logos');

-- 4. project-images (Imágenes manuales del proyecto)
CREATE POLICY "Constructora can upload project images"
ON storage.objects FOR ALL TO authenticated
USING (bucket_id = 'project-images')
WITH CHECK (bucket_id = 'project-images');
