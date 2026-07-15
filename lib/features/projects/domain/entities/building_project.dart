import 'dart:convert';

enum ProjectScope {
  constructionElement,
  completeBuilding,
}

enum BuildingType {
  house,
  residentialBuilding,
  commercialBuilding,
  commercialSpace,
  office,
  warehouse,
  custom,
}

enum ConstructionSystem {
  reinforcedConcrete,
  masonry,
  steelStructure,
  mixed,
}

enum FinishLevel {
  basic,
  standard,
  premium,
}

class BuildingProject {
  final String? id;
  final String constructoraId;
  final String name;
  final ProjectScope scope;
  final BuildingType buildingType;
  final double totalArea;
  final int floors;
  final double floorHeight;
  final int bedrooms;
  final int bathrooms;
  final int kitchens;
  final int parkingSpaces;
  final bool hasRoofSlab;
  final bool hasExteriorWalls;
  final ConstructionSystem constructionSystem;
  final FinishLevel finishLevel;
  final double wastePercentage;
  final String? customDescription;

  BuildingProject({
    this.id,
    required this.constructoraId,
    required this.name,
    this.scope = ProjectScope.completeBuilding,
    required this.buildingType,
    required this.totalArea,
    required this.floors,
    required this.floorHeight,
    this.bedrooms = 0,
    this.bathrooms = 0,
    this.kitchens = 0,
    this.parkingSpaces = 0,
    this.hasRoofSlab = true,
    this.hasExteriorWalls = true,
    required this.constructionSystem,
    required this.finishLevel,
    this.wastePercentage = 0.0,
    this.customDescription,
  });

  BuildingProject copyWith({
    String? id,
    String? constructoraId,
    String? name,
    ProjectScope? scope,
    BuildingType? buildingType,
    double? totalArea,
    int? floors,
    double? floorHeight,
    int? bedrooms,
    int? bathrooms,
    int? kitchens,
    int? parkingSpaces,
    bool? hasRoofSlab,
    bool? hasExteriorWalls,
    ConstructionSystem? constructionSystem,
    FinishLevel? finishLevel,
    double? wastePercentage,
    String? customDescription,
  }) {
    return BuildingProject(
      id: id ?? this.id,
      constructoraId: constructoraId ?? this.constructoraId,
      name: name ?? this.name,
      scope: scope ?? this.scope,
      buildingType: buildingType ?? this.buildingType,
      totalArea: totalArea ?? this.totalArea,
      floors: floors ?? this.floors,
      floorHeight: floorHeight ?? this.floorHeight,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      kitchens: kitchens ?? this.kitchens,
      parkingSpaces: parkingSpaces ?? this.parkingSpaces,
      hasRoofSlab: hasRoofSlab ?? this.hasRoofSlab,
      hasExteriorWalls: hasExteriorWalls ?? this.hasExteriorWalls,
      constructionSystem: constructionSystem ?? this.constructionSystem,
      finishLevel: finishLevel ?? this.finishLevel,
      wastePercentage: wastePercentage ?? this.wastePercentage,
      customDescription: customDescription ?? this.customDescription,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null && id!.isNotEmpty) 'id': id,
      'constructora_id': constructoraId,
      'nombre': name,
      'tipo_construccion': 'edificacion_completa', // Needed to satisfy DB NOT NULL constraint
      'project_scope': scope.toString().split('.').last,
      'building_type': buildingType.toString().split('.').last,
      'total_area': totalArea,
      'floors': floors,
      'floor_height': floorHeight,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'kitchens': kitchens,
      'parking_spaces': parkingSpaces,
      'has_roof_slab': hasRoofSlab,
      'has_exterior_walls': hasExteriorWalls,
      'construction_system': constructionSystem.toString().split('.').last,
      'finish_level': finishLevel.toString().split('.').last,
      'waste_percentage': wastePercentage,
      'custom_description': customDescription,
    };
  }

  factory BuildingProject.fromMap(Map<String, dynamic> map) {
    return BuildingProject(
      id: map['id'] as String?,
      constructoraId: map['constructora_id'] as String? ?? '',
      name: map['nombre'] as String? ?? '',
      scope: ProjectScope.values.firstWhere(
        (e) => e.toString().split('.').last == map['project_scope'],
        orElse: () => ProjectScope.completeBuilding,
      ),
      buildingType: BuildingType.values.firstWhere(
        (e) => e.toString().split('.').last == map['building_type'],
        orElse: () => BuildingType.custom,
      ),
      totalArea: (map['total_area'] as num?)?.toDouble() ?? 0.0,
      floors: (map['floors'] as num?)?.toInt() ?? 1,
      floorHeight: (map['floor_height'] as num?)?.toDouble() ?? 2.4,
      bedrooms: (map['bedrooms'] as num?)?.toInt() ?? 0,
      bathrooms: (map['bathrooms'] as num?)?.toInt() ?? 0,
      kitchens: (map['kitchens'] as num?)?.toInt() ?? 0,
      parkingSpaces: (map['parking_spaces'] as num?)?.toInt() ?? 0,
      hasRoofSlab: map['has_roof_slab'] as bool? ?? true,
      hasExteriorWalls: map['has_exterior_walls'] as bool? ?? true,
      constructionSystem: ConstructionSystem.values.firstWhere(
        (e) => e.toString().split('.').last == map['construction_system'],
        orElse: () => ConstructionSystem.reinforcedConcrete,
      ),
      finishLevel: FinishLevel.values.firstWhere(
        (e) => e.toString().split('.').last == map['finish_level'],
        orElse: () => FinishLevel.standard,
      ),
      wastePercentage: (map['waste_percentage'] as num?)?.toDouble() ?? 0.0,
      customDescription: map['custom_description'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory BuildingProject.fromJson(String source) =>
      BuildingProject.fromMap(json.decode(source) as Map<String, dynamic>);

  List<String> validate() {
    final errors = <String>[];
    if (name.trim().isEmpty) {
      errors.add('El nombre del proyecto es obligatorio.');
    }
    if (totalArea <= 0) {
      errors.add('El área debe ser mayor a 0 m².');
    }
    // Max area configurable, but for now we put a reasonable limit like 10,000
    if (totalArea > 10000) {
      errors.add('El área excede el máximo permitido para estimaciones referenciales.');
    }
    if (floors < 1 || floors > 20) {
      errors.add('El número de plantas debe estar entre 1 y 20.');
    }
    if (floorHeight < 2.2 || floorHeight > 6.0) {
      errors.add('La altura por planta debe estar entre 2.2m y 6.0m.');
    }
    if (wastePercentage < 0 || wastePercentage > 30) {
      errors.add('El porcentaje de desperdicio debe estar entre 0% y 30%.');
    }
    if (bedrooms < 0 || bathrooms < 0 || kitchens < 0 || parkingSpaces < 0) {
      errors.add('Las cantidades de espacios no pueden ser negativas.');
    }
    return errors;
  }
}
