-- RLS Policies for BuildScan

ALTER TABLE public.ferreterias ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.proyectos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.proformas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.solicitudes_cotizacion ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.detalles_cotizacion ENABLE ROW LEVEL SECURITY;

-- Ferreterias
DROP POLICY IF EXISTS "ferreterias_select_all" ON public.ferreterias;
CREATE POLICY "ferreterias_select_all" ON public.ferreterias
FOR SELECT TO authenticated USING (activa = true OR user_id = auth.uid());

DROP POLICY IF EXISTS "ferreterias_insert_own" ON public.ferreterias;
CREATE POLICY "ferreterias_insert_own" ON public.ferreterias
FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "ferreterias_update_own" ON public.ferreterias;
CREATE POLICY "ferreterias_update_own" ON public.ferreterias
FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- Proyectos
DROP POLICY IF EXISTS "proyectos_all_constructora" ON public.proyectos;
CREATE POLICY "proyectos_all_constructora" ON public.proyectos
FOR ALL TO authenticated USING (constructora_id = auth.uid()) WITH CHECK (constructora_id = auth.uid());

DROP POLICY IF EXISTS "proyectos_read_ferreteria" ON public.proyectos;
CREATE POLICY "proyectos_read_ferreteria" ON public.proyectos
FOR SELECT TO authenticated USING (auth_can_read_proyecto(id));

-- Proformas
DROP POLICY IF EXISTS "proformas_all_constructora" ON public.proformas;
CREATE POLICY "proformas_all_constructora" ON public.proformas
FOR ALL TO authenticated USING (constructora_id = auth.uid()) WITH CHECK (constructora_id = auth.uid());

DROP POLICY IF EXISTS "proformas_read_ferreteria" ON public.proformas;
CREATE POLICY "proformas_read_ferreteria" ON public.proformas
FOR SELECT TO authenticated USING (auth_can_read_proforma(id));

-- Solicitudes
DROP POLICY IF EXISTS "solicitudes_select_participants" ON public.solicitudes_cotizacion;
CREATE POLICY "solicitudes_select_participants" ON public.solicitudes_cotizacion
FOR SELECT TO authenticated
USING (
  EXISTS (SELECT 1 FROM public.ferreterias WHERE id = ferreteria_id AND user_id = auth.uid())
  OR EXISTS (SELECT 1 FROM public.proformas WHERE id = proforma_id AND constructora_id = auth.uid())
);

DROP POLICY IF EXISTS "solicitudes_insert_constructora" ON public.solicitudes_cotizacion;
CREATE POLICY "solicitudes_insert_constructora" ON public.solicitudes_cotizacion
FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (SELECT 1 FROM public.proformas WHERE id = proforma_id AND constructora_id = auth.uid())
);

DROP POLICY IF EXISTS "solicitudes_update_participants" ON public.solicitudes_cotizacion;
CREATE POLICY "solicitudes_update_participants" ON public.solicitudes_cotizacion
FOR UPDATE TO authenticated
USING (
  EXISTS (SELECT 1 FROM public.ferreterias WHERE id = ferreteria_id AND user_id = auth.uid())
  OR EXISTS (SELECT 1 FROM public.proformas WHERE id = proforma_id AND constructora_id = auth.uid())
)
WITH CHECK (
  EXISTS (SELECT 1 FROM public.ferreterias WHERE id = ferreteria_id AND user_id = auth.uid())
  OR EXISTS (SELECT 1 FROM public.proformas WHERE id = proforma_id AND constructora_id = auth.uid())
);

-- Detalles Cotizacion
DROP POLICY IF EXISTS "detalles_select_participants" ON public.detalles_cotizacion;
CREATE POLICY "detalles_select_participants" ON public.detalles_cotizacion
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.solicitudes_cotizacion sc
    JOIN public.ferreterias f ON f.id = sc.ferreteria_id
    WHERE sc.id = solicitud_id AND f.user_id = auth.uid()
  )
  OR EXISTS (
    SELECT 1 FROM public.solicitudes_cotizacion sc
    JOIN public.proformas p ON p.id = sc.proforma_id
    WHERE sc.id = solicitud_id AND p.constructora_id = auth.uid()
  )
);
