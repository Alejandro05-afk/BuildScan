// lib/features/projects/data/models/building_project_model.dart
//
// Separates Supabase serialization from the domain entity.
// toInsertMap() / toUpdateMap() use the policy to emit null for incompatible fields.

import '../../domain/entities/building_project.dart';

class BuildingProjectMapper {
  // ── Entity → Model (for DB writes) ────────────────────────────────────────

  static Map<String, dynamic> toInsertMap(BuildingProject p) {
    final cfg = configForType(p.buildingType.policyKey);
    return {
      'constructora_id': p.constructoraId,
      'nombre': p.name,
      // Legacy columns required by DB NOT NULL constraints:
      'tipo_construccion': 'edificacion_completa',
      'area_m2': p.totalArea,
      'area': p.totalArea,
      'largo': 0.0,
      'ancho': 0.0,
      'alto': 0.0,
      // Semantic columns:
      'project_scope': p.scope.name,
      'building_type': p.buildingType.name,
      'total_area': p.totalArea,
      'floors': p.floors,
      'floor_height': p.floorHeight,
      'construction_system': p.constructionSystem.name,
      'finish_level': p.finishLevel.name,
      'waste_percentage': p.wastePercentage,
      'has_roof_slab': p.hasRoofSlab,
      'has_exterior_walls': p.hasExteriorWalls,
      'custom_description': p.customDescription,
      // Conditional fields – always present, set to null when incompatible:
      'bedrooms': cfg.isVisible(BuildingField.bedrooms) ? p.bedrooms : null,
      'bathrooms': cfg.isVisible(BuildingField.bathrooms) ? p.bathrooms : null,
      'kitchens': cfg.isVisible(BuildingField.kitchens) ? p.kitchens : null,
      'apartments_per_floor':
          cfg.isVisible(BuildingField.apartmentsPerFloor) ? p.apartmentsPerFloor : null,
      'clear_height': cfg.isVisible(BuildingField.clearHeight) ? p.clearHeight : null,
      'administrative_area':
          cfg.isVisible(BuildingField.administrativeArea) ? p.administrativeArea : null,
      'commercial_units': cfg.isVisible(BuildingField.commercialUnits) ? p.commercialUnits : null,
      'workstations': cfg.isVisible(BuildingField.workstations) ? p.workstations : null,
      'loading_area': cfg.isVisible(BuildingField.loadingArea) ? p.loadingArea : null,
      'parking_spaces': cfg.isVisible(BuildingField.parkingSpaces) ? p.parkingSpaces : null,
    };
  }

  /// For UPDATE – sends explicit null for incompatible fields to overwrite stale DB values.
  static Map<String, dynamic> toUpdateMap(BuildingProject p) {
    final map = toInsertMap(p);
    map.remove('id'); // never update PK
    return map;
  }

  // ── DB row → Entity ─────────────────────────────────────────────────────

  static BuildingProject fromMap(Map<String, dynamic> map) {
    final buildingType = _parseBuildingType(map['building_type'] as String?);
    final cfg = configForType(buildingType.policyKey);

    return BuildingProject(
      id: map['id'] as String?,
      constructoraId: map['constructora_id'] as String? ?? '',
      name: map['nombre'] as String? ?? '',
      scope: _parseScope(map['project_scope'] as String?),
      buildingType: buildingType,
      totalArea: (map['total_area'] as num?)?.toDouble() ??
          (map['area_m2'] as num?)?.toDouble() ??
          0.0,
      floors: (map['floors'] as num?)?.toInt() ?? 1,
      floorHeight: (map['floor_height'] as num?)?.toDouble() ?? 2.6,
      constructionSystem: _parseConstructionSystem(map['construction_system'] as String?),
      finishLevel: _parseFinishLevel(map['finish_level'] as String?),
      wastePercentage: (map['waste_percentage'] as num?)?.toDouble() ?? 0.0,
      hasRoofSlab: map['has_roof_slab'] as bool? ?? true,
      hasExteriorWalls: map['has_exterior_walls'] as bool? ?? true,
      customDescription: map['custom_description'] as String?,
      // Conditional – only assign if the policy allows it for this type:
      bedrooms: cfg.isVisible(BuildingField.bedrooms)
          ? (map['bedrooms'] as num?)?.toInt()
          : null,
      bathrooms: cfg.isVisible(BuildingField.bathrooms)
          ? (map['bathrooms'] as num?)?.toInt()
          : null,
      kitchens: cfg.isVisible(BuildingField.kitchens)
          ? (map['kitchens'] as num?)?.toInt()
          : null,
      apartmentsPerFloor: cfg.isVisible(BuildingField.apartmentsPerFloor)
          ? (map['apartments_per_floor'] as num?)?.toInt()
          : null,
      clearHeight: cfg.isVisible(BuildingField.clearHeight)
          ? (map['clear_height'] as num?)?.toDouble()
          : null,
      administrativeArea: cfg.isVisible(BuildingField.administrativeArea)
          ? (map['administrative_area'] as num?)?.toDouble()
          : null,
      commercialUnits: cfg.isVisible(BuildingField.commercialUnits)
          ? (map['commercial_units'] as num?)?.toInt()
          : null,
      workstations: cfg.isVisible(BuildingField.workstations)
          ? (map['workstations'] as num?)?.toInt()
          : null,
      loadingArea: cfg.isVisible(BuildingField.loadingArea)
          ? (map['loading_area'] as num?)?.toDouble()
          : null,
      parkingSpaces: cfg.isVisible(BuildingField.parkingSpaces)
          ? (map['parking_spaces'] as num?)?.toInt()
          : null,
    );
  }

  // ── Private parsers ────────────────────────────────────────────────────────

  static BuildingType _parseBuildingType(String? value) {
    if (value == null) return BuildingType.custom;
    return BuildingType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BuildingType.custom,
    );
  }

  static ProjectScope _parseScope(String? value) {
    return ProjectScope.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ProjectScope.completeBuilding,
    );
  }

  static ConstructionSystem _parseConstructionSystem(String? value) {
    return ConstructionSystem.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ConstructionSystem.reinforcedConcrete,
    );
  }

  static FinishLevel _parseFinishLevel(String? value) {
    return FinishLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FinishLevel.standard,
    );
  }
}
