// lib/features/projects/presentation/providers/project_form_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../calculation/domain/entities/project_dimensions.dart';
import '../../../calculation/domain/entities/material_estimate.dart';
import '../../../calculation/domain/services/material_calculation_engine.dart';
import '../../../projects/domain/policies/element_type_policy.dart';
import 'project_form_state.dart';

class ProjectFormNotifier extends Notifier<ProjectFormState> {
  @override
  ProjectFormState build() => const ProjectFormState();

  void updateNombre(String value) {
    final next = state.copyWith(nombre: value);
    state = next.copyWith(isValid: _validate(next));
  }

  /// Changes the element type and clears all fields incompatible with the new type.
  void changeElementType(ElementType value) {
    final cfg = configForElementType(value);

    // Build a new cleared state using sentinel nulls for incompatible fields.
    final next = state.copyWith(
      tipoConstruccion: value,
      largo: state.largo,
      ancho: cfg.isVisible(ElementField.width) ? state.ancho : 0.0,
      alto: cfg.isVisible(ElementField.wallHeight) ? state.alto : null,
      thickness: cfg.isVisible(ElementField.thickness) ? state.thickness : null,
      doors: cfg.isVisible(ElementField.doors) ? state.doors : null,
      windows: cfg.isVisible(ElementField.windows) ? state.windows : null,
      blockType: cfg.isVisible(ElementField.blockType) ? state.blockType : null,
      tileWidth: cfg.isVisible(ElementField.tileWidth) ? state.tileWidth : null,
      tileLength: cfg.isVisible(ElementField.tileLength) ? state.tileLength : null,
      installationType:
          cfg.isVisible(ElementField.installationType) ? state.installationType : null,
      concreteType: cfg.isVisible(ElementField.concreteType) ? state.concreteType : null,
      roofType: cfg.isVisible(ElementField.roofType) ? state.roofType : null,
      roofSlope: cfg.isVisible(ElementField.roofSlope) ? state.roofSlope : null,
      eave: cfg.isVisible(ElementField.eave) ? state.eave : null,
      finishType: cfg.isVisible(ElementField.finishType) ? state.finishType : null,
    );
    state = next.copyWith(isValid: _validate(next));
  }

  void updateMedidas({double? largo, double? ancho, double? alto}) {
    final next = state.copyWith(
      largo: largo ?? state.largo,
      ancho: ancho ?? state.ancho,
      alto: alto ?? state.alto, // Preserve previous alto if not passed
    );
    state = next.copyWith(isValid: _validate(next));
  }

  void updateThickness(double? value) {
    final next = state.copyWith(thickness: value);
    state = next.copyWith(isValid: _validate(next));
  }

  void updateDoors(int? value) {
    final next = state.copyWith(doors: value);
    state = next.copyWith(isValid: _validate(next));
  }

  void updateWindows(int? value) {
    final next = state.copyWith(windows: value);
    state = next.copyWith(isValid: _validate(next));
  }

  void updateDesperdicio(double value) {
    final clamped = value.clamp(0.0, 30.0);
    final next = state.copyWith(desperdicio: clamped);
    state = next.copyWith(isValid: _validate(next));
  }

  void updateStringField({
    String? blockType,
    String? concreteType,
    String? roofType,
    String? installationType,
    String? finishType,
    double? roofSlope,
    double? eave,
    double? tileWidth,
    double? tileLength,
  }) {
    ProjectFormState next = state;
    if (blockType != null) next = next.copyWith(blockType: blockType);
    if (concreteType != null) next = next.copyWith(concreteType: concreteType);
    if (roofType != null) next = next.copyWith(roofType: roofType);
    if (installationType != null) next = next.copyWith(installationType: installationType);
    if (finishType != null) next = next.copyWith(finishType: finishType);
    if (roofSlope != null) next = next.copyWith(roofSlope: roofSlope);
    if (eave != null) next = next.copyWith(eave: eave);
    if (tileWidth != null) next = next.copyWith(tileWidth: tileWidth);
    if (tileLength != null) next = next.copyWith(tileLength: tileLength);
    state = next.copyWith(isValid: _validate(next));
  }

  bool _validate(ProjectFormState s) {
    if (s.nombre.trim().isEmpty) return false;
    if (s.desperdicio < 0 || s.desperdicio > 30) return false;
    if (s.largo <= 0) return false;

    final cfg = configForElementType(s.tipoConstruccion);

    if (cfg.isRequired(ElementField.width) && s.ancho <= 0) return false;
    if (cfg.isRequired(ElementField.wallHeight) && (s.alto == null || s.alto! <= 0)) return false;
    if (cfg.isRequired(ElementField.thickness) &&
        (s.thickness == null || s.thickness! <= 0)) {
      return false;
    }
    if (cfg.isRequired(ElementField.roofType) &&
        (s.roofType == null || s.roofType!.isEmpty)) {
      return false;
    }

    return true;
  }
}

final projectFormProvider =
    NotifierProvider<ProjectFormNotifier, ProjectFormState>(ProjectFormNotifier.new);

final calculationResultProvider = Provider<CalculationResult?>((ref) {
  final form = ref.watch(projectFormProvider);
  if (!form.isValid) return null;

  final engine = MaterialCalculationEngine();
  return engine.calculate(
    dimensions: form.toDimensions(),
    wastePercentage: form.desperdicio,
  );
});
