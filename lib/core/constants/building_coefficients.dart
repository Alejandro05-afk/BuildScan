class BuildingCoefficients {
  // Coeficientes académicos configurables para estimaciones referenciales

  // Factores de distribución de paredes interiores según el tipo de edificación
  // Multiplicador sobre el área de paredes exteriores estimadas
  static const double houseInternalWallFactor = 1.55;
  static const double residentialBuildingWallFactor = 1.75;
  static const double commercialWallFactor = 1.35;
  static const double warehouseWallFactor = 1.10;
  static const double customWallFactor = 1.50;

  // Consumos promedio (cantidades por m2 o unidad referencial)
  // Obra gris
  static const double cementoPorM2Hormigon = 7.0; // sacos (50kg) referencial por m3 o m2 losa
  static const double aceroPorM2Hormigon = 12.0; // kg referencial
  
  // Mampostería
  static const double bloquesPorM2Pared = 12.5; // unidades
  static const double cementoPorM2Mamposteria = 0.25; // sacos
  static const double arenaPorM2Mamposteria = 0.03; // m3
  
  // Acabados y Pisos
  static const double ceramicaPorM2Piso = 1.05; // m2 considerando recortes
  static const double bondexPorM2Piso = 0.2; // sacos
  static const double pinturaPorM2Pared = 0.15; // galones (2 manos)
}
