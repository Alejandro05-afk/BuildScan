-- Migración para añadir campos faltantes a proyectos y proformas

-- 1. Actualizar tabla proyectos
ALTER TABLE public.proyectos 
ADD COLUMN IF NOT EXISTS tipo_construccion TEXT,
ADD COLUMN IF NOT EXISTS largo DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS ancho DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS alto DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS area DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS porcentaje_desperdicio DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS sugerencia TEXT,
ADD COLUMN IF NOT EXISTS ai_image_path TEXT,
ADD COLUMN IF NOT EXISTS ai_image_source TEXT;

-- 2. Actualizar tabla proformas
-- Renombrar documento_url a pdf_path (usamos un bloque DO para evitar errores si ya se renombró)
DO $$
BEGIN
  IF EXISTS(SELECT *
    FROM information_schema.columns
    WHERE table_name='proformas' and column_name='documento_url')
  THEN
      ALTER TABLE public.proformas RENAME COLUMN documento_url TO pdf_path;
  END IF;
END $$;

ALTER TABLE public.proformas
ADD COLUMN IF NOT EXISTS materiales_json JSONB;
