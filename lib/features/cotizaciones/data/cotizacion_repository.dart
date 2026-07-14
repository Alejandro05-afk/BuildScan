import 'package:flutter/foundation.dart';
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

  Future<List<Map<String, dynamic>>> obtenerSolicitudesFerreteria(String ferreteriaId) async {
    final data = await client
        .from('solicitudes_cotizacion')
        .select('*, proformas(*, proyectos(nombre, area_m2, tipo_construccion))')
        .eq('ferreteria_id', ferreteriaId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data as List);
  }

  Future<void> responderCotizacion({
    required String solicitudId,
    required List<Map<String, dynamic>> detalles,
  }) async {
    // 1. Insertar detalle de materiales cotizados
    await client.from('detalle_cotizacion').insert(
      detalles.map((item) => {
        'solicitud_id': solicitudId,
        'material_id': item['material_id'],
        'material_nombre': item['material_nombre'],
        'cantidad': item['cantidad'],
        'unidad': item['unidad'],
        'precio_unitario': item['precio_unitario'],
      }).toList(),
    );

    // 2. Calcular total en cliente para MVP
    final total = detalles.fold<double>(0, (sum, item) {
      return sum + ((item['cantidad'] as num).toDouble() *
          (item['precio_unitario'] as num).toDouble());
    });

    // 3. Actualizar estado de la solicitud
    await client.from('solicitudes_cotizacion').update({
      'estado': 'cotizada',
      'total_cotizado': total,
      'fecha_respuesta': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', solicitudId);
  }

  Future<void> aceptarCotizacion(String solicitudId) async {
    await client.from('solicitudes_cotizacion').update({
      'estado': 'aceptada',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', solicitudId);
  }

  /// 10.1 Suscripción Realtime para nuevas cotizaciones
  RealtimeChannel suscribirseACotizaciones(Function(PostgresChangePayload) onUpdate) {
    final channel = client.channel('cotizaciones-channel');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'solicitudes_cotizacion',
      callback: (payload) {
        // Actualizar lista o mostrar notificación interna en la app
        debugPrint('Cambio en cotización: ${payload.newRecord}');
        onUpdate(payload);
      },
    ).subscribe();
    
    return channel;
  }
}
