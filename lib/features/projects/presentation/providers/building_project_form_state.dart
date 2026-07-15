import '../../domain/entities/building_project.dart';
import '../../domain/entities/building_suggestion_result.dart';
import '../../domain/entities/building_calculation_result.dart';
import '../../domain/services/building_area_distribution_service.dart';

class BuildingProjectState {
  final BuildingProject form;
  final List<BuildingSuggestionResult> suggestions;
  final BuildingSuggestionResult? selectedSuggestion;
  final BuildingAreaDistribution? distribution;
  final BuildingCalculationResult? calculation;
  final bool isCalculating;
  final bool isSaving;
  final String? errorMessage;
  final int currentStep;

  BuildingProjectState({
    required this.form,
    this.suggestions = const [],
    this.selectedSuggestion,
    this.distribution,
    this.calculation,
    this.isCalculating = false,
    this.isSaving = false,
    this.errorMessage,
    this.currentStep = 1,
  });

  BuildingProjectState copyWith({
    BuildingProject? form,
    List<BuildingSuggestionResult>? suggestions,
    BuildingSuggestionResult? selectedSuggestion,
    BuildingAreaDistribution? distribution,
    BuildingCalculationResult? calculation,
    bool? isCalculating,
    bool? isSaving,
    String? errorMessage,
    int? currentStep,
  }) {
    return BuildingProjectState(
      form: form ?? this.form,
      suggestions: suggestions ?? this.suggestions,
      selectedSuggestion: selectedSuggestion ?? this.selectedSuggestion,
      distribution: distribution ?? this.distribution,
      calculation: calculation ?? this.calculation,
      isCalculating: isCalculating ?? this.isCalculating,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}
