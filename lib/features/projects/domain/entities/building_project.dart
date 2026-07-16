// lib/features/projects/domain/entities/building_project.dart
//
// Domain entity for complete building projects.
// Uses a sentinel pattern to allow null values in copyWith.
// Does NOT contain Supabase logic – see BuildingProjectModel.

import '../policies/building_type_policy.dart';

export '../policies/building_type_policy.dart'
    show BuildingField, BuildingFieldRule, BuildingTypeConfig, buildingTypePolicy, configForType;

// ─── Enums ────────────────────────────────────────────────────────────────

enum ProjectScope { constructionElement, completeBuilding }

enum BuildingType {
  house,
  residentialBuilding,
  commercialBuilding,
  commercialSpace,
  office,
  warehouse,
  custom,
}

extension BuildingTypeKey on BuildingType {
  /// Stable key used to look up in [buildingTypePolicy] and in Supabase.
  String get policyKey => name; // same as enum name for now
}

enum ConstructionSystem { reinforcedConcrete, masonry, steelStructure, mixed }

enum FinishLevel { basic, standard, premium }

// ─── Sentinel for nullable copyWith ───────────────────────────────────────

class _Unset {
  const _Unset();
}

const _unset = _Unset();

// ─── Entity ───────────────────────────────────────────────────────────────

class BuildingProject {
  final String? id;
  final String constructoraId;
  final String name;
  final ProjectScope scope;
  final BuildingType buildingType;
  final double totalArea;
  final int floors;
  /// Semantic height of an interior room or floor-to-ceiling.
  /// NOT to be confused with clearHeight (warehouse).
  final double floorHeight;

  // Residential
  final int? bedrooms;
  final int? bathrooms;
  final int? kitchens;

  // Residential building
  final int? apartmentsPerFloor;

  // Non-residential
  /// Warehouse / commercial: free height in meters.
  final double? clearHeight;
  /// Optional administrative area (m²) for warehouses.
  final double? administrativeArea;
  /// Commercial building: units per floor.
  final int? commercialUnits;
  /// Office: estimated workstations.
  final int? workstations;
  /// Warehouse: loading dock area (m²).
  final double? loadingArea;

  // Common optional
  final int? parkingSpaces;
  final bool hasRoofSlab;
  final bool hasExteriorWalls;
  final ConstructionSystem constructionSystem;
  final FinishLevel finishLevel;
  final double wastePercentage;
  final String? customDescription;

  const BuildingProject({
    this.id,
    required this.constructoraId,
    required this.name,
    this.scope = ProjectScope.completeBuilding,
    required this.buildingType,
    required this.totalArea,
    this.floors = 1,
    this.floorHeight = 2.6,
    this.bedrooms,
    this.bathrooms,
    this.kitchens,
    this.apartmentsPerFloor,
    this.clearHeight,
    this.administrativeArea,
    this.commercialUnits,
    this.workstations,
    this.loadingArea,
    this.parkingSpaces,
    this.hasRoofSlab = true,
    this.hasExteriorWalls = true,
    required this.constructionSystem,
    required this.finishLevel,
    this.wastePercentage = 0.0,
    this.customDescription,
  });

  // ── Policy helper ────────────────────────────────────────────────────────

  BuildingTypeConfig get policy => configForType(buildingType.policyKey);

  // ── copyWith with sentinel pattern ───────────────────────────────────────

  BuildingProject copyWith({
    String? id,
    String? constructoraId,
    String? name,
    ProjectScope? scope,
    BuildingType? buildingType,
    double? totalArea,
    int? floors,
    double? floorHeight,
    Object? bedrooms = _unset,
    Object? bathrooms = _unset,
    Object? kitchens = _unset,
    Object? apartmentsPerFloor = _unset,
    Object? clearHeight = _unset,
    Object? administrativeArea = _unset,
    Object? commercialUnits = _unset,
    Object? workstations = _unset,
    Object? loadingArea = _unset,
    Object? parkingSpaces = _unset,
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
      bedrooms: identical(bedrooms, _unset) ? this.bedrooms : bedrooms as int?,
      bathrooms: identical(bathrooms, _unset) ? this.bathrooms : bathrooms as int?,
      kitchens: identical(kitchens, _unset) ? this.kitchens : kitchens as int?,
      apartmentsPerFloor: identical(apartmentsPerFloor, _unset)
          ? this.apartmentsPerFloor
          : apartmentsPerFloor as int?,
      clearHeight: identical(clearHeight, _unset) ? this.clearHeight : clearHeight as double?,
      administrativeArea: identical(administrativeArea, _unset)
          ? this.administrativeArea
          : administrativeArea as double?,
      commercialUnits: identical(commercialUnits, _unset)
          ? this.commercialUnits
          : commercialUnits as int?,
      workstations: identical(workstations, _unset) ? this.workstations : workstations as int?,
      loadingArea: identical(loadingArea, _unset) ? this.loadingArea : loadingArea as double?,
      parkingSpaces: identical(parkingSpaces, _unset)
          ? this.parkingSpaces
          : parkingSpaces as int?,
      hasRoofSlab: hasRoofSlab ?? this.hasRoofSlab,
      hasExteriorWalls: hasExteriorWalls ?? this.hasExteriorWalls,
      constructionSystem: constructionSystem ?? this.constructionSystem,
      finishLevel: finishLevel ?? this.finishLevel,
      wastePercentage: wastePercentage ?? this.wastePercentage,
      customDescription: customDescription ?? this.customDescription,
    );
  }

  /// Returns a new project with all fields incompatible with [newType] set to null.
  BuildingProject withType(BuildingType newType) {
    final cfg = configForType(newType.policyKey);
    return copyWith(
      buildingType: newType,
      bedrooms: cfg.isVisible(BuildingField.bedrooms) ? bedrooms : null,
      bathrooms: cfg.isVisible(BuildingField.bathrooms) ? bathrooms : null,
      kitchens: cfg.isVisible(BuildingField.kitchens) ? kitchens : null,
      apartmentsPerFloor:
          cfg.isVisible(BuildingField.apartmentsPerFloor) ? apartmentsPerFloor : null,
      clearHeight: cfg.isVisible(BuildingField.clearHeight) ? clearHeight : null,
      administrativeArea:
          cfg.isVisible(BuildingField.administrativeArea) ? administrativeArea : null,
      commercialUnits: cfg.isVisible(BuildingField.commercialUnits) ? commercialUnits : null,
      workstations: cfg.isVisible(BuildingField.workstations) ? workstations : null,
      loadingArea: cfg.isVisible(BuildingField.loadingArea) ? loadingArea : null,
      parkingSpaces: cfg.isVisible(BuildingField.parkingSpaces) ? parkingSpaces : null,
    );
  }

  // ── Validation ────────────────────────────────────────────────────────────

  List<String> validate() {
    final errors = <String>[];
    if (name.trim().isEmpty) errors.add('El nombre del proyecto es obligatorio.');
    if (totalArea <= 0) errors.add('El área debe ser mayor a 0 m².');
    if (totalArea > 10000) errors.add('El área excede el máximo de 10 000 m².');
    if (wastePercentage < 0 || wastePercentage > 30) {
      errors.add('El desperdicio debe estar entre 0% y 30%.');
    }

    final cfg = policy;

    if (cfg.isRequired(BuildingField.floors)) {
      final min = cfg.ruleFor(BuildingField.floors).min?.toInt() ?? 1;
      final max = cfg.ruleFor(BuildingField.floors).max?.toInt() ?? 30;
      if (floors < min || floors > max) {
        errors.add('El número de plantas debe estar entre $min y $max.');
      }
    }

    if (cfg.isVisible(BuildingField.bedrooms) && cfg.isRequired(BuildingField.bedrooms)) {
      if (bedrooms == null || bedrooms! < 1) {
        errors.add('Ingresa al menos un dormitorio.');
      }
    }

    if (cfg.isVisible(BuildingField.clearHeight) && cfg.isRequired(BuildingField.clearHeight)) {
      final min = cfg.ruleFor(BuildingField.clearHeight).min ?? 2.5;
      if (clearHeight == null || clearHeight! < min) {
        errors.add('Ingresa la altura libre de la bodega (mín. ${min}m).');
      }
    }

    if (cfg.isVisible(BuildingField.apartmentsPerFloor) &&
        cfg.isRequired(BuildingField.apartmentsPerFloor)) {
      if (apartmentsPerFloor == null || apartmentsPerFloor! < 1) {
        errors.add('Ingresa el número de departamentos por planta.');
      }
    }

    if (cfg.isVisible(BuildingField.commercialUnits) &&
        cfg.isRequired(BuildingField.commercialUnits)) {
      if (commercialUnits == null || commercialUnits! < 1) {
        errors.add('Ingresa el número de locales por planta.');
      }
    }

    return errors;
  }
}
