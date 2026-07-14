class FerreteriaModel {
  FerreteriaModel({
    required this.id,
    required this.userId,
    required this.nombreComercial,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    this.telefono,
    this.logoUrl,
    this.destacada = false,
  });

  final String id;
  final String userId;
  final String nombreComercial;
  final String direccion;
  final double latitud;
  final double longitud;
  final String? telefono;
  final String? logoUrl;
  final bool destacada;

  factory FerreteriaModel.fromMap(Map<String, dynamic> map) {
    return FerreteriaModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      nombreComercial: map['nombre_comercial'] as String,
      direccion: map['direccion'] as String,
      latitud: (map['latitud'] as num).toDouble(),
      longitud: (map['longitud'] as num).toDouble(),
      telefono: map['telefono'] as String?,
      logoUrl: map['logo_url'] as String?,
      destacada: map['destacada'] as bool? ?? false,
    );
  }
}
