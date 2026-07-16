// lib/features/projects/domain/entities/project_entity.dart
//
// Domain entity for simple construction element projects.
// Uses the new ElementType (retrocompatible with old ConstructionType values).

import '../../../calculation/domain/entities/project_dimensions.dart';

export '../../../projects/domain/policies/element_type_policy.dart' show ElementType, ElementTypeDb, ElementTypeConfig, configForElementType, ElementField;

class ProjectEntity {
  final String id;
  final String constructoraId;
  final String nombre;
  final ElementType tipoConstruccion;
  final double largo;
  final double ancho;
  /// Semantic height: wall height for walls, room height for rooms. Null for floors/slabs.
  final double? alto;
  final double area;
  final double porcentajeDesperdicio;
  final String? sugerencia;
  final String? aiImagePath;
  final String? aiImageSource;
  final String estado;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  /// Variable technical fields stored in jsonb column `detalles_tecnicos`.
  final Map<String, dynamic>? detallesTecnicos;

  ProjectEntity({
    required this.id,
    required this.constructoraId,
    required this.nombre,
    required this.tipoConstruccion,
    required this.largo,
    required this.ancho,
    this.alto,
    required this.area,
    required this.porcentajeDesperdicio,
    this.sugerencia,
    this.aiImagePath,
    this.aiImageSource,
    required this.estado,
    this.createdAt,
    this.updatedAt,
    this.detallesTecnicos,
  });
}
