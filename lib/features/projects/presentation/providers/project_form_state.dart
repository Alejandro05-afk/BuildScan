// lib/features/projects/presentation/providers/project_form_state.dart

import '../../../calculation/domain/entities/project_dimensions.dart';

class ProjectFormState {
  final String nombre;
  final ElementType tipoConstruccion;
  final double largo;
  final double ancho;
  /// Nullable: null for floors and slabs.
  final double? alto;
  /// Nullable: only for concrete slabs.
  final double? thickness;
  final int? doors;
  final int? windows;
  final String? blockType;
  final double? tileWidth;
  final double? tileLength;
  final String? installationType;
  final String? concreteType;
  final String? roofType;
  final double? roofSlope;
  final double? eave;
  final String? finishType;
  final double desperdicio;
  final bool isValid;

  const ProjectFormState({
    this.nombre = '',
    this.tipoConstruccion = ElementType.wall,
    this.largo = 0,
    this.ancho = 0,
    this.alto,
    this.thickness,
    this.doors,
    this.windows,
    this.blockType,
    this.tileWidth,
    this.tileLength,
    this.installationType,
    this.concreteType,
    this.roofType,
    this.roofSlope,
    this.eave,
    this.finishType,
    this.desperdicio = 10,
    this.isValid = false,
  });

  static const _unset = Object();

  ProjectFormState copyWith({
    String? nombre,
    ElementType? tipoConstruccion,
    double? largo,
    double? ancho,
    Object? alto = _unset,
    Object? thickness = _unset,
    Object? doors = _unset,
    Object? windows = _unset,
    Object? blockType = _unset,
    Object? tileWidth = _unset,
    Object? tileLength = _unset,
    Object? installationType = _unset,
    Object? concreteType = _unset,
    Object? roofType = _unset,
    Object? roofSlope = _unset,
    Object? eave = _unset,
    Object? finishType = _unset,
    double? desperdicio,
    bool? isValid,
  }) {
    return ProjectFormState(
      nombre: nombre ?? this.nombre,
      tipoConstruccion: tipoConstruccion ?? this.tipoConstruccion,
      largo: largo ?? this.largo,
      ancho: ancho ?? this.ancho,
      alto: identical(alto, _unset) ? this.alto : alto as double?,
      thickness: identical(thickness, _unset) ? this.thickness : thickness as double?,
      doors: identical(doors, _unset) ? this.doors : doors as int?,
      windows: identical(windows, _unset) ? this.windows : windows as int?,
      blockType: identical(blockType, _unset) ? this.blockType : blockType as String?,
      tileWidth: identical(tileWidth, _unset) ? this.tileWidth : tileWidth as double?,
      tileLength: identical(tileLength, _unset) ? this.tileLength : tileLength as double?,
      installationType: identical(installationType, _unset)
          ? this.installationType
          : installationType as String?,
      concreteType:
          identical(concreteType, _unset) ? this.concreteType : concreteType as String?,
      roofType: identical(roofType, _unset) ? this.roofType : roofType as String?,
      roofSlope: identical(roofSlope, _unset) ? this.roofSlope : roofSlope as double?,
      eave: identical(eave, _unset) ? this.eave : eave as double?,
      finishType: identical(finishType, _unset) ? this.finishType : finishType as String?,
      desperdicio: desperdicio ?? this.desperdicio,
      isValid: isValid ?? this.isValid,
    );
  }

  /// Converts state to a ProjectDimensions domain object.
  ProjectDimensions toDimensions() {
    return ProjectDimensions(
      elementType: tipoConstruccion,
      largo: largo,
      ancho: ancho,
      alto: alto,
      thickness: thickness,
      doors: doors,
      windows: windows,
      blockType: blockType,
      tileWidth: tileWidth,
      tileLength: tileLength,
      installationType: installationType,
      concreteType: concreteType,
      roofType: roofType,
      roofSlope: roofSlope,
      eave: eave,
      finishType: finishType,
      porcentajeDesperdicio: desperdicio,
    );
  }
}
