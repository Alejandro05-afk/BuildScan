class ProfileModel {
  ProfileModel({
    required this.id,
    this.email,
    required this.nombre,
    this.telefono,
    required this.rol,
    this.avatarUrl,
    this.createdAt,
  });

  final String id;
  final String? email;
  final String nombre;
  final String? telefono;
  final String rol; // 'constructora' or 'ferreteria'
  final String? avatarUrl;
  final DateTime? createdAt;

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as String,
      email: map['email'] as String?,
      nombre: map['nombre'] as String,
      telefono: map['telefono'] as String?,
      rol: map['rol'] as String,
      avatarUrl: map['avatar_url'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
    );
  }

  bool get isConstructora => rol == 'constructora';
  bool get isFerreteria => rol == 'ferreteria';
}
