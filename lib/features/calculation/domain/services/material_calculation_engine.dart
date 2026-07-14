import '../entities/project_dimensions.dart';
import '../entities/material_estimate.dart';
 
class MaterialCalculationEngine {
  CalculationResult calculate({
    required ConstructionType type,
    required ProjectDimensions dimensions,
    double wastePercentage = 10,
  }) {
    final factor = 1 + (wastePercentage / 100);
 
    switch (type) {
      case ConstructionType.paredLadrillo:
        final area = dimensions.areaPared;
        return CalculationResult(
          areaCalculada: area,
          desperdicio: wastePercentage,
          sugerencia: _suggestByArea(area),
          materiales: [
            MaterialEstimate(
              nombre: 'Ladrillos',
              unidad: 'unidades',
              cantidad: area * 42 * factor,
            ),
            MaterialEstimate(
              nombre: 'Cemento',
              unidad: 'sacos',
              cantidad: area * 0.25 * factor,
            ),
            MaterialEstimate(
              nombre: 'Arena',
              unidad: 'm³',
              cantidad: area * 0.05 * factor,
            ),
          ],
        );
 
      case ConstructionType.losaHormigon:
        final area = dimensions.areaPiso;
        return CalculationResult(
          areaCalculada: area,
          desperdicio: wastePercentage,
          sugerencia: _suggestByArea(area),
          materiales: [
            MaterialEstimate(nombre: 'Cemento', unidad: 'sacos', cantidad: area * 0.65 * factor),
            MaterialEstimate(nombre: 'Arena', unidad: 'm³', cantidad: area * 0.06 * factor),
            MaterialEstimate(nombre: 'Ripio', unidad: 'm³', cantidad: area * 0.07 * factor),
            MaterialEstimate(nombre: 'Varilla', unidad: 'unidades', cantidad: area * 0.80 * factor),
          ],
        );
 
      case ConstructionType.pisoCeramico:
        final area = dimensions.areaPiso;
        return CalculationResult(
          areaCalculada: area,
          desperdicio: wastePercentage,
          sugerencia: 'Área adecuada para instalación de piso cerámico.',
          materiales: [
            MaterialEstimate(nombre: 'Cerámica', unidad: 'm²', cantidad: area * 1.08),
            MaterialEstimate(nombre: 'Cemento cola', unidad: 'sacos', cantidad: area * 0.25),
            MaterialEstimate(nombre: 'Boquilla', unidad: 'kg', cantidad: area * 0.05),
          ],
        );
 
      case ConstructionType.cuartoBasico:
        final area = dimensions.areaPiso;
        return CalculationResult(
          areaCalculada: area,
          desperdicio: wastePercentage,
          sugerencia: _suggestByArea(area),
          materiales: [
            MaterialEstimate(nombre: 'Bloques/Ladrillos', unidad: 'unidades', cantidad: area * 85 * factor),
            MaterialEstimate(nombre: 'Cemento', unidad: 'sacos', cantidad: area * 0.90 * factor),
            MaterialEstimate(nombre: 'Arena', unidad: 'm³', cantidad: area * 0.12 * factor),
          ],
        );
    }
  }
 
  String _suggestByArea(double area) {
    if (area < 20) return 'Sugerencia: bodega, baño externo o cuarto pequeño.';
    if (area < 45) return 'Sugerencia: local pequeño, oficina o habitación básica.';
    if (area < 80) return 'Sugerencia: vivienda pequeña o ampliación familiar.';
    return 'Sugerencia: proyecto mediano; se recomienda dividir por ambientes.';
  }
}
