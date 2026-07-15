import '../entities/building_project.dart';
import '../entities/building_suggestion_result.dart';

class BuildingSuggestionService {
  List<BuildingSuggestionResult> suggestFromAreaAndFloors({
    required double area,
    int? maxFloors,
    String? usage,
  }) {
    final suggestions = <BuildingSuggestionResult>[];

    if (area >= 40 && area <= 70) {
      suggestions.add(BuildingSuggestionResult(
        title: 'Vivienda Compacta',
        description: 'Casa pequeña de una planta, ideal para 1 a 2 personas.',
        recommendedType: BuildingType.house,
        suggestedSpaces: ['1 a 2 dormitorios', '1 baño', 'Sala-comedor', 'Cocina'],
        estimatedBuiltArea: area,
        estimatedCirculationArea: area * 0.1,
        estimatedWallArea: area * 2.5,
        estimatedRoofArea: area,
        assumptions: ['Distribución abierta', 'No requiere cimentación profunda'],
        warnings: ['Área mínima, difícil ampliación'],
      ));
    }

    if (area > 70 && area <= 120) {
      suggestions.add(BuildingSuggestionResult(
        title: 'Casa Familiar Estándar',
        description: 'Vivienda cómoda para familia pequeña.',
        recommendedType: BuildingType.house,
        suggestedSpaces: ['2 a 3 dormitorios', '2 baños', 'Sala, comedor, cocina', 'Parqueadero opcional'],
        estimatedBuiltArea: area,
        estimatedCirculationArea: area * 0.12,
        estimatedWallArea: area * 2.6,
        estimatedRoofArea: area / (maxFloors ?? 1),
        assumptions: ['Distribución tradicional'],
        warnings: ['Verificar normativa de retiros y parqueos'],
      ));
    }

    if (area > 120 && area <= 220) {
      suggestions.add(BuildingSuggestionResult(
        title: 'Casa Amplia',
        description: 'Vivienda espaciosa con áreas sociales.',
        recommendedType: BuildingType.house,
        suggestedSpaces: ['3 a 4 dormitorios', '3 baños', 'Área social', '2 parqueaderos'],
        estimatedBuiltArea: area,
        estimatedCirculationArea: area * 0.15,
        estimatedWallArea: area * 2.8,
        estimatedRoofArea: area / (maxFloors ?? 2),
        assumptions: ['Acabados de mayor calidad'],
        warnings: ['Requiere análisis estructural detallado'],
      ));
    }

    if (area > 220) {
      suggestions.add(BuildingSuggestionResult(
        title: 'Edificación Residencial / Comercial',
        description: 'Edificio de departamentos o mixto comercial.',
        recommendedType: BuildingType.residentialBuilding,
        suggestedSpaces: ['Múltiples unidades', 'Áreas comunes', 'Parqueos subterráneos'],
        estimatedBuiltArea: area,
        estimatedCirculationArea: area * 0.18,
        estimatedWallArea: area * 3.0,
        estimatedRoofArea: area / (maxFloors ?? 3),
        assumptions: ['Estructura aporticada o mixta'],
        warnings: ['Estimación altamente preliminar. Requiere estudios completos.'],
      ));
    }

    // Default if no specific range matches perfectly
    if (suggestions.isEmpty) {
      suggestions.add(BuildingSuggestionResult(
        title: 'Proyecto Personalizado',
        description: 'Edificación a medida basada en el área.',
        recommendedType: BuildingType.custom,
        suggestedSpaces: ['A definir por el usuario'],
        estimatedBuiltArea: area,
        estimatedCirculationArea: area * 0.15,
        estimatedWallArea: area * 2.5,
        estimatedRoofArea: area / (maxFloors ?? 1),
        assumptions: ['Cálculo basado en promedios generales'],
        warnings: ['Revisar con un profesional el diseño propuesto'],
      ));
    }

    return suggestions;
  }
}
