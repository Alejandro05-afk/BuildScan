class DetalleCotizacionModel {
  final String id;
  final String solicitudId;
  final String materialNombre;
  final double cantidad;
  final String unidad;
  final double precioUnitario;
  final double subtotal;

  const DetalleCotizacionModel({
    required this.id,
    required this.solicitudId,
    required this.materialNombre,
    required this.cantidad,
    required this.unidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory DetalleCotizacionModel.fromMap(Map<String, dynamic> map) {
    return DetalleCotizacionModel(
      id: map['id'] as String,
      solicitudId: map['solicitud_id'] as String,
      materialNombre: map['material_nombre'] as String,
      cantidad: (map['cantidad'] as num).toDouble(),
      unidad: map['unidad'] as String,
      precioUnitario: (map['precio_unitario'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'solicitud_id': solicitudId,
      'material_nombre': materialNombre,
      'cantidad': cantidad,
      'unidad': unidad,
      'precio_unitario': precioUnitario,
      'subtotal': subtotal,
    };
  }
}
