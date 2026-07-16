// lib/features/projects/domain/policies/building_type_policy.dart
//
// Central policy for complete building projects.
// Defines which fields are visible, required, their labels, units,
// and validation bounds for each BuildingType.
// All layers (UI, providers, repository, PDF, AI) must consult this file.

/// Fields that may appear in a complete building form.
enum BuildingField {
  bedrooms,
  bathrooms,
  kitchens,
  floors,
  clearHeight,   // Altura libre – for warehouses, offices, commercial
  apartmentsPerFloor,
  parkingSpaces,
  administrativeArea,
  commercialUnits,
  workstations,
  loadingArea,
  hasRoofSlab,
  hasExteriorWalls,
  constructionSystem,
  finishLevel,
  wastePercentage,
}

/// Per-field rule: visibility, requirement, display metadata and clearing.
class BuildingFieldRule {
  final bool visible;
  final bool required;
  /// When the field is hidden and clearWhenHidden is true,
  /// the provider must set the field to null in state.
  final bool clearWhenHidden;
  final String label;
  final String? unit;
  final num? min;
  final num? max;

  const BuildingFieldRule({
    required this.visible,
    this.required = false,
    this.clearWhenHidden = true,
    required this.label,
    this.unit,
    this.min,
    this.max,
  });
}

/// Per-type configuration resolved from [buildingTypePolicy].
class BuildingTypeConfig {
  final Map<BuildingField, BuildingFieldRule> rules;

  const BuildingTypeConfig({required this.rules});

  BuildingFieldRule ruleFor(BuildingField field) =>
      rules[field] ?? BuildingFieldRule(visible: false, label: '');

  bool isVisible(BuildingField field) => ruleFor(field).visible;
  bool isRequired(BuildingField field) => ruleFor(field).required;
  String labelFor(BuildingField field) => ruleFor(field).label;
  String? unitFor(BuildingField field) => ruleFor(field).unit;

  /// Returns visible fields in insertion order.
  Iterable<BuildingField> get visibleFields =>
      rules.entries.where((e) => e.value.visible).map((e) => e.key);

  /// Returns fields that should be set to null when switching to this type.
  Iterable<BuildingField> get fieldsToNull =>
      rules.entries.where((e) => !e.value.visible && e.value.clearWhenHidden).map((e) => e.key);
}

// ---------------------------------------------------------------------------
// Central configuration map
// ---------------------------------------------------------------------------

/// Import this map wherever field behavior is needed.
/// Never hard-code BuildingType conditions in UI or repository.
const Map<String, BuildingTypeConfig> buildingTypePolicy = {
  'house': BuildingTypeConfig(rules: {
    BuildingField.bedrooms: BuildingFieldRule(
      visible: true, required: true, label: 'Dormitorios', min: 1, max: 20),
    BuildingField.bathrooms: BuildingFieldRule(
      visible: true, required: true, label: 'Baños', min: 1, max: 20),
    BuildingField.kitchens: BuildingFieldRule(
      visible: true, required: false, label: 'Cocinas', min: 0, max: 5),
    BuildingField.floors: BuildingFieldRule(
      visible: true, required: true, label: 'Número de Plantas', min: 1, max: 10),
    BuildingField.clearHeight: BuildingFieldRule(
      visible: false, label: 'Altura libre', clearWhenHidden: true),
    BuildingField.apartmentsPerFloor: BuildingFieldRule(
      visible: false, label: 'Departamentos por planta', clearWhenHidden: true),
    BuildingField.parkingSpaces: BuildingFieldRule(
      visible: true, required: false, label: 'Estacionamientos', min: 0, max: 50),
    BuildingField.administrativeArea: BuildingFieldRule(
      visible: false, label: 'Área administrativa', clearWhenHidden: true),
    BuildingField.commercialUnits: BuildingFieldRule(
      visible: false, label: 'Locales comerciales', clearWhenHidden: true),
    BuildingField.workstations: BuildingFieldRule(
      visible: false, label: 'Puestos de trabajo', clearWhenHidden: true),
    BuildingField.loadingArea: BuildingFieldRule(
      visible: false, label: 'Área de carga y descarga', clearWhenHidden: true),
    BuildingField.hasRoofSlab: BuildingFieldRule(visible: true, label: '¿Losa de cubierta?'),
    BuildingField.hasExteriorWalls: BuildingFieldRule(visible: true, label: '¿Paredes exteriores?'),
    BuildingField.constructionSystem: BuildingFieldRule(visible: true, required: true, label: 'Sistema constructivo'),
    BuildingField.finishLevel: BuildingFieldRule(visible: true, required: true, label: 'Nivel de acabados'),
    BuildingField.wastePercentage: BuildingFieldRule(
      visible: true, required: false, label: 'Desperdicio', unit: '%', min: 0, max: 30),
  }),

  'residentialBuilding': BuildingTypeConfig(rules: {
    BuildingField.bedrooms: BuildingFieldRule(
      visible: true, required: true, label: 'Dormitorios por departamento', min: 1, max: 10),
    BuildingField.bathrooms: BuildingFieldRule(
      visible: true, required: true, label: 'Baños por departamento', min: 1, max: 10),
    BuildingField.kitchens: BuildingFieldRule(
      visible: false, label: 'Cocinas', clearWhenHidden: true),
    BuildingField.floors: BuildingFieldRule(
      visible: true, required: true, label: 'Número de Plantas', min: 2, max: 20),
    BuildingField.clearHeight: BuildingFieldRule(
      visible: false, label: 'Altura libre', clearWhenHidden: true),
    BuildingField.apartmentsPerFloor: BuildingFieldRule(
      visible: true, required: true, label: 'Departamentos por planta', min: 1, max: 20),
    BuildingField.parkingSpaces: BuildingFieldRule(
      visible: true, required: false, label: 'Estacionamientos totales', min: 0, max: 200),
    BuildingField.administrativeArea: BuildingFieldRule(
      visible: false, label: 'Área administrativa', clearWhenHidden: true),
    BuildingField.commercialUnits: BuildingFieldRule(
      visible: false, label: 'Locales comerciales', clearWhenHidden: true),
    BuildingField.workstations: BuildingFieldRule(
      visible: false, label: 'Puestos de trabajo', clearWhenHidden: true),
    BuildingField.loadingArea: BuildingFieldRule(
      visible: false, label: 'Área de carga', clearWhenHidden: true),
    BuildingField.hasRoofSlab: BuildingFieldRule(visible: true, label: '¿Losa de cubierta?'),
    BuildingField.hasExteriorWalls: BuildingFieldRule(visible: true, label: '¿Paredes exteriores?'),
    BuildingField.constructionSystem: BuildingFieldRule(visible: true, required: true, label: 'Sistema constructivo'),
    BuildingField.finishLevel: BuildingFieldRule(visible: true, required: true, label: 'Nivel de acabados'),
    BuildingField.wastePercentage: BuildingFieldRule(
      visible: true, required: false, label: 'Desperdicio', unit: '%', min: 0, max: 30),
  }),

  'warehouse': BuildingTypeConfig(rules: {
    BuildingField.bedrooms: BuildingFieldRule(
      visible: false, label: 'Dormitorios', clearWhenHidden: true),
    BuildingField.bathrooms: BuildingFieldRule(
      visible: true, required: true, label: 'Baños', min: 1, max: 10),
    BuildingField.kitchens: BuildingFieldRule(
      visible: false, label: 'Cocinas', clearWhenHidden: true),
    BuildingField.floors: BuildingFieldRule(
      visible: true, required: true, label: 'Niveles', min: 1, max: 5),
    BuildingField.clearHeight: BuildingFieldRule(
      visible: true, required: true, label: 'Altura libre de bodega', unit: 'm', min: 2.5, max: 30),
    BuildingField.apartmentsPerFloor: BuildingFieldRule(
      visible: false, label: 'Departamentos por planta', clearWhenHidden: true),
    BuildingField.parkingSpaces: BuildingFieldRule(
      visible: true, required: false, label: 'Estacionamientos', min: 0, max: 200),
    BuildingField.administrativeArea: BuildingFieldRule(
      visible: true, required: false, label: 'Área administrativa', unit: 'm²', min: 0),
    BuildingField.commercialUnits: BuildingFieldRule(
      visible: false, label: 'Locales comerciales', clearWhenHidden: true),
    BuildingField.workstations: BuildingFieldRule(
      visible: false, label: 'Puestos de trabajo', clearWhenHidden: true),
    BuildingField.loadingArea: BuildingFieldRule(
      visible: true, required: false, label: 'Área de carga y descarga', unit: 'm²', min: 0),
    BuildingField.hasRoofSlab: BuildingFieldRule(visible: true, label: '¿Cubierta?'),
    BuildingField.hasExteriorWalls: BuildingFieldRule(visible: true, label: '¿Cerramiento perimetral?'),
    BuildingField.constructionSystem: BuildingFieldRule(visible: true, required: true, label: 'Sistema constructivo'),
    BuildingField.finishLevel: BuildingFieldRule(visible: true, required: true, label: 'Nivel de acabados'),
    BuildingField.wastePercentage: BuildingFieldRule(
      visible: true, required: false, label: 'Desperdicio', unit: '%', min: 0, max: 30),
  }),

  'commercialSpace': BuildingTypeConfig(rules: {
    BuildingField.bedrooms: BuildingFieldRule(
      visible: false, label: 'Dormitorios', clearWhenHidden: true),
    BuildingField.bathrooms: BuildingFieldRule(
      visible: true, required: true, label: 'Baños', min: 1, max: 10),
    BuildingField.kitchens: BuildingFieldRule(
      visible: false, label: 'Cocinas', clearWhenHidden: true),
    BuildingField.floors: BuildingFieldRule(
      visible: true, required: false, label: 'Niveles del local', min: 1, max: 3),
    BuildingField.clearHeight: BuildingFieldRule(
      visible: true, required: true, label: 'Altura libre', unit: 'm', min: 2.2, max: 12),
    BuildingField.apartmentsPerFloor: BuildingFieldRule(
      visible: false, label: 'Departamentos', clearWhenHidden: true),
    BuildingField.parkingSpaces: BuildingFieldRule(
      visible: true, required: false, label: 'Estacionamientos', min: 0, max: 50),
    BuildingField.administrativeArea: BuildingFieldRule(
      visible: true, required: false, label: 'Área de oficina', unit: 'm²', min: 0),
    BuildingField.commercialUnits: BuildingFieldRule(
      visible: false, label: 'Locales', clearWhenHidden: true),
    BuildingField.workstations: BuildingFieldRule(
      visible: false, label: 'Puestos de trabajo', clearWhenHidden: true),
    BuildingField.loadingArea: BuildingFieldRule(
      visible: true, required: false, label: 'Área de almacenamiento', unit: 'm²', min: 0),
    BuildingField.hasRoofSlab: BuildingFieldRule(visible: true, label: '¿Cubierta?'),
    BuildingField.hasExteriorWalls: BuildingFieldRule(visible: true, label: '¿Cerramiento?'),
    BuildingField.constructionSystem: BuildingFieldRule(visible: true, required: true, label: 'Sistema constructivo'),
    BuildingField.finishLevel: BuildingFieldRule(visible: true, required: true, label: 'Nivel de acabados'),
    BuildingField.wastePercentage: BuildingFieldRule(
      visible: true, required: false, label: 'Desperdicio', unit: '%', min: 0, max: 30),
  }),

  'commercialBuilding': BuildingTypeConfig(rules: {
    BuildingField.bedrooms: BuildingFieldRule(
      visible: false, label: 'Dormitorios', clearWhenHidden: true),
    BuildingField.bathrooms: BuildingFieldRule(
      visible: true, required: true, label: 'Baños por planta', min: 1, max: 20),
    BuildingField.kitchens: BuildingFieldRule(
      visible: false, label: 'Cocinas', clearWhenHidden: true),
    BuildingField.floors: BuildingFieldRule(
      visible: true, required: true, label: 'Número de Plantas', min: 1, max: 30),
    BuildingField.clearHeight: BuildingFieldRule(
      visible: true, required: false, label: 'Altura libre por planta', unit: 'm', min: 2.5),
    BuildingField.apartmentsPerFloor: BuildingFieldRule(
      visible: false, label: 'Departamentos', clearWhenHidden: true),
    BuildingField.parkingSpaces: BuildingFieldRule(
      visible: true, required: false, label: 'Estacionamientos', min: 0, max: 500),
    BuildingField.administrativeArea: BuildingFieldRule(
      visible: false, label: 'Área administrativa', clearWhenHidden: true),
    BuildingField.commercialUnits: BuildingFieldRule(
      visible: true, required: true, label: 'Locales por planta', min: 1, max: 50),
    BuildingField.workstations: BuildingFieldRule(
      visible: false, label: 'Puestos de trabajo', clearWhenHidden: true),
    BuildingField.loadingArea: BuildingFieldRule(
      visible: true, required: false, label: 'Área de carga y descarga', unit: 'm²', min: 0),
    BuildingField.hasRoofSlab: BuildingFieldRule(visible: true, label: '¿Cubierta?'),
    BuildingField.hasExteriorWalls: BuildingFieldRule(visible: true, label: '¿Fachada/Cerramiento?'),
    BuildingField.constructionSystem: BuildingFieldRule(visible: true, required: true, label: 'Sistema constructivo'),
    BuildingField.finishLevel: BuildingFieldRule(visible: true, required: true, label: 'Nivel de acabados'),
    BuildingField.wastePercentage: BuildingFieldRule(
      visible: true, required: false, label: 'Desperdicio', unit: '%', min: 0, max: 30),
  }),

  'office': BuildingTypeConfig(rules: {
    BuildingField.bedrooms: BuildingFieldRule(
      visible: false, label: 'Dormitorios', clearWhenHidden: true),
    BuildingField.bathrooms: BuildingFieldRule(
      visible: true, required: true, label: 'Baños', min: 1, max: 20),
    BuildingField.kitchens: BuildingFieldRule(
      visible: false, label: 'Cocinas', clearWhenHidden: true),
    BuildingField.floors: BuildingFieldRule(
      visible: true, required: true, label: 'Número de Plantas', min: 1, max: 20),
    BuildingField.clearHeight: BuildingFieldRule(
      visible: true, required: false, label: 'Altura libre por planta', unit: 'm', min: 2.4),
    BuildingField.apartmentsPerFloor: BuildingFieldRule(
      visible: false, label: 'Departamentos', clearWhenHidden: true),
    BuildingField.parkingSpaces: BuildingFieldRule(
      visible: true, required: false, label: 'Estacionamientos', min: 0, max: 200),
    BuildingField.administrativeArea: BuildingFieldRule(
      visible: false, label: 'Área administrativa', clearWhenHidden: true),
    BuildingField.commercialUnits: BuildingFieldRule(
      visible: false, label: 'Locales', clearWhenHidden: true),
    BuildingField.workstations: BuildingFieldRule(
      visible: true, required: false, label: 'Puestos de trabajo estimados', min: 1, max: 1000),
    BuildingField.loadingArea: BuildingFieldRule(
      visible: false, label: 'Área de carga', clearWhenHidden: true),
    BuildingField.hasRoofSlab: BuildingFieldRule(visible: true, label: '¿Cubierta?'),
    BuildingField.hasExteriorWalls: BuildingFieldRule(visible: true, label: '¿Fachada?'),
    BuildingField.constructionSystem: BuildingFieldRule(visible: true, required: true, label: 'Sistema constructivo'),
    BuildingField.finishLevel: BuildingFieldRule(visible: true, required: true, label: 'Nivel de acabados'),
    BuildingField.wastePercentage: BuildingFieldRule(
      visible: true, required: false, label: 'Desperdicio', unit: '%', min: 0, max: 30),
  }),

  'custom': BuildingTypeConfig(rules: {
    BuildingField.bedrooms: BuildingFieldRule(
      visible: true, required: false, label: 'Dormitorios', min: 0, max: 50),
    BuildingField.bathrooms: BuildingFieldRule(
      visible: true, required: false, label: 'Baños', min: 0, max: 50),
    BuildingField.kitchens: BuildingFieldRule(
      visible: true, required: false, label: 'Cocinas', min: 0, max: 10),
    BuildingField.floors: BuildingFieldRule(
      visible: true, required: true, label: 'Número de Plantas', min: 1, max: 30),
    BuildingField.clearHeight: BuildingFieldRule(
      visible: true, required: false, label: 'Altura libre', unit: 'm', min: 0),
    BuildingField.apartmentsPerFloor: BuildingFieldRule(
      visible: true, required: false, label: 'Departamentos / Unidades por planta', min: 0),
    BuildingField.parkingSpaces: BuildingFieldRule(
      visible: true, required: false, label: 'Estacionamientos', min: 0, max: 500),
    BuildingField.administrativeArea: BuildingFieldRule(
      visible: true, required: false, label: 'Área administrativa', unit: 'm²', min: 0),
    BuildingField.commercialUnits: BuildingFieldRule(
      visible: true, required: false, label: 'Locales / Unidades comerciales', min: 0),
    BuildingField.workstations: BuildingFieldRule(
      visible: true, required: false, label: 'Puestos de trabajo', min: 0),
    BuildingField.loadingArea: BuildingFieldRule(
      visible: true, required: false, label: 'Área de carga y descarga', unit: 'm²', min: 0),
    BuildingField.hasRoofSlab: BuildingFieldRule(visible: true, label: '¿Cubierta?'),
    BuildingField.hasExteriorWalls: BuildingFieldRule(visible: true, label: '¿Cerramiento?'),
    BuildingField.constructionSystem: BuildingFieldRule(visible: true, required: true, label: 'Sistema constructivo'),
    BuildingField.finishLevel: BuildingFieldRule(visible: true, required: true, label: 'Nivel de acabados'),
    BuildingField.wastePercentage: BuildingFieldRule(
      visible: true, required: false, label: 'Desperdicio', unit: '%', min: 0, max: 30),
  }),
};

/// Convenience accessor – returns config for the given BuildingType string key.
/// Falls back to 'custom' if not found.
BuildingTypeConfig configForType(String buildingTypeKey) {
  return buildingTypePolicy[buildingTypeKey] ?? buildingTypePolicy['custom']!;
}
