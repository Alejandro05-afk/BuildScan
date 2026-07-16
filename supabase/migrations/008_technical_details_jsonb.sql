-- Migration 008: Add technical details JSONB column and new building fields
-- This migration is ADDITIVE. No columns are dropped or renamed.
-- Old data remains accessible and compatible.

-- 1. Add detalles_tecnicos jsonb column for variable element fields
--    (espesor, puertas, ventanas, tipo bloque, dimensiones cerámica, etc.)
alter table public.proyectos
  add column if not exists detalles_tecnicos jsonb not null default '{}'::jsonb;

-- Ensure it's always a JSON object
alter table public.proyectos
  drop constraint if exists proyectos_detalles_tecnicos_es_objeto;
alter table public.proyectos
  add constraint proyectos_detalles_tecnicos_es_objeto
    check (jsonb_typeof(detalles_tecnicos) = 'object');

-- 2. Add new building-type-specific columns for complete building projects
--    All are nullable since they only apply to certain building types.

alter table public.proyectos
  add column if not exists apartments_per_floor integer;

alter table public.proyectos
  add column if not exists clear_height numeric(6,2);   -- Altura libre (bodegas, locales)

alter table public.proyectos
  add column if not exists administrative_area numeric(10,2); -- Área administrativa (m²)

alter table public.proyectos
  add column if not exists commercial_units integer;    -- Locales por planta

alter table public.proyectos
  add column if not exists workstations integer;        -- Puestos de trabajo

alter table public.proyectos
  add column if not exists loading_area numeric(10,2);  -- Área de carga y descarga (m²)

-- 3. Basic range constraints (application-level validation is primary)
--    Only add if they don't already exist.

alter table public.proyectos
  drop constraint if exists proyectos_porcentaje_desperdicio_valido;
alter table public.proyectos
  add constraint proyectos_porcentaje_desperdicio_valido
    check (porcentaje_desperdicio is null or porcentaje_desperdicio between 0 and 30);

alter table public.proyectos
  drop constraint if exists proyectos_apartments_per_floor_valido;
alter table public.proyectos
  add constraint proyectos_apartments_per_floor_valido
    check (apartments_per_floor is null or apartments_per_floor >= 1);

alter table public.proyectos
  drop constraint if exists proyectos_clear_height_valido;
alter table public.proyectos
  add constraint proyectos_clear_height_valido
    check (clear_height is null or clear_height >= 0);

-- 4. Initialize detalles_tecnicos for existing rows that have null
update public.proyectos
  set detalles_tecnicos = '{}'::jsonb
  where detalles_tecnicos is null;
