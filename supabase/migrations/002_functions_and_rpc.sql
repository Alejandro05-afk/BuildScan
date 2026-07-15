-- Supabase Functions and RPCs for BuildScan
-- All functions are SECURITY DEFINER to bypass RLS safely, but include internal identity checks.

SET search_path = public;

-- 1. Helper Function: Check if Ferretería can read a specific Proforma
CREATE OR REPLACE FUNCTION auth_can_read_proforma(p_proforma_id UUID)
RETURNS BOOLEAN
SECURITY DEFINER
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM solicitudes_cotizacion sc
    JOIN ferreterias f ON f.id = sc.ferreteria_id
    WHERE sc.proforma_id = p_proforma_id
    AND f.user_id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql;

-- 2. Helper Function: Check if Ferretería can read a specific Proyecto
CREATE OR REPLACE FUNCTION auth_can_read_proyecto(p_proyecto_id UUID)
RETURNS BOOLEAN
SECURITY DEFINER
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM proformas p
    JOIN solicitudes_cotizacion sc ON sc.proforma_id = p.id
    JOIN ferreterias f ON f.id = sc.ferreteria_id
    WHERE p.proyecto_id = p_proyecto_id
    AND f.user_id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql;

-- 3. Atomic RPC: Aceptar Cotización
CREATE OR REPLACE FUNCTION aceptar_cotizacion(p_solicitud_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_proforma_id UUID;
  v_constructora_id UUID;
BEGIN
  -- Obtener la proforma asociada a la solicitud
  SELECT p.id, p.constructora_id
  INTO v_proforma_id, v_constructora_id
  FROM solicitudes_cotizacion sc
  JOIN proformas p ON p.id = sc.proforma_id
  WHERE sc.id = p_solicitud_id;

  -- Validación de propiedad: El usuario que llama debe ser el dueño de la proforma
  IF v_constructora_id != auth.uid() THEN
    RAISE EXCEPTION 'No tienes permiso para aceptar esta cotización.';
  END IF;

  -- Validar que no exista ya una cotización aceptada para esta proforma
  IF EXISTS (
    SELECT 1 FROM solicitudes_cotizacion
    WHERE proforma_id = v_proforma_id
      AND estado = 'aceptada'
  ) THEN
    RAISE EXCEPTION 'Ya existe una cotización aceptada para esta proforma.';
  END IF;

  -- Actualizar atómicamente: Aceptar la solicitada y rechazar el resto
  UPDATE solicitudes_cotizacion
  SET estado = CASE
    WHEN id = p_solicitud_id THEN 'aceptada'
    ELSE 'rechazada'
  END
  WHERE proforma_id = v_proforma_id
    AND estado IN ('cotizada', 'enviada');
END;
$$;

-- Restringir permisos públicos y permitir a autenticados
REVOKE ALL ON FUNCTION aceptar_cotizacion(UUID) FROM public;
GRANT EXECUTE ON FUNCTION aceptar_cotizacion(UUID) TO authenticated;

-- 4. Atomic RPC: Responder Cotización (con inserción de detalles)
CREATE OR REPLACE FUNCTION responder_cotizacion(
  p_solicitud_id UUID,
  p_detalles JSONB
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_ferreteria_user_id UUID;
  v_total DOUBLE PRECISION := 0;
  v_item JSONB;
BEGIN
  -- Validar propiedad: El que responde debe ser el dueño de la ferretería asociada
  SELECT f.user_id INTO v_ferreteria_user_id
  FROM solicitudes_cotizacion sc
  JOIN ferreterias f ON f.id = sc.ferreteria_id
  WHERE sc.id = p_solicitud_id;

  IF v_ferreteria_user_id != auth.uid() THEN
    RAISE EXCEPTION 'No tienes permiso para responder a esta solicitud.';
  END IF;

  -- Validar que la solicitud no esté ya cotizada o rechazada
  IF NOT EXISTS (
    SELECT 1 FROM solicitudes_cotizacion
    WHERE id = p_solicitud_id AND estado = 'enviada'
  ) THEN
    RAISE EXCEPTION 'La solicitud ya fue respondida o cancelada.';
  END IF;

  -- Insertar los detalles
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_detalles)
  LOOP
    INSERT INTO detalles_cotizacion (
      solicitud_id, material_nombre, cantidad, unidad, precio_unitario, subtotal
    ) VALUES (
      p_solicitud_id,
      v_item->>'material_nombre',
      (v_item->>'cantidad')::DOUBLE PRECISION,
      v_item->>'unidad',
      (v_item->>'precio_unitario')::DOUBLE PRECISION,
      (v_item->>'subtotal')::DOUBLE PRECISION
    );

    v_total := v_total + (v_item->>'subtotal')::DOUBLE PRECISION;
  END LOOP;

  -- Actualizar el estado y total de la solicitud
  UPDATE solicitudes_cotizacion
  SET estado = 'cotizada',
      total_cotizado = v_total,
      updated_at = NOW()
  WHERE id = p_solicitud_id;
END;
$$;

REVOKE ALL ON FUNCTION responder_cotizacion(UUID, JSONB) FROM public;
GRANT EXECUTE ON FUNCTION responder_cotizacion(UUID, JSONB) TO authenticated;
