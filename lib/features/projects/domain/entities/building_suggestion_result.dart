import 'building_project.dart';

class BuildingSuggestionResult {
  final String title;
  final String description;
  final BuildingType recommendedType;
  final List<String> suggestedSpaces;
  final double estimatedBuiltArea;
  final double estimatedCirculationArea;
  final double estimatedWallArea;
  final double estimatedRoofArea;
  final List<String> assumptions;
  final List<String> warnings;

  BuildingSuggestionResult({
    required this.title,
    required this.description,
    required this.recommendedType,
    required this.suggestedSpaces,
    required this.estimatedBuiltArea,
    required this.estimatedCirculationArea,
    required this.estimatedWallArea,
    required this.estimatedRoofArea,
    required this.assumptions,
    required this.warnings,
  });
}
