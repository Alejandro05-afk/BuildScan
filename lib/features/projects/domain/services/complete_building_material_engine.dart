import 'dart:math';
import '../../../../core/constants/building_coefficients.dart';
import '../entities/building_project.dart';
import '../entities/building_calculation_result.dart';

class CompleteBuildingMaterialEngine {
  BuildingCalculationResult calculateMaterials(BuildingProject project) {
    final materials = <MaterialEstimate>[];
    final assumptions = <String>[];
    final warnings = <String>[];

    // 1. Cálculos de áreas base
    final areaPerFloor = project.totalArea / project.floors;
    final estimatedSide = sqrt(areaPerFloor);
    final estimatedPerimeter = 4 * estimatedSide;

    final exteriorWallArea = estimatedPerimeter * project.floorHeight * project.floors;
    
    double internalWallFactor = BuildingCoefficients.houseInternalWallFactor;
    switch (project.buildingType) {
      case BuildingType.house:
        internalWallFactor = BuildingCoefficients.houseInternalWallFactor;
        break;
      case BuildingType.residentialBuilding:
        internalWallFactor = BuildingCoefficients.residentialBuildingWallFactor;
        break;
      case BuildingType.commercialBuilding:
      case BuildingType.commercialSpace:
      case BuildingType.office:
        internalWallFactor = BuildingCoefficients.commercialWallFactor;
        break;
      case BuildingType.warehouse:
        internalWallFactor = BuildingCoefficients.warehouseWallFactor;
        break;
      case BuildingType.custom:
        internalWallFactor = BuildingCoefficients.customWallFactor;
        break;
    }

    double totalWallArea = exteriorWallArea * internalWallFactor;
    if (!project.hasExteriorWalls) {
       totalWallArea = exteriorWallArea * (internalWallFactor - 1.0); // Sólo paredes internas si no tiene exteriores
    }

    final floorArea = project.totalArea;
    final roofArea = project.hasRoofSlab ? areaPerFloor : 0.0;

    assumptions.add('Área por planta estimada: ${areaPerFloor.toStringAsFixed(2)} m²');
    assumptions.add('Paredes estimadas usando factor de distribución: $internalWallFactor');

    warnings.add('Cantidades estructurales preliminares sujetas a cálculo estructural.');

    double applyWaste(double quantity) {
      return quantity * (1 + (project.wastePercentage / 100));
    }

    // Categoría: Obra Gris / Estructura
    if (project.constructionSystem == ConstructionSystem.reinforcedConcrete || 
        project.constructionSystem == ConstructionSystem.mixed) {
      // Cantidades ultra referenciales para losas, vigas y columnas sumadas al área de losa
      final hormigonVolumeEst = roofArea * 0.25; // m3 estimado muy grueso
      materials.add(MaterialEstimate(
        materialName: 'Cemento (Estructura)',
        quantity: applyWaste(hormigonVolumeEst * BuildingCoefficients.cementoPorM2Hormigon),
        unit: 'sacos',
        category: 'Obra Gris',
        criteria: 'Estimación referencial para vigas, columnas y losas',
        isStructural: true,
      ));
      materials.add(MaterialEstimate(
        materialName: 'Acero de refuerzo',
        quantity: applyWaste(roofArea * BuildingCoefficients.aceroPorM2Hormigon),
        unit: 'kg',
        category: 'Obra Gris',
        criteria: 'Estimación referencial para armaduras',
        isStructural: true,
      ));
    } else if (project.constructionSystem == ConstructionSystem.steelStructure) {
      materials.add(MaterialEstimate(
        materialName: 'Acero estructural',
        quantity: applyWaste(floorArea * 25), // 25kg/m2 referencial
        unit: 'kg',
        category: 'Obra Gris',
        criteria: 'Perfilería estructural',
        isStructural: true,
      ));
    }

    // Categoría: Mampostería
    materials.add(MaterialEstimate(
      materialName: 'Bloques/Ladrillos',
      quantity: applyWaste(totalWallArea * BuildingCoefficients.bloquesPorM2Pared),
      unit: 'unidades',
      category: 'Mampostería',
      criteria: 'Considerando dimensiones estándar 20x40',
    ));
    materials.add(MaterialEstimate(
      materialName: 'Cemento (Mortero de asiente y enlucido)',
      quantity: applyWaste(totalWallArea * BuildingCoefficients.cementoPorM2Mamposteria),
      unit: 'sacos',
      category: 'Mampostería',
      criteria: 'Para asiente de bloques y recubrimiento',
    ));

    // Categoría: Pisos y Acabados
    materials.add(MaterialEstimate(
      materialName: 'Cerámica/Porcelanato',
      quantity: applyWaste(floorArea * BuildingCoefficients.ceramicaPorM2Piso),
      unit: 'm²',
      category: 'Pisos',
      criteria: 'Área de piso más zócalos referenciales',
    ));
    materials.add(MaterialEstimate(
      materialName: 'Pegamento/Bondex',
      quantity: applyWaste(floorArea * BuildingCoefficients.bondexPorM2Piso),
      unit: 'sacos',
      category: 'Pisos',
      criteria: 'Para instalación de cerámica',
    ));
    
    // Pintura
    materials.add(MaterialEstimate(
      materialName: 'Pintura',
      quantity: applyWaste(totalWallArea * BuildingCoefficients.pinturaPorM2Pared),
      unit: 'galones',
      category: 'Acabados',
      criteria: '2 manos de pintura sobre paredes y cielorraso (referencial)',
    ));

    return BuildingCalculationResult(
      materials: materials,
      assumptions: assumptions,
      warnings: warnings,
      estimatedWallArea: totalWallArea,
      estimatedFloorArea: floorArea,
      estimatedRoofArea: roofArea,
    );
  }
}
