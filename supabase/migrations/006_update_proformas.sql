-- 006_update_proformas.sql
-- Add missing columns to proformas table if they don't exist
-- and notify PostgREST to reload the schema cache

ALTER TABLE public.proformas
ADD COLUMN IF NOT EXISTS nombre TEXT,
ADD COLUMN IF NOT EXISTS materiales_json JSONB,
ADD COLUMN IF NOT EXISTS pdf_path TEXT;

-- Reload Supabase Schema Cache
NOTIFY pgrst, 'reload schema';
