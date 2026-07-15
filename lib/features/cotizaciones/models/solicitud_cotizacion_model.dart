class SolicitudCotizacionModel {
  final String id;
  final String proformaId;
  final String ferreteriaId;
  final String estado;
  final double? totalCotizado;
  final DateTime? createdAt;

  const SolicitudCotizacionModel({
    required this.id,
    required this.proformaId,
    required this.ferreteriaId,
    required this.estado,
    this.totalCotizado,
    this.createdAt,
  });

  factory SolicitudCotizacionModel.fromMap(Map<String, dynamic> map) {
    return SolicitudCotizacionModel(
      id: map['id'] as String,
      proformaId: map['proforma_id'] as String,
      ferreteriaId: map['ferreteria_id'] as String,
      estado: map['estado'] as String,
      totalCotizado: map['total_cotizado'] != null ? (map['total_cotizado'] as num).toDouble() : null,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'proforma_id': proformaId,
      'ferreteria_id': ferreteriaId,
      'estado': estado,
      'total_cotizado': totalCotizado,
    };
  }
}
