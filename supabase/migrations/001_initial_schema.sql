-- Supabase Schema Dump for BuildScan
-- Tables and Unique Constraints

-- 1. ferreterias
CREATE TABLE IF NOT EXISTS public.ferreterias (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    nombre_comercial TEXT NOT NULL,
    ruc TEXT,
    telefono TEXT,
    direccion TEXT,
    latitud DOUBLE PRECISION NOT NULL,
    longitud DOUBLE PRECISION NOT NULL,
    activa BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RESTRICCIÓN OBLIGATORIA: Una sola ferretería por usuario
ALTER TABLE public.ferreterias 
ADD CONSTRAINT ferreterias_user_id_unique UNIQUE (user_id);

-- 2. proyectos
CREATE TABLE IF NOT EXISTS public.proyectos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    constructora_id UUID NOT NULL REFERENCES auth.users(id),
    nombre TEXT NOT NULL,
    descripcion TEXT,
    ubicacion TEXT,
    estado TEXT DEFAULT 'activo',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. proformas
CREATE TABLE IF NOT EXISTS public.proformas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    proyecto_id UUID NOT NULL REFERENCES public.proyectos(id),
    constructora_id UUID NOT NULL REFERENCES auth.users(id),
    nombre TEXT NOT NULL,
    documento_url TEXT,
    estado TEXT DEFAULT 'borrador',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. materiales (items de proforma)
CREATE TABLE IF NOT EXISTS public.materiales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    proforma_id UUID NOT NULL REFERENCES public.proformas(id) ON DELETE CASCADE,
    nombre TEXT NOT NULL,
    cantidad DOUBLE PRECISION NOT NULL,
    unidad TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. solicitudes_cotizacion
CREATE TABLE IF NOT EXISTS public.solicitudes_cotizacion (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    proforma_id UUID NOT NULL REFERENCES public.proformas(id) ON DELETE CASCADE,
    ferreteria_id UUID NOT NULL REFERENCES public.ferreterias(id) ON DELETE CASCADE,
    estado TEXT DEFAULT 'enviada', -- enviada, cotizada, aceptada, rechazada
    total_cotizado DOUBLE PRECISION,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(proforma_id, ferreteria_id) -- Evita duplicados
);

-- 6. detalles_cotizacion (precios de la ferreteria)
CREATE TABLE IF NOT EXISTS public.detalles_cotizacion (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    solicitud_id UUID NOT NULL REFERENCES public.solicitudes_cotizacion(id) ON DELETE CASCADE,
    material_nombre TEXT NOT NULL,
    cantidad DOUBLE PRECISION NOT NULL,
    unidad TEXT NOT NULL,
    precio_unitario DOUBLE PRECISION NOT NULL,
    subtotal DOUBLE PRECISION NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
