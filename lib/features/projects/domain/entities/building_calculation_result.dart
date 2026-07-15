class MaterialEstimate {
  final String materialName;
  final double quantity;
  final String unit;
  final String category;
  final String criteria;
  final bool isStructural;

  MaterialEstimate({
    required this.materialName,
    required this.quantity,
    required this.unit,
    required this.category,
    required this.criteria,
    this.isStructural = false,
  });
}

class BuildingCalculationResult {
  final List<MaterialEstimate> materials;
  final List<String> assumptions;
  final List<String> warnings;
  final double estimatedWallArea;
  final double estimatedFloorArea;
  final double estimatedRoofArea;

  BuildingCalculationResult({
    required this.materials,
    required this.assumptions,
    required this.warnings,
    required this.estimatedWallArea,
    required this.estimatedFloorArea,
    required this.estimatedRoofArea,
  });
}
