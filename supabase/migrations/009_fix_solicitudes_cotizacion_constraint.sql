-- Migración correctiva: Fix CHECK constraint en solicitudes_cotizacion
-- El constraint creado manualmente no incluía 'enviada', causando error al insertar solicitudes.

-- 1. Eliminar el constraint incorrecto existente (si existe)
ALTER TABLE public.solicitudes_cotizacion
DROP CONSTRAINT IF EXISTS solicitudes_cotizacion_estado_check;

-- 2. Crear el CHECK constraint correcto con los 4 estados válidos
ALTER TABLE public.solicitudes_cotizacion
ADD CONSTRAINT solicitudes_cotizacion_estado_check
CHECK (estado IN ('enviada', 'cotizada', 'aceptada', 'rechazada'));

-- 3. Agregar columna mensaje si no existe (usada por el código Dart)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'solicitudes_cotizacion' AND column_name = 'mensaje'
  ) THEN
    ALTER TABLE public.solicitudes_cotizacion ADD COLUMN mensaje TEXT;
  END IF;
END $$;
