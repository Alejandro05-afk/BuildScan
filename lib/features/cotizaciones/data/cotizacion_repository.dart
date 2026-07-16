import 'package:supabase_flutter/supabase_flutter.dart';

class CotizacionRepository {
  CotizacionRepository(this.client);
  final SupabaseClient client;

  Future<void> enviarSolicitudAFerreterias({
    required String proformaId,
    required List<String> ferreteriasIds,
    String? mensaje,
  }) async {
    if (ferreteriasIds.isEmpty) {
      throw Exception('No se seleccionaron ferreterías para enviar la solicitud.');
    }
    // Evitar solicitudes duplicadas
    for (final ferreteriaId in ferreteriasIds) {
      final existentes = await client
          .from('solicitudes_cotizacion')
          .select('id')
          .eq('proforma_id', proformaId)
          .eq('ferreteria_id', ferreteriaId)
          .inFilter('estado', ['enviada', 'cotizada', 'aceptada', 'rechazada'])
          .limit(1);

      if (existentes.isEmpty) {
        await client.from('solicitudes_cotizacion').insert({
          'proforma_id': proformaId,
          'ferreteria_id': ferreteriaId,
          'estado': 'enviada',
          'mensaje': mensaje,
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> obtenerSolicitudesFerreteria(String userId) async {
    // Primero, obtener la ferretería asociada al usuario
    final ferreterias = await client.from('ferreterias').select('id').eq('user_id', userId).limit(1);
    if (ferreterias.isEmpty) return [];

    final ferreteriaId = ferreterias[0]['id'];

    // Obtener las solicitudes de esta ferretería con info de la proforma
    return await client
        .from('solicitudes_cotizacion')
        .select('''
          *,
          proformas (
            materiales_json,
            proyectos (nombre)
          )
        ''')
        .eq('ferreteria_id', ferreteriaId)
        .order('created_at', ascending: false);
  }

  Future<List<Map<String, dynamic>>> obtenerCotizacionesConstructora(String userId) async {
    // Obtener las proformas de esta constructora, luego las solicitudes asociadas
    return await client
        .from('solicitudes_cotizacion')
        .select('''
          *,
          proformas!inner (
            constructora_id,
            proyectos (nombre)
          ),
          ferreterias (nombre_comercial)
        ''')
        .eq('proformas.constructora_id', userId)
        .order('created_at', ascending: false);
  }

  Future<void> responderCotizacion({
    required String solicitudId,
    required List<Map<String, dynamic>> detalles, // { material_nombre, cantidad, unidad, precio_unitario, subtotal }
  }) async {
    // Calcular subtotales antes de enviar
    final detallesProcesados = detalles.map((d) {
      final cantidad = d['cantidad'] as num;
      final precio = d['precio_unitario'] as num;
      return {
        'material_nombre': d['material_nombre'],
        'cantidad': cantidad,
        'unidad': d['unidad'],
        'precio_unitario': precio,
        'subtotal': cantidad * precio,
      };
    }).toList();

    await client.rpc(
      'responder_cotizacion',
      params: {
        'p_solicitud_id': solicitudId,
        'p_detalles': detallesProcesados,
      },
    );
  }

  Future<void> aceptarCotizacion(String solicitudId, String proformaId) async {
    await client.rpc(
      'aceptar_cotizacion',
      params: {
        'p_solicitud_id': solicitudId,
      },
    );
  }

  Future<void> rechazarCotizacion(String solicitudId) async {
    await client.from('solicitudes_cotizacion').update({
      'estado': 'rechazada',
    }).eq('id', solicitudId);
  }

  Future<String> crearProforma({
    required String proyectoId,
    required String constructoraId,
    required String nombre,
    required List<Map<String, dynamic>> materialesJson,
  }) async {
    final proformaResult = await client.from('proformas').insert({
      'proyecto_id': proyectoId,
      'constructora_id': constructoraId,
      'nombre': nombre,
      'materiales_json': materialesJson,
    }).select('id').single();

    return proformaResult['id'] as String;
  }

  Future<void> updateProformaPdfPath(String proformaId, String pdfPath) async {
    await client.from('proformas').update({
      'pdf_path': pdfPath,
    }).eq('id', proformaId);
  }
}
