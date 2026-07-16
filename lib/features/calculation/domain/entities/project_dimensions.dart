// lib/features/calculation/domain/entities/project_dimensions.dart
//
// Extended project dimensions for simple construction elements.
// Uses the new ElementType (retrocompatible with old ConstructionType values).

import '../../../projects/domain/policies/element_type_policy.dart';

export '../../../projects/domain/policies/element_type_policy.dart'
    show ElementType, ElementField, ElementFieldRule, ElementTypeConfig,
         elementTypePolicy, configForElementType;

// ─── Legacy alias ─────────────────────────────────────────────────────────
// Kept so existing code that still imports ConstructionType from here
// does not break immediately. Remove once all callers are migrated.

/// @deprecated Use [ElementType] instead.
typedef ConstructionType = ElementType;

// ─── Dimensions ───────────────────────────────────────────────────────────

/// Holds all measurable fields for a simple construction element.
/// Fields are nullable – only those allowed by [ElementTypePolicy] will be set.
class ProjectDimensions {
  final ElementType elementType;
  final double largo;   // length (m) – all types
  final double ancho;   // width  (m) – floor, slab, room, roof
  /// Used as wall height for [ElementType.wall] and room height for [ElementType.room].
  /// Null for floors, slabs, and roofs (use [thickness] for slabs).
  final double? alto;
  /// Slab thickness in meters. Only valid for [ElementType.concreteSlab].
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
  final double porcentajeDesperdicio;

  const ProjectDimensions({
    required this.elementType,
    required this.largo,
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
    this.porcentajeDesperdicio = 10,
  });

  // ── Computed areas ───────────────────────────────────────────────────────

  /// Horizontal floor area (m²).
  double get areaPiso => largo * ancho;

  /// Wall area using [alto] (m²). Only valid for walls and rooms.
  double get areaPared => largo * (alto ?? 0);

  /// Slab volume (m³). Only valid for concrete slabs.
  double get volumenLosa => largo * ancho * (thickness ?? 0);

  // ── Technical details for Supabase jsonb column ──────────────────────────

  Map<String, dynamic> toTechnicalDetails() {
    final policy = configForElementType(elementType);
    return policy.sanitizeTechnicalDetails({
      if (thickness != null) 'thickness': thickness,
      if (doors != null) 'doors': doors,
      if (windows != null) 'windows': windows,
      if (blockType != null) 'blockType': blockType,
      if (tileWidth != null) 'tileWidth': tileWidth,
      if (tileLength != null) 'tileLength': tileLength,
      if (installationType != null) 'installationType': installationType,
      if (concreteType != null) 'concreteType': concreteType,
      if (roofType != null) 'roofType': roofType,
      if (roofSlope != null) 'roofSlope': roofSlope,
      if (eave != null) 'eave': eave,
      if (finishType != null) 'finishType': finishType,
    });
  }

  // ── copyWith with sentinel ────────────────────────────────────────────────

  static const _unset = Object();

  ProjectDimensions copyWith({
    ElementType? elementType,
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
    double? porcentajeDesperdicio,
  }) {
    return ProjectDimensions(
      elementType: elementType ?? this.elementType,
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
      porcentajeDesperdicio: porcentajeDesperdicio ?? this.porcentajeDesperdicio,
    );
  }

  /// Returns a new instance with fields incompatible with [newType] set to null.
  ProjectDimensions withElementType(ElementType newType) {
    final cfg = configForElementType(newType);
    return copyWith(
      elementType: newType,
      alto: cfg.isVisible(ElementField.wallHeight) ? alto : null,
      thickness: cfg.isVisible(ElementField.thickness) ? thickness : null,
      doors: cfg.isVisible(ElementField.doors) ? doors : null,
      windows: cfg.isVisible(ElementField.windows) ? windows : null,
      blockType: cfg.isVisible(ElementField.blockType) ? blockType : null,
      tileWidth: cfg.isVisible(ElementField.tileWidth) ? tileWidth : null,
      tileLength: cfg.isVisible(ElementField.tileLength) ? tileLength : null,
      installationType: cfg.isVisible(ElementField.installationType) ? installationType : null,
      concreteType: cfg.isVisible(ElementField.concreteType) ? concreteType : null,
      roofType: cfg.isVisible(ElementField.roofType) ? roofType : null,
      roofSlope: cfg.isVisible(ElementField.roofSlope) ? roofSlope : null,
      eave: cfg.isVisible(ElementField.eave) ? eave : null,
      finishType: cfg.isVisible(ElementField.finishType) ? finishType : null,
    );
  }

  // ── Factory from Supabase row ─────────────────────────────────────────────

  factory ProjectDimensions.fromMap(Map<String, dynamic> map) {
    final elementType = ElementTypeDb.fromDbValue(map['tipo_construccion'] as String?);
    final rawDetails = (map['detalles_tecnicos'] as Map<String, dynamic>?) ?? {};

    return ProjectDimensions(
      elementType: elementType,
      largo: (map['largo'] as num?)?.toDouble() ?? 0,
      ancho: (map['ancho'] as num?)?.toDouble() ?? 0,
      alto: (map['alto'] as num?)?.toDouble(),
      thickness: (rawDetails['thickness'] as num?)?.toDouble(),
      doors: (rawDetails['doors'] as num?)?.toInt(),
      windows: (rawDetails['windows'] as num?)?.toInt(),
      blockType: rawDetails['blockType'] as String?,
      tileWidth: (rawDetails['tileWidth'] as num?)?.toDouble(),
      tileLength: (rawDetails['tileLength'] as num?)?.toDouble(),
      installationType: rawDetails['installationType'] as String?,
      concreteType: rawDetails['concreteType'] as String?,
      roofType: rawDetails['roofType'] as String?,
      roofSlope: (rawDetails['roofSlope'] as num?)?.toDouble(),
      eave: (rawDetails['eave'] as num?)?.toDouble(),
      finishType: rawDetails['finishType'] as String?,
      porcentajeDesperdicio:
          (map['porcentaje_desperdicio'] as num?)?.toDouble() ?? 10,
    );
  }

  Map<String, dynamic> toInsertMap({required String constructoraId, required String nombre}) {
    final cfg = configForElementType(elementType);
    return {
      'constructora_id': constructoraId,
      'nombre': nombre,
      'tipo_construccion': elementType.dbValue,
      'largo': largo,
      'ancho': cfg.isVisible(ElementField.width) ? ancho : 0.0,
      'alto': cfg.isVisible(ElementField.wallHeight) ? alto : null,
      'area': areaPiso,
      'area_m2': areaPiso,
      'porcentaje_desperdicio': porcentajeDesperdicio,
      'detalles_tecnicos': toTechnicalDetails(),
    };
  }

  /// Update map – sends null for incompatible columns to overwrite stale DB values.
  Map<String, dynamic> toUpdateMap({required String constructoraId, required String nombre}) {
    final map = toInsertMap(constructoraId: constructoraId, nombre: nombre);
    map.remove('id');
    return map;
  }
}
