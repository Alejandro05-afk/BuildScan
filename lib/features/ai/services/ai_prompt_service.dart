// lib/features/ai/services/ai_prompt_service.dart
//
// Builds AI image generation prompts from project data.
// Only includes fields that are visible for the given type – never sends
// zero-valued or incompatible data to the AI.

import '../../calculation/domain/entities/project_dimensions.dart';
import '../../projects/domain/entities/building_project.dart';

class AiPromptService {
  // ── Simple element prompt ─────────────────────────────────────────────────

  String buildConstructionPrompt({
    required ElementType type,
    required ProjectDimensions dimensions,
    String nombre = '',
    String style = 'moderna',
  }) {
    final area = dimensions.areaPiso;
    final typeLabel = _elementTypeLabel(type);
    final sizeLabel = _sizeLabel(area);

    final buf = StringBuffer();
    buf.write('Architectural concept render of a $typeLabel');
    if (nombre.isNotEmpty) buf.write(' named "$nombre"');
    buf.write(', $sizeLabel for ${area.toStringAsFixed(1)} square meters, ');
    buf.write('${dimensions.largo}m x ${dimensions.ancho}m layout');

    if (dimensions.alto != null && dimensions.alto! > 0) {
      buf.write(', ${dimensions.alto}m height');
    }
    if (dimensions.thickness != null && dimensions.thickness! > 0) {
      buf.write(', ${dimensions.thickness! * 100}cm thickness');
    }
    if (dimensions.doors != null && dimensions.doors! > 0) {
      buf.write(', ${dimensions.doors} door${dimensions.doors! > 1 ? 's' : ''}');
    }
    if (dimensions.windows != null && dimensions.windows! > 0) {
      buf.write(', ${dimensions.windows} window${dimensions.windows! > 1 ? 's' : ''}');
    }
    if (dimensions.blockType != null && dimensions.blockType!.isNotEmpty) {
      buf.write(', ${dimensions.blockType} blocks');
    }
    if (dimensions.concreteType != null && dimensions.concreteType!.isNotEmpty) {
      buf.write(', ${dimensions.concreteType} concrete');
    }
    if (dimensions.roofType != null && dimensions.roofType!.isNotEmpty) {
      buf.write(', ${dimensions.roofType} roof');
    }
    if (dimensions.roofSlope != null && dimensions.roofSlope! > 0) {
      buf.write(', ${dimensions.roofSlope}° slope');
    }
    if (dimensions.eave != null && dimensions.eave! > 0) {
      buf.write(', ${dimensions.eave}m eaves');
    }
    if (dimensions.finishType != null && dimensions.finishType!.isNotEmpty) {
      buf.write(', ${dimensions.finishType} finishes');
    }
    if (dimensions.installationType != null && dimensions.installationType!.isNotEmpty) {
      buf.write(', ${dimensions.installationType} installation');
    }
    if (dimensions.tileWidth != null && dimensions.tileLength != null) {
      buf.write(', ${dimensions.tileWidth}x${dimensions.tileLength}cm tiles');
    }

    buf.write(', functional design, realistic construction materials common in Ecuador, ');
    buf.write('$style style, exterior perspective, professional architectural visualization, ');
    buf.write('clean lines, natural lighting, urban context');

    return buf.toString();
  }

  // ── Complete building prompt – context-aware ──────────────────────────────

  String buildCompleteBuildingPrompt({required BuildingProject project}) {
    final typeLabel = _buildingTypeLabel(project.buildingType);
    final buf = StringBuffer();

    buf.write('Architectural concept render of a $typeLabel, ');
    buf.write(
        'approximately ${project.totalArea.toStringAsFixed(0)} square meters, ');
    buf.write('${project.floors} floor${project.floors > 1 ? 's' : ''}, ');
    buf.write('${project.constructionSystem.name} construction, ');
    buf.write('${project.finishLevel.name} finishes, ');

    // Only add fields that make sense for this building type:
    final cfg = project.policy;

    if (cfg.isVisible(BuildingField.bedrooms) && project.bedrooms != null) {
      buf.write('${project.bedrooms} bedroom${project.bedrooms! > 1 ? 's' : ''}, ');
    }
    if (cfg.isVisible(BuildingField.apartmentsPerFloor) &&
        project.apartmentsPerFloor != null) {
      buf.write('${project.apartmentsPerFloor} apartments per floor, ');
    }
    if (cfg.isVisible(BuildingField.clearHeight) && project.clearHeight != null) {
      buf.write('${project.clearHeight}m clear height, ');
    }
    if (cfg.isVisible(BuildingField.commercialUnits) &&
        project.commercialUnits != null) {
      buf.write('${project.commercialUnits} commercial units per floor, ');
    }
    if (cfg.isVisible(BuildingField.workstations) && project.workstations != null) {
      buf.write('${project.workstations} workstations, ');
    }
    if (cfg.isVisible(BuildingField.loadingArea) && project.loadingArea != null) {
      buf.write('loading dock area of ${project.loadingArea}m², ');
    }

    buf.write(
        'contemporary architecture, urban context, professional architectural visualization, '
        'realistic construction materials, clean lines, natural lighting, exterior perspective');

    return buf.toString();
  }

  String get negativePrompt =>
      'blurry, distorted, low quality, unrealistic proportions, '
      'extra floors, text, watermark, deformed, ugly, disfigured, '
      'poorly drawn, bad anatomy, wrong anatomy, floating objects';

  // ── Private helpers ───────────────────────────────────────────────────────

  String _elementTypeLabel(ElementType type) {
    switch (type) {
      case ElementType.wall:
        return 'brick wall structure with proper mortar joints';
      case ElementType.concreteSlab:
        return 'concrete slab building';
      case ElementType.ceramicFloor:
        return 'ceramic floor residential space with polished tiles';
      case ElementType.room:
        return 'basic room construction interior';
      case ElementType.roof:
        return 'roof structure and covering system';
    }
  }

  String _buildingTypeLabel(BuildingType type) {
    switch (type) {
      case BuildingType.house:
        return 'modern residential house';
      case BuildingType.residentialBuilding:
        return 'modern residential apartment building';
      case BuildingType.commercialBuilding:
        return 'commercial office building';
      case BuildingType.commercialSpace:
        return 'commercial retail space';
      case BuildingType.office:
        return 'modern office building';
      case BuildingType.warehouse:
        return 'industrial warehouse with metal structure';
      case BuildingType.custom:
        return 'mixed-use construction project';
    }
  }

  String _sizeLabel(double area) {
    if (area < 20) return 'small utility space';
    if (area < 45) return 'small room';
    if (area < 80) return 'residential unit';
    return 'medium-scale project';
  }
}
