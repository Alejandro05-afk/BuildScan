import '../entities/project_dimensions.dart';
import '../entities/material_estimate.dart';
import 'building_suggestion_service.dart';

class MaterialCalculationEngine {
  final BuildingSuggestionService _suggestionService = BuildingSuggestionService();

  CalculationResult calculate({
    required ConstructionType type,
    required ProjectDimensions dimensions,
    double wastePercentage = 10,
  }) {
    final factor = 1 + (wastePercentage / 100);
    final areaPiso = dimensions.areaPiso;
    
    // Sugerencia usando el servicio externo
    final suggestion = _suggestionService.getSuggestion(
      area: areaPiso,
      type: type,
    );
 
    switch (type) {
      case ConstructionType.paredLadrillo:
        final area = dimensions.areaPared;
        return CalculationResult(
          areaCalculada: area,
          desperdicio: wastePercentage,
          sugerencia: suggestion,
          materiales: [
            MaterialEstimate(
              nombre: 'Ladrillos',
              unidad: 'unidades',
              cantidad: (area * 42 * factor).ceilToDouble(),
            ),
            MaterialEstimate(
              nombre: 'Cemento',
              unidad: 'sacos',
              cantidad: area * 0.25 * factor,
            ),
            MaterialEstimate(
              nombre: 'Arena',
              unidad: 'kg',
              cantidad: area * 0.05 * factor * 1500, // 1500kg por m3
            ),
          ],
        );
 
      case ConstructionType.losaHormigon:
        return CalculationResult(
          areaCalculada: areaPiso,
          desperdicio: wastePercentage,
          sugerencia: suggestion,
          materiales: [
            MaterialEstimate(nombre: 'Cemento', unidad: 'sacos', cantidad: areaPiso * 0.65 * factor),
            MaterialEstimate(nombre: 'Arena', unidad: 'kg', cantidad: areaPiso * 0.06 * factor * 1500),
            MaterialEstimate(nombre: 'Ripio', unidad: 'm³', cantidad: areaPiso * 0.07 * factor),
            MaterialEstimate(nombre: 'Varilla', unidad: 'unidades', cantidad: (areaPiso * 0.80 * factor).ceilToDouble()),
          ],
        );
 
      case ConstructionType.pisoCeramico:
        return CalculationResult(
          areaCalculada: areaPiso,
          desperdicio: wastePercentage,
          sugerencia: suggestion,
          materiales: [
            MaterialEstimate(nombre: 'Cerámica', unidad: 'm²', cantidad: areaPiso * factor),
            MaterialEstimate(nombre: 'Cemento cola', unidad: 'sacos', cantidad: areaPiso * 0.25 * factor),
            MaterialEstimate(nombre: 'Boquilla', unidad: 'kg', cantidad: areaPiso * 0.05 * factor),
          ],
        );
 
      case ConstructionType.cuartoBasico:
        // Cálculo del perímetro y área de paredes
        final perimetro = 2 * (dimensions.largo + dimensions.ancho);
        final areaParedes = perimetro * dimensions.alto;
        
        return CalculationResult(
          areaCalculada: areaPiso, // Se mantiene el área del piso como referencia principal
          desperdicio: wastePercentage,
          sugerencia: '$suggestion (El cálculo asume paredes sin descontar vanos)',
          materiales: [
            MaterialEstimate(nombre: 'Bloques/Ladrillos', unidad: 'unidades', cantidad: (areaParedes * 85 * factor).ceilToDouble()),
            MaterialEstimate(nombre: 'Cemento', unidad: 'sacos', cantidad: areaParedes * 0.90 * factor),
            MaterialEstimate(nombre: 'Arena', unidad: 'kg', cantidad: areaParedes * 0.12 * factor * 1500),
          ],
        );
    }
  }
}
