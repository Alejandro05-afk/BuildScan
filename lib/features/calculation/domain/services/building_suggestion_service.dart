// lib/features/calculation/domain/services/building_suggestion_service.dart
//
// Provides contextual suggestions for simple construction elements.
// Uses the new ElementType (retrocompatible via ConstructionType alias).

import '../entities/project_dimensions.dart';

class BuildingSuggestionService {
  String getSuggestion({required double area, required ElementType type}) {
    switch (type) {
      case ElementType.wall:
        return 'La pared requiere cálculo por m² neto (descontando vanos de puertas y ventanas). '
            'Se recomienda validar la altura y aplicar al menos 10% de desperdicio.';

      case ElementType.ceramicFloor:
        return 'Para piso cerámico, considere el patrón de instalación. '
            'Una instalación diagonal incrementa el desperdicio hasta un 15%.';

      case ElementType.concreteSlab:
        return 'El volumen de hormigón depende directamente del espesor. '
            'Losas residenciales típicas: 12–15 cm. Losas industriales: 15–20 cm. '
            'Siempre coordine con un ingeniero estructural.';

      case ElementType.room:
        if (area < 6) return 'Cuarto muy pequeño. Verifique normativa mínima de habitabilidad.';
        if (area < 12) return 'Cuarto de tamaño básico. Adecuado para dormitorio simple u oficina pequeña.';
        return 'Cuarto de tamaño amplio. Considere particiones interiores para optimizar el espacio.';

      case ElementType.roof:
        return 'La cubierta debe diseñarse con la pendiente mínima requerida según el material '
            '(teja: ≥20%, zinc: ≥10%, termoacústica: ≥5%). '
            'Incluya alero mínimo de 0.50m para protección de fachadas.';
    }
  }
}
