import '../../../calculation/domain/entities/project_dimensions.dart';

class ProjectEntity {
  final String id;
  final String constructoraId;
  final String nombre;
  final ConstructionType tipoConstruccion;
  final double largo;
  final double ancho;
  final double alto;
  final double area;
  final double porcentajeDesperdicio;
  final String? sugerencia;
  final String? aiImagePath;
  final String? aiImageSource;
  final String estado;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProjectEntity({
    required this.id,
    required this.constructoraId,
    required this.nombre,
    required this.tipoConstruccion,
    required this.largo,
    required this.ancho,
    required this.alto,
    required this.area,
    required this.porcentajeDesperdicio,
    this.sugerencia,
    this.aiImagePath,
    this.aiImageSource,
    required this.estado,
    this.createdAt,
    this.updatedAt,
  });
}
