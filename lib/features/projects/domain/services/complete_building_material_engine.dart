// lib/features/projects/domain/services/complete_building_material_engine.dart
//
// Strategy pattern implementation for complete building material estimation.
// Each BuildingType has a dedicated strategy with type-appropriate calculations.

import 'dart:math';
import '../../../../core/constants/building_coefficients.dart';
import '../entities/building_project.dart';
import '../entities/building_calculation_result.dart';

// ─── Strategy interface ───────────────────────────────────────────────────────

abstract interface class BuildingMaterialStrategy {
  BuildingCalculationResult calculate(BuildingProject project);
}

// ─── Engine ──────────────────────────────────────────────────────────────────

class CompleteBuildingMaterialEngine {
  static final Map<BuildingType, BuildingMaterialStrategy> _strategies = {
    BuildingType.house: _HouseStrategy(),
    BuildingType.residentialBuilding: _ResidentialBuildingStrategy(),
    BuildingType.warehouse: _WarehouseStrategy(),
    BuildingType.commercialSpace: _CommercialSpaceStrategy(),
    BuildingType.commercialBuilding: _CommercialBuildingStrategy(),
    BuildingType.office: _OfficeStrategy(),
    BuildingType.custom: _CustomStrategy(),
  };

  BuildingCalculationResult calculateMaterials(BuildingProject project) {
    final strategy = _strategies[project.buildingType];
    if (strategy == null) {
      throw UnsupportedError(
          'No existe una estrategia de cálculo para ${project.buildingType}');
    }
    return strategy.calculate(project);
  }
}

// ─── Shared helpers ──────────────────────────────────────────────────────────

double _applyWaste(double quantity, double wastePercentage) =>
    quantity * (1 + wastePercentage / 100);

/// Estimates perimeter of a square building with the given area.
double _estimatedPerimeter(double areaPerFloor) {
  final side = sqrt(areaPerFloor);
  return 4 * side;
}

MaterialEstimate _cement(double qty, String category, String criteria) =>
    MaterialEstimate(
      materialName: 'Cemento',
      quantity: qty,
      unit: 'sacos',
      category: category,
      criteria: criteria,
    );

MaterialEstimate _blocks(double qty, String category) => MaterialEstimate(
      materialName: 'Bloques / Ladrillos',
      quantity: qty,
      unit: 'unidades',
      category: category,
      criteria: 'Dimensiones estándar 20×40 cm',
    );

MaterialEstimate _steel(double qty, bool structural) => MaterialEstimate(
      materialName: structural ? 'Acero de refuerzo' : 'Acero estructural',
      quantity: qty,
      unit: 'kg',
      category: 'Obra Gris',
      criteria: structural
          ? 'Estimación referencial para columnas, vigas y losas'
          : 'Perfilería estructural',
      isStructural: true,
    );

// ─── House strategy ───────────────────────────────────────────────────────────

class _HouseStrategy implements BuildingMaterialStrategy {
  @override
  BuildingCalculationResult calculate(BuildingProject p) {
    final materials = <MaterialEstimate>[];
    final assumptions = <String>[];
    final warnings = <String>[];

    final areaPerFloor = p.totalArea / p.floors;
    final perimeter = _estimatedPerimeter(areaPerFloor);
    final wallHeight = p.floorHeight;
    final exteriorWallArea = perimeter * wallHeight * p.floors;
    final totalWallArea = exteriorWallArea * BuildingCoefficients.houseInternalWallFactor;
    final roofArea = areaPerFloor;

    assumptions.add('Sistema constructivo: hormigón armado / mampostería');
    assumptions.add('Paredes interiores estimadas con factor ${BuildingCoefficients.houseInternalWallFactor}');
    if (p.bedrooms != null) assumptions.add('Dormitorios: ${p.bedrooms}');
    if (p.bathrooms != null) assumptions.add('Baños: ${p.bathrooms}');
    warnings.add('Cantidades referenciales. Requieren planos y cálculo estructural.');

    final w = (double q) => _applyWaste(q, p.wastePercentage);

    // Estructura
    materials.add(_cement(w(roofArea * 0.25 * BuildingCoefficients.cementoPorM2Hormigon),
        'Estructura', 'Vigas, columnas y losas (referencial)'));
    materials.add(_steel(w(roofArea * BuildingCoefficients.aceroPorM2Hormigon), true));

    // Mampostería
    materials.add(_blocks(w(totalWallArea * BuildingCoefficients.bloquesPorM2Pared), 'Mampostería'));
    materials.add(_cement(w(totalWallArea * BuildingCoefficients.cementoPorM2Mamposteria),
        'Mampostería', 'Mortero de asiente y enlucido'));

    // Pisos
    materials.add(MaterialEstimate(
      materialName: 'Cerámica / Porcelanato',
      quantity: w(p.totalArea * BuildingCoefficients.ceramicaPorM2Piso),
      unit: 'm²',
      category: 'Pisos',
      criteria: 'Área total + zócalos referenciales',
    ));

    // Acabados
    materials.add(MaterialEstimate(
      materialName: 'Pintura',
      quantity: w(totalWallArea * BuildingCoefficients.pinturaPorM2Pared),
      unit: 'galones',
      category: 'Acabados',
      criteria: '2 manos sobre paredes y cielorraso',
    ));

    return BuildingCalculationResult(
      materials: materials,
      assumptions: assumptions,
      warnings: warnings,
      estimatedWallArea: totalWallArea,
      estimatedFloorArea: p.totalArea,
      estimatedRoofArea: roofArea,
    );
  }
}

// ─── Residential building strategy ───────────────────────────────────────────

class _ResidentialBuildingStrategy implements BuildingMaterialStrategy {
  @override
  BuildingCalculationResult calculate(BuildingProject p) {
    final materials = <MaterialEstimate>[];
    final assumptions = <String>[];
    final warnings = <String>[];

    final totalDepts = (p.apartmentsPerFloor ?? 4) * p.floors;
    final areaPerFloor = p.totalArea / p.floors;
    final perimeter = _estimatedPerimeter(areaPerFloor);
    final totalWallArea =
        perimeter * p.floorHeight * p.floors * BuildingCoefficients.residentialBuildingWallFactor;

    assumptions.add('Departamentos totales: $totalDepts');
    if (p.bedrooms != null) assumptions.add('Dormitorios por dpto: ${p.bedrooms}');
    warnings.add('Edificio residencial: requiere cálculo estructural certificado.');

    final w = (double q) => _applyWaste(q, p.wastePercentage);

    materials.add(_cement(w(areaPerFloor * 0.65), 'Estructura', 'Losas y estructura por piso'));
    materials.add(_steel(w(p.totalArea * 8), true));
    materials.add(_blocks(w(totalWallArea * BuildingCoefficients.bloquesPorM2Pared), 'Mampostería'));
    materials.add(_cement(w(totalWallArea * BuildingCoefficients.cementoPorM2Mamposteria),
        'Mampostería', 'Asiente y enlucido'));
    materials.add(MaterialEstimate(
      materialName: 'Cerámica / Porcelanato',
      quantity: w(p.totalArea * BuildingCoefficients.ceramicaPorM2Piso),
      unit: 'm²',
      category: 'Pisos',
      criteria: 'Área total construida',
    ));

    return BuildingCalculationResult(
      materials: materials,
      assumptions: assumptions,
      warnings: warnings,
      estimatedWallArea: totalWallArea,
      estimatedFloorArea: p.totalArea,
      estimatedRoofArea: areaPerFloor,
    );
  }
}

// ─── Warehouse strategy ───────────────────────────────────────────────────────

class _WarehouseStrategy implements BuildingMaterialStrategy {
  @override
  BuildingCalculationResult calculate(BuildingProject p) {
    final materials = <MaterialEstimate>[];
    final assumptions = <String>[];
    final warnings = <String>[];

    final clearH = p.clearHeight ?? 6.0;
    final areaPerFloor = p.totalArea / p.floors;
    final perimeter = _estimatedPerimeter(areaPerFloor);
    // Bodegas: muros de cerramiento, no paredes de mampostería residencial
    final wallArea = perimeter * clearH * p.floors *
        BuildingCoefficients.warehouseWallFactor;

    assumptions.add('Altura libre: ${clearH.toStringAsFixed(1)} m');
    if (p.administrativeArea != null) {
      assumptions.add('Área administrativa: ${p.administrativeArea} m²');
    }
    if (p.loadingArea != null) {
      assumptions.add('Área de carga y descarga: ${p.loadingArea} m²');
    }
    warnings.add('Bodega industrial: no incluye pisos industriales especializados ni obra civil de cimentación profunda.');
    // Explicitly NOT adding bedrooms or residential fields

    final w = (double q) => _applyWaste(q, p.wastePercentage);

    // Estructura metálica (prioridad para bodegas)
    materials.add(_steel(w(p.totalArea * 25), false)); // 25 kg/m²
    materials.add(MaterialEstimate(
      materialName: 'Cubierta (lámina termoacústica o zinc)',
      quantity: w(areaPerFloor),
      unit: 'm²',
      category: 'Cubierta',
      criteria: 'Área de losa de cubierta',
    ));

    // Cerramiento perimetral
    materials.add(MaterialEstimate(
      materialName: 'Panel o bloque de cerramiento',
      quantity: w(wallArea),
      unit: 'm²',
      category: 'Cerramiento',
      criteria: 'Muros perimetrales incluyendo galpón',
    ));

    // Piso industrial
    materials.add(MaterialEstimate(
      materialName: 'Hormigón para piso industrial',
      quantity: w(p.totalArea * 0.18), // 18 cm espesor aprox.
      unit: 'm³',
      category: 'Piso Industrial',
      criteria: 'Losa de contrapiso con malla electrosoldada',
    ));
    materials.add(MaterialEstimate(
      materialName: 'Malla electrosoldada',
      quantity: w(p.totalArea),
      unit: 'm²',
      category: 'Piso Industrial',
      criteria: 'Refuerzo de piso industrial',
    ));

    // Área administrativa (si aplica)
    if (p.administrativeArea != null && p.administrativeArea! > 0) {
      materials.add(_blocks(
        w(p.administrativeArea! * 4 * BuildingCoefficients.bloquesPorM2Pared),
        'Área Administrativa',
      ));
    }

    return BuildingCalculationResult(
      materials: materials,
      assumptions: assumptions,
      warnings: warnings,
      estimatedWallArea: wallArea,
      estimatedFloorArea: p.totalArea,
      estimatedRoofArea: areaPerFloor,
    );
  }
}

// ─── Commercial space strategy ────────────────────────────────────────────────

class _CommercialSpaceStrategy implements BuildingMaterialStrategy {
  @override
  BuildingCalculationResult calculate(BuildingProject p) {
    final materials = <MaterialEstimate>[];
    final assumptions = <String>[];
    final warnings = <String>[];

    final clearH = p.clearHeight ?? 3.5;
    final areaPerFloor = p.totalArea / p.floors;
    final perimeter = _estimatedPerimeter(areaPerFloor);
    final wallArea = perimeter * clearH * p.floors * BuildingCoefficients.commercialWallFactor;

    assumptions.add('Local comercial: altura libre ${clearH.toStringAsFixed(1)} m');
    warnings.add('Cantidades referenciales para instalaciones comerciales básicas.');

    final w = (double q) => _applyWaste(q, p.wastePercentage);

    materials.add(_cement(w(areaPerFloor * 0.40), 'Estructura', 'Losa y estructura'));
    materials.add(_blocks(w(wallArea * BuildingCoefficients.bloquesPorM2Pared), 'Mampostería'));
    materials.add(MaterialEstimate(
      materialName: 'Porcelanato / Cerámica comercial',
      quantity: w(p.totalArea * 1.05),
      unit: 'm²',
      category: 'Pisos',
      criteria: 'Piso comercial de alto tránsito',
    ));
    materials.add(MaterialEstimate(
      materialName: 'Pintura',
      quantity: w(wallArea * BuildingCoefficients.pinturaPorM2Pared),
      unit: 'galones',
      category: 'Acabados',
      criteria: 'Acabado de local comercial',
    ));

    return BuildingCalculationResult(
      materials: materials,
      assumptions: assumptions,
      warnings: warnings,
      estimatedWallArea: wallArea,
      estimatedFloorArea: p.totalArea,
      estimatedRoofArea: areaPerFloor,
    );
  }
}

// ─── Commercial building strategy ────────────────────────────────────────────

class _CommercialBuildingStrategy implements BuildingMaterialStrategy {
  @override
  BuildingCalculationResult calculate(BuildingProject p) {
    final materials = <MaterialEstimate>[];
    final assumptions = <String>[];
    final warnings = <String>[];

    final units = p.commercialUnits ?? 4;
    final totalUnits = units * p.floors;
    final areaPerFloor = p.totalArea / p.floors;
    final perimeter = _estimatedPerimeter(areaPerFloor);
    final wallArea = perimeter * p.floorHeight * p.floors * BuildingCoefficients.commercialWallFactor;

    assumptions.add('Locales por planta: $units – Total locales: $totalUnits');
    warnings.add('Edificio comercial: requiere diseño estructural profesional.');

    final w = (double q) => _applyWaste(q, p.wastePercentage);

    materials.add(_cement(w(areaPerFloor * p.floors * 0.50), 'Estructura', 'Losas y vigas'));
    materials.add(_steel(w(p.totalArea * 10), true));
    materials.add(_blocks(w(wallArea * BuildingCoefficients.bloquesPorM2Pared), 'Mampostería'));
    materials.add(MaterialEstimate(
      materialName: 'Porcelanato comercial',
      quantity: w(p.totalArea),
      unit: 'm²',
      category: 'Pisos',
      criteria: 'Área total comercial',
    ));

    return BuildingCalculationResult(
      materials: materials,
      assumptions: assumptions,
      warnings: warnings,
      estimatedWallArea: wallArea,
      estimatedFloorArea: p.totalArea,
      estimatedRoofArea: areaPerFloor,
    );
  }
}

// ─── Office strategy ──────────────────────────────────────────────────────────

class _OfficeStrategy implements BuildingMaterialStrategy {
  @override
  BuildingCalculationResult calculate(BuildingProject p) {
    final materials = <MaterialEstimate>[];
    final assumptions = <String>[];
    final warnings = <String>[];

    final clearH = p.clearHeight ?? 2.7;
    final areaPerFloor = p.totalArea / p.floors;
    final perimeter = _estimatedPerimeter(areaPerFloor);
    final wallArea = perimeter * clearH * p.floors * BuildingCoefficients.commercialWallFactor;

    if (p.workstations != null) assumptions.add('Puestos de trabajo: ${p.workstations}');
    assumptions.add('Altura libre por planta: ${clearH.toStringAsFixed(1)} m');
    warnings.add('Oficinas: requiere diseño de instalaciones especializadas (red eléctrica, datos, HVAC).');

    final w = (double q) => _applyWaste(q, p.wastePercentage);

    materials.add(_cement(w(areaPerFloor * 0.45), 'Estructura', 'Losas y estructura'));
    materials.add(_steel(w(p.totalArea * 9), true));
    materials.add(_blocks(w(wallArea * BuildingCoefficients.bloquesPorM2Pared), 'Mampostería'));
    materials.add(MaterialEstimate(
      materialName: 'Porcelanato / Piso técnico',
      quantity: w(p.totalArea),
      unit: 'm²',
      category: 'Pisos',
      criteria: 'Área total de oficinas',
    ));
    materials.add(MaterialEstimate(
      materialName: 'Panel de cielorraso',
      quantity: w(p.totalArea),
      unit: 'm²',
      category: 'Acabados',
      criteria: 'Cielorraso de oficinas',
    ));

    return BuildingCalculationResult(
      materials: materials,
      assumptions: assumptions,
      warnings: warnings,
      estimatedWallArea: wallArea,
      estimatedFloorArea: p.totalArea,
      estimatedRoofArea: areaPerFloor,
    );
  }
}

// ─── Custom strategy ──────────────────────────────────────────────────────────

class _CustomStrategy implements BuildingMaterialStrategy {
  @override
  BuildingCalculationResult calculate(BuildingProject p) {
    // Fallback: generic calculation. Does not assume residential defaults.
    final materials = <MaterialEstimate>[];
    final assumptions = ['Construcción personalizada: estimación genérica'];
    final warnings = [
      'Para construcciones personalizadas, los cálculos son muy aproximados.',
      'Se recomienda especificar el tipo de edificación exacto para mayor precisión.',
    ];

    final areaPerFloor = p.totalArea / p.floors;
    final perimeter = _estimatedPerimeter(areaPerFloor);
    final wallArea = perimeter * p.floorHeight * p.floors * BuildingCoefficients.customWallFactor;

    final w = (double q) => _applyWaste(q, p.wastePercentage);

    materials.add(_cement(w(areaPerFloor * 0.35), 'Estructura', 'Estimación genérica'));
    materials.add(_blocks(w(wallArea * BuildingCoefficients.bloquesPorM2Pared), 'Mampostería'));
    materials.add(MaterialEstimate(
      materialName: 'Cerámica / Piso',
      quantity: w(p.totalArea),
      unit: 'm²',
      category: 'Pisos',
      criteria: 'Área total genérica',
    ));

    return BuildingCalculationResult(
      materials: materials,
      assumptions: assumptions,
      warnings: warnings,
      estimatedWallArea: wallArea,
      estimatedFloorArea: p.totalArea,
      estimatedRoofArea: areaPerFloor,
    );
  }
}
