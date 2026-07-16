// lib/features/calculation/domain/services/material_calculation_engine.dart
//
// Calculates materials for simple construction elements.
// Uses the ElementType policy to determine the correct formula for each type.

import '../entities/project_dimensions.dart';
import '../entities/material_estimate.dart';
import 'building_suggestion_service.dart';

class MaterialCalculationEngine {
  final BuildingSuggestionService _suggestionService = BuildingSuggestionService();

  CalculationResult calculate({
    required ProjectDimensions dimensions,
    double wastePercentage = 10,
  }) {
    final type = dimensions.elementType;
    final factor = 1 + (wastePercentage / 100);
    final suggestion = _suggestionService.getSuggestion(
      area: dimensions.areaPiso,
      type: type,
    );

    switch (type) {
      case ElementType.wall:
        return _calculateWall(dimensions, factor, suggestion);
      case ElementType.ceramicFloor:
        return _calculateCeramicFloor(dimensions, factor, suggestion);
      case ElementType.concreteSlab:
        return _calculateConcreteSlab(dimensions, factor, suggestion);
      case ElementType.room:
        return _calculateRoom(dimensions, factor, suggestion);
      case ElementType.roof:
        return _calculateRoof(dimensions, factor, suggestion);
    }
  }

  // ── Strategies ────────────────────────────────────────────────────────────

  CalculationResult _calculateWall(
      ProjectDimensions d, double factor, String suggestion) {
    // Net wall area – subtract door and window openings
    final grossArea = d.largo * (d.alto ?? 0);
    final doorArea = (d.doors ?? 0) * 2.1 * 0.9; // 2.1m × 0.9m per door
    final windowArea = (d.windows ?? 0) * 1.2 * 1.0; // 1.2m × 1.0m per window
    final netArea = (grossArea - doorArea - windowArea).clamp(0, grossArea).toDouble();

    return CalculationResult(
      areaCalculada: netArea,
      desperdicio: (factor - 1) * 100,
      sugerencia: '$suggestion (Área neta: ${netArea.toStringAsFixed(2)} m²)',
      materiales: [
        MaterialEstimate(
          nombre: 'Ladrillos / Bloques',
          unidad: 'unidades',
          cantidad: (netArea * 42 * factor).ceilToDouble(),
        ),
        MaterialEstimate(
          nombre: 'Cemento',
          unidad: 'sacos',
          cantidad: (netArea * 0.25 * factor).ceilToDouble(),
        ),
        MaterialEstimate(
          nombre: 'Arena',
          unidad: 'kg',
          cantidad: (netArea * 0.05 * factor * 1500).ceilToDouble(),
        ),
      ],
    );
  }

  CalculationResult _calculateCeramicFloor(
      ProjectDimensions d, double factor, String suggestion) {
    // alto must be null for ceramic floors – we use areaPiso
    final area = d.areaPiso;
    return CalculationResult(
      areaCalculada: area,
      desperdicio: (factor - 1) * 100,
      sugerencia: suggestion,
      materiales: [
        MaterialEstimate(nombre: 'Cerámica / Porcelanato', unidad: 'm²', cantidad: (area * factor).ceilToDouble()),
        MaterialEstimate(
          nombre: 'Cemento cola',
          unidad: 'sacos',
          cantidad: (area * 0.25 * factor).ceilToDouble(),
        ),
        MaterialEstimate(
          nombre: 'Boquilla / Fragua',
          unidad: 'kg',
          cantidad: (area * 0.05 * factor).ceilToDouble(),
        ),
      ],
    );
  }

  CalculationResult _calculateConcreteSlab(
      ProjectDimensions d, double factor, String suggestion) {
    // Uses thickness, not alto
    final slabThickness = d.thickness ?? 0.12; // default 12 cm
    final volume = d.largo * d.ancho * slabThickness;

    return CalculationResult(
      areaCalculada: d.areaPiso,
      desperdicio: (factor - 1) * 100,
      sugerencia:
          '$suggestion (Espesor: ${(slabThickness * 100).toStringAsFixed(0)} cm, Volumen: ${volume.toStringAsFixed(2)} m³)',
      materiales: [
        MaterialEstimate(
          nombre: 'Cemento',
          unidad: 'sacos',
          cantidad: (volume * 8.5 * factor).ceilToDouble(),
        ),
        MaterialEstimate(
          nombre: 'Arena',
          unidad: 'm³',
          cantidad: (volume * 0.55 * factor).ceilToDouble(),
        ),
        MaterialEstimate(
          nombre: 'Ripio',
          unidad: 'm³',
          cantidad: (volume * 0.65 * factor).ceilToDouble(),
        ),
        MaterialEstimate(
          nombre: 'Varilla corrugada',
          unidad: 'kg',
          cantidad: (d.areaPiso * 8 * factor).ceilToDouble(),
        ),
      ],
    );
  }

  CalculationResult _calculateRoom(
      ProjectDimensions d, double factor, String suggestion) {
    final perimetro = 2 * (d.largo + d.ancho);
    final wallHeight = d.alto ?? 2.6;
    final grossWallArea = perimetro * wallHeight;
    final doorArea = (d.doors ?? 0) * 2.1 * 0.9;
    final windowArea = (d.windows ?? 0) * 1.2 * 1.0;
    final netWallArea =
        (grossWallArea - doorArea - windowArea).clamp(0, grossWallArea).toDouble();
    final floorArea = d.areaPiso;

    return CalculationResult(
      areaCalculada: floorArea,
      desperdicio: (factor - 1) * 100,
      sugerencia:
          '$suggestion (Paredes netas: ${netWallArea.toStringAsFixed(2)} m², sin descontar vanos de fachada)',
      materiales: [
        MaterialEstimate(
          nombre: 'Bloques / Ladrillos (paredes)',
          unidad: 'unidades',
          cantidad: (netWallArea * 42 * factor).ceilToDouble(),
        ),
        MaterialEstimate(
          nombre: 'Cemento (mortero)',
          unidad: 'sacos',
          cantidad: (netWallArea * 0.25 * factor).ceilToDouble(),
        ),
        MaterialEstimate(
          nombre: 'Cerámica (piso)',
          unidad: 'm²',
          cantidad: (floorArea * factor).ceilToDouble(),
        ),
        MaterialEstimate(
          nombre: 'Cemento cola (piso)',
          unidad: 'sacos',
          cantidad: (floorArea * 0.25 * factor).ceilToDouble(),
        ),
      ],
    );
  }

  CalculationResult _calculateRoof(
      ProjectDimensions d, double factor, String suggestion) {
    final baseArea = d.areaPiso;
    // Slope correction if provided
    final slope = d.roofSlope ?? 0;
    final slopeRad = slope * 3.14159 / 180;
    final slopeCorrection = slope > 0 ? (1 / (1 - (slopeRad / 3.14159))) : 1.0;
    final actualRoofArea = baseArea * slopeCorrection;

    return CalculationResult(
      areaCalculada: actualRoofArea,
      desperdicio: (factor - 1) * 100,
      sugerencia: '$suggestion (Tipo: ${d.roofType ?? 'estándar'}, Área inclinada: ${actualRoofArea.toStringAsFixed(2)} m²)',
      materiales: [
        MaterialEstimate(
          nombre: 'Material de cubierta',
          unidad: 'm²',
          cantidad: (actualRoofArea * factor).ceilToDouble(),
        ),
        MaterialEstimate(
          nombre: 'Estructura de soporte (madera/metal)',
          unidad: 'm²',
          cantidad: (actualRoofArea * 0.3 * factor).ceilToDouble(),
        ),
      ],
    );
  }
}
