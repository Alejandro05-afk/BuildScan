import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../calculation/domain/entities/project_dimensions.dart';
import '../../../calculation/domain/entities/material_estimate.dart';
import '../../../calculation/domain/services/material_calculation_engine.dart';
import 'project_form_state.dart';

class ProjectFormNotifier extends Notifier<ProjectFormState> {
  @override
  ProjectFormState build() => const ProjectFormState();

  void updateNombre(String value) {
    final next = state.copyWith(nombre: value);
    state = next.copyWith(isValid: _validate(next));
  }

  void updateTipo(ConstructionType value) {
    final next = state.copyWith(tipoConstruccion: value);
    state = next.copyWith(isValid: _validate(next));
  }

  void updateMedidas({double? largo, double? ancho, double? alto}) {
    final next = state.copyWith(
      largo: largo ?? state.largo,
      ancho: ancho ?? state.ancho,
      alto: alto ?? state.alto,
    );
    state = next.copyWith(isValid: _validate(next));
  }

  void updateDesperdicio(double value) {
    double clamped = value;
    if (clamped < 0) clamped = 0;
    if (clamped > 30) clamped = 30;
    final next = state.copyWith(desperdicio: clamped);
    state = next.copyWith(isValid: _validate(next));
  }

  bool _validate(ProjectFormState current) {
    if (current.nombre.trim().isEmpty) return false;
    if (current.desperdicio < 0 || current.desperdicio > 30) return false;

    switch (current.tipoConstruccion) {
      case ConstructionType.paredLadrillo:
        return current.largo > 0 && current.alto > 0;
      case ConstructionType.losaHormigon:
      case ConstructionType.pisoCeramico:
        return current.largo > 0 && current.ancho > 0;
      case ConstructionType.cuartoBasico:
        return current.largo > 0 && current.ancho > 0 && current.alto > 0;
    }
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
