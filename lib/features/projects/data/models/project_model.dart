// lib/features/projects/data/models/project_model.dart
//
// Supabase model for simple element projects.
// Retrocompatible: parses old ConstructionType string values via ElementTypeDb.

import '../../domain/entities/project_entity.dart';

class ProjectModel extends ProjectEntity {
  ProjectModel({
    required super.id,
    required super.constructoraId,
    required super.nombre,
    required super.tipoConstruccion,
    required super.largo,
    required super.ancho,
    super.alto,
    required super.area,
    required super.porcentajeDesperdicio,
    super.sugerencia,
    super.aiImagePath,
    super.aiImageSource,
    required super.estado,
    super.createdAt,
    super.updatedAt,
    super.detallesTecnicos,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    // Retrocompatible parsing of element type
    final elementType = ElementTypeDb.fromDbValue(map['tipo_construccion'] as String?);

    return ProjectModel(
      id: map['id'] as String,
      constructoraId: map['constructora_id'] as String,
      nombre: map['nombre'] as String,
      tipoConstruccion: elementType,
      largo: (map['largo'] as num?)?.toDouble() ?? 0,
      ancho: (map['ancho'] as num?)?.toDouble() ?? 0,
      // alto is now nullable
      alto: (map['alto'] as num?)?.toDouble(),
      area: (map['area'] as num?)?.toDouble() ??
          (map['area_m2'] as num?)?.toDouble() ??
          0,
      porcentajeDesperdicio:
          (map['porcentaje_desperdicio'] as num?)?.toDouble() ?? 0,
      sugerencia: map['sugerencia'] as String?,
      aiImagePath: map['ai_image_path'] as String?,
      aiImageSource: map['ai_image_source'] as String?,
      estado: map['estado'] as String? ?? 'activo',
      createdAt:
          map['created_at'] != null ? DateTime.tryParse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.tryParse(map['updated_at']) : null,
      detallesTecnicos:
          (map['detalles_tecnicos'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'constructora_id': constructoraId,
      'nombre': nombre,
      'tipo_construccion': tipoConstruccion.dbValue,
      'largo': largo,
      'ancho': ancho,
      'alto': alto,  // explicitly null for floors/slabs
      'area': area,
      'area_m2': area,
      'porcentaje_desperdicio': porcentajeDesperdicio,
      'sugerencia': sugerencia,
      'ai_image_path': aiImagePath,
      'ai_image_source': aiImageSource,
      'estado': estado,
      'detalles_tecnicos': detallesTecnicos ?? {},
    };
  }
}
