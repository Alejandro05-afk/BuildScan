import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../calculation/domain/entities/project_dimensions.dart';
import '../../../calculation/domain/entities/material_estimate.dart';
import '../../../calculation/domain/services/material_calculation_engine.dart';
import 'project_form_state.dart';

class ProjectFormNotifier extends Notifier<ProjectFormState> {
  @override
  ProjectFormState build() => const ProjectFormState();

  void updateNombre(String value) {
    state = state.copyWith(nombre: value, isValid: _validate(nombre: value));
  }

  void updateTipo(ConstructionType value) {
    state = state.copyWith(tipoConstruccion: value);
  }

  void updateMedidas({double? largo, double? ancho, double? alto}) {
    final next = state.copyWith(
      largo: largo ?? state.largo,
      ancho: ancho ?? state.ancho,
      alto: alto ?? state.alto,
    );
    state = next.copyWith(isValid: _validate(state: next));
  }

  void updateDesperdicio(double value) {
    state = state.copyWith(desperdicio: value);
  }

  bool _validate({ProjectFormState? state, String? nombre}) {
    final current = state ?? this.state.copyWith(nombre: nombre);
    return current.nombre.trim().isNotEmpty &&
        current.largo > 0 &&
        current.ancho > 0;
  }
}

final projectFormProvider =
    NotifierProvider<ProjectFormNotifier, ProjectFormState>(() {
  return ProjectFormNotifier();
});

final calculationResultProvider = Provider<CalculationResult?>((ref) {
  final form = ref.watch(projectFormProvider);
  if (!form.isValid) return null;

  final engine = MaterialCalculationEngine();
  return engine.calculate(
    type: form.tipoConstruccion,
    dimensions: ProjectDimensions(
      largo: form.largo,
      ancho: form.ancho,
      alto: form.alto,
    ),
    wastePercentage: form.desperdicio,
  );
});
