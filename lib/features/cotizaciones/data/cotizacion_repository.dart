import 'package:supabase_flutter/supabase_flutter.dart';

class CotizacionRepository {
  CotizacionRepository(this.client);
  final SupabaseClient client;

  Future<void> enviarSolicitudAFerreterias({
    required String proformaId,
    required List<String> ferreteriasIds,
    String? mensaje,
  }) async {
    final solicitudes = ferreteriasIds.map((ferreteriaId) {
      return {
        'proforma_id': proformaId,
        'ferreteria_id': ferreteriaId,
        'estado': 'pendiente',
        'mensaje': mensaje,
      };
    }).toList();

    await client.from('solicitudes_cotizacion').insert(solicitudes);
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
    required List<Map<String, dynamic>> detalles, // { material_nombre, cantidad, unidad, precio_unitario }
  }) async {
    double totalCotizado = 0;
    
    final detallesAInsertar = detalles.map((d) {
      final cantidad = d['cantidad'] as num;
      final precio = d['precio_unitario'] as num;
      totalCotizado += cantidad * precio;
      
      return {
        'solicitud_id': solicitudId,
        'material_nombre': d['material_nombre'],
        'cantidad': cantidad,
        'unidad': d['unidad'],
        'precio_unitario': precio,
      };
    }).toList();

    await client.from('detalle_cotizacion').insert(detallesAInsertar);
    
    await client.from('solicitudes_cotizacion').update({
      'estado': 'cotizada',
      'total_cotizado': totalCotizado,
      'fecha_respuesta': DateTime.now().toIso8601String(),
    }).eq('id', solicitudId);
  }

  Future<void> aceptarCotizacion(String solicitudId) async {
    await client.from('solicitudes_cotizacion').update({
      'estado': 'aceptada',
    }).eq('id', solicitudId);
  }

  Future<String> guardarProyectoYProforma({
    required String constructoraId,
    required String nombreProyecto,
    required double area,
    required String tipoConstruccion,
    required List<Map<String, dynamic>> materialesJson,
  }) async {
    // 1. Guardar Proyecto
    final proyectoResult = await client.from('proyectos').insert({
      'constructora_id': constructoraId,
      'nombre': nombreProyecto,
      'area_m2': area,
      'tipo_construccion': tipoConstruccion,
    }).select('id').single();
    
    final proyectoId = proyectoResult['id'];

    // 2. Guardar Proforma
    final proformaResult = await client.from('proformas').insert({
      'proyecto_id': proyectoId,
      'constructora_id': constructoraId,
      'materiales_json': materialesJson,
    }).select('id').single();

    return proformaResult['id'] as String;
  }
}
