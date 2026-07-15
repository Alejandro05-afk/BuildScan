import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/building_project.dart';
import '../../domain/services/building_suggestion_service.dart';
import '../../domain/services/building_area_distribution_service.dart';
import '../../domain/services/complete_building_material_engine.dart';
import 'building_project_form_state.dart';

final buildingProjectFormProvider = NotifierProvider<BuildingProjectFormNotifier, BuildingProjectState>(() {
  return BuildingProjectFormNotifier(
    suggestionService: BuildingSuggestionService(),
    distributionService: BuildingAreaDistributionService(),
    materialEngine: CompleteBuildingMaterialEngine(),
  );
});

class BuildingProjectFormNotifier extends Notifier<BuildingProjectState> {
  final BuildingSuggestionService suggestionService;
  final BuildingAreaDistributionService distributionService;
  final CompleteBuildingMaterialEngine materialEngine;

  BuildingProjectFormNotifier({
    required this.suggestionService,
    required this.distributionService,
    required this.materialEngine,
  });

  @override
  BuildingProjectState build() {
    return BuildingProjectState(
      form: BuildingProject(
        constructoraId: '', // To be filled later via Auth Provider
        name: '',
        buildingType: BuildingType.custom,
        totalArea: 0,
        floors: 1,
        floorHeight: 2.6,
        constructionSystem: ConstructionSystem.reinforcedConcrete,
        finishLevel: FinishLevel.standard,
      ),
    );
  }

  void updateForm(BuildingProject newForm) {
    state = state.copyWith(form: newForm);
  }

  void nextStep() {
    if (state.currentStep < 6) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 1) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void generateSuggestions() {
    final validationErrors = state.form.validate();
    if (validationErrors.isNotEmpty) {
      state = state.copyWith(errorMessage: validationErrors.join('\n'));
      return;
    }

    state = state.copyWith(isCalculating: true, errorMessage: null);

    try {
      final suggestions = suggestionService.suggestFromAreaAndFloors(
        area: state.form.totalArea,
        maxFloors: state.form.floors,
      );
      state = state.copyWith(
        suggestions: suggestions,
        isCalculating: false,
      );
      nextStep();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error generando sugerencias: $e',
        isCalculating: false,
      );
    }
  }

  void selectSuggestion(int index) {
    if (index >= 0 && index < state.suggestions.length) {
      final selected = state.suggestions[index];
      
      // Actualizar el formulario con el tipo recomendado
      final newForm = state.form.copyWith(
        buildingType: selected.recommendedType,
      );
      
      state = state.copyWith(
        selectedSuggestion: selected,
        form: newForm,
      );
      
      _calculateDistribution(newForm);
      nextStep();
    }
  }

  void _calculateDistribution(BuildingProject form) {
    final dist = distributionService.estimateDistribution(
      form.buildingType,
      form.totalArea,
    );
    state = state.copyWith(distribution: dist);
  }

  void calculateMaterials() {
    state = state.copyWith(isCalculating: true, errorMessage: null);
    try {
      final calc = materialEngine.calculateMaterials(state.form);
      state = state.copyWith(
        calculation: calc,
        isCalculating: false,
      );
      nextStep();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error en el cálculo: $e',
        isCalculating: false,
      );
    }
  }

  // TODO: Add save functionality to Supabase
}
