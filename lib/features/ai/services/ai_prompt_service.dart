import '../../calculation/domain/entities/project_dimensions.dart';

class AiPromptService {
  String buildConstructionPrompt({
    required ConstructionType type,
    required ProjectDimensions dimensions,
    String style = 'moderna',
  }) {
    final area = dimensions.largo * dimensions.ancho;
    final typeLabel = _typeLabel(type);
    final sizeLabel = _sizeLabel(area);

    return 'Architectural concept render of a $typeLabel, '
        '$sizeLabel for ${area.toStringAsFixed(1)} square meters, '
        '${dimensions.largo}m x ${dimensions.ancho}m layout, '
        'functional design, realistic construction materials common in Ecuador, '
        '$style style, exterior perspective, professional architectural visualization, '
        'clean lines, natural lighting, urban context';
  }

  String get negativePrompt =>
      'blurry, distorted, low quality, unrealistic proportions, '
      'extra floors, text, watermark, deformed, ugly, disfigured, '
      'poorly drawn, bad anatomy, wrong anatomy, floating objects';

  String _typeLabel(ConstructionType type) {
    switch (type) {
      case ConstructionType.paredLadrillo:
        return 'brick wall structure';
      case ConstructionType.losaHormigon:
        return 'concrete slab building';
      case ConstructionType.pisoCeramico:
        return 'ceramic floor residential space';
      case ConstructionType.cuartoBasico:
        return 'basic room construction';
    }
  }

  String _sizeLabel(double area) {
    if (area < 20) return 'small utility space';
    if (area < 45) return 'small room';
    if (area < 80) return 'residential unit';
    return 'medium-scale project';
  }
}
