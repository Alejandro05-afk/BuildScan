// lib/features/projects/presentation/providers/building_project_form_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/building_project.dart';
import '../../domain/services/building_suggestion_service.dart';
import '../../domain/services/building_area_distribution_service.dart';
import '../../domain/services/complete_building_material_engine.dart';
import 'building_project_form_state.dart';

final buildingProjectFormProvider =
    NotifierProvider<BuildingProjectFormNotifier, BuildingProjectState>(() {
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
        constructoraId: '',
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

  /// Changes the building type and clears incompatible fields in state and controllers.
  /// This is the single method that must be called for type changes.
  void changeBuildingType(BuildingType newType) {
    // withType() returns a project with incompatible fields set to null.
    final newForm = state.form.withType(newType);
    state = state.copyWith(form: newForm);
    _calculateDistribution(newForm);
  }

  void nextStep() {
    if (state.currentStep < 6) {
      if (state.currentStep == 4) {
        _calculateDistribution(state.form);
      }
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 1) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void generateSuggestions() {
    final validationErrors = _validateStep1();
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

      final firstSuggestion = suggestions.first;
      // Use withType() to cleanly switch and clear incompatible fields.
      final newForm = state.form.withType(firstSuggestion.recommendedType);

      state = state.copyWith(
        suggestions: suggestions,
        selectedSuggestion: firstSuggestion,
        form: newForm,
        isCalculating: false,
      );

      _calculateDistribution(newForm);
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
      // withType() clears incompatible fields for the new recommended type.
      final newForm = state.form.withType(selected.recommendedType);

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
    final errors = state.form.validate();
    if (errors.isNotEmpty) {
      state = state.copyWith(
        errorMessage: errors.join('\n'),
        isCalculating: false,
      );
      return;
    }

    state = state.copyWith(isCalculating: true, errorMessage: null);
    try {
      final calc = materialEngine.calculateMaterials(state.form);
      state = state.copyWith(
        calculation: calc,
        isCalculating: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error en el cálculo: $e',
        isCalculating: false,
      );
    }
  }

  List<String> _validateStep1() {
    final errors = <String>[];
    if (state.form.name.trim().isEmpty) errors.add('El nombre del proyecto es obligatorio.');
    if (state.form.totalArea <= 0) errors.add('El área debe ser mayor a 0 m².');
    if (state.form.floors < 1) errors.add('Ingresa al menos 1 planta.');
    return errors;
  }
}
