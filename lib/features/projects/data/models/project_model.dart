import '../../domain/entities/project_entity.dart';
import '../../../calculation/domain/entities/project_dimensions.dart';

class ProjectModel extends ProjectEntity {
  ProjectModel({
    required super.id,
    required super.constructoraId,
    required super.nombre,
    required super.tipoConstruccion,
    required super.largo,
    required super.ancho,
    required super.alto,
    required super.area,
    required super.porcentajeDesperdicio,
    super.sugerencia,
    super.aiImagePath,
    super.aiImageSource,
    required super.estado,
    super.createdAt,
    super.updatedAt,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] as String,
      constructoraId: map['constructora_id'] as String,
      nombre: map['nombre'] as String,
      tipoConstruccion: _parseType(map['tipo_construccion'] as String?),
      largo: (map['largo'] as num?)?.toDouble() ?? 0,
      ancho: (map['ancho'] as num?)?.toDouble() ?? 0,
      alto: (map['alto'] as num?)?.toDouble() ?? 0,
      area: (map['area'] as num?)?.toDouble() ?? 0,
      porcentajeDesperdicio: (map['porcentaje_desperdicio'] as num?)?.toDouble() ?? 0,
      sugerencia: map['sugerencia'] as String?,
      aiImagePath: map['ai_image_path'] as String?,
      aiImageSource: map['ai_image_source'] as String?,
      estado: map['estado'] as String? ?? 'activo',
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'constructora_id': constructoraId,
      'nombre': nombre,
      'tipo_construccion': tipoConstruccion.name,
      'largo': largo,
      'ancho': ancho,
      'alto': alto,
      'area': area,
      'porcentaje_desperdicio': porcentajeDesperdicio,
      'sugerencia': sugerencia,
      'ai_image_path': aiImagePath,
      'ai_image_source': aiImageSource,
      'estado': estado,
    };
  }

  static ConstructionType _parseType(String? typeStr) {
    if (typeStr == null) return ConstructionType.paredLadrillo;
    return ConstructionType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => ConstructionType.paredLadrillo,
    );
  }
}
