// lib/features/projects/domain/policies/element_type_policy.dart
//
// Central policy for simple construction elements (walls, floors, slabs, rooms, roofs).
// Defines which fields are visible, required, their semantic labels, units,
// and whether to clear them when the element type changes.
// All layers must consult this file.

/// Semantic element types replacing the old ConstructionType enum.
/// The [dbValue] extension provides retrocompatible DB keys.
enum ElementType {
  wall,         // Pared
  ceramicFloor, // Piso cerámico
  concreteSlab, // Losa de hormigón
  room,         // Cuarto / habitación básica
  roof,         // Techo / cubierta
}

extension ElementTypeDb on ElementType {
  /// Stable DB key – never changes even if enum name changes.
  String get dbValue {
    switch (this) {
      case ElementType.wall:         return 'wall';
      case ElementType.ceramicFloor: return 'ceramic_floor';
      case ElementType.concreteSlab: return 'concrete_slab';
      case ElementType.room:         return 'room';
      case ElementType.roof:         return 'roof';
    }
  }

  /// Retrocompatible parser – handles old Spanish keys from Supabase.
  static ElementType fromDbValue(String? value) {
    switch (value) {
      case 'wall':
      case 'paredLadrillo':
      case 'pared_ladrillo':
      case 'pared':
        return ElementType.wall;
      case 'ceramic_floor':
      case 'pisoCeramico':
      case 'piso_ceramico':
      case 'piso':
        return ElementType.ceramicFloor;
      case 'concrete_slab':
      case 'losaHormigon':
      case 'losa_hormigon':
      case 'losa':
        return ElementType.concreteSlab;
      case 'room':
      case 'cuartoBasico':
      case 'cuarto_basico':
      case 'cuarto':
        return ElementType.room;
      case 'roof':
      case 'techo':
        return ElementType.roof;
      default:
        return ElementType.wall; // safe fallback for legacy data
    }
  }

  String get displayLabel {
    switch (this) {
      case ElementType.wall:         return 'Pared';
      case ElementType.ceramicFloor: return 'Piso cerámico';
      case ElementType.concreteSlab: return 'Losa de hormigón';
      case ElementType.room:         return 'Cuarto básico';
      case ElementType.roof:         return 'Techo / Cubierta';
    }
  }
}

// ---------------------------------------------------------------------------
// Fields for simple elements
// ---------------------------------------------------------------------------

/// Fields that may appear in a simple construction element form.
enum ElementField {
  length,           // Largo (m)
  width,            // Ancho (m)
  wallHeight,       // Altura de pared (m)  – wall & room only
  thickness,        // Espesor (m)          – concreteSlab only
  doors,            // Número de puertas    – wall & room
  windows,          // Número de ventanas   – wall & room
  blockType,        // Tipo de bloque/ladrillo – wall
  tileWidth,        // Ancho de baldosa (m) – ceramicFloor
  tileLength,       // Largo de baldosa (m) – ceramicFloor
  installationType, // Tipo de instalación  – ceramicFloor (optional)
  concreteType,     // Tipo de hormigón     – concreteSlab (optional)
  roofType,         // Tipo de cubierta     – roof
  roofSlope,        // Pendiente (%)        – roof (optional)
  eave,             // Alero (m)            – roof (optional)
  finishType,       // Tipo de acabado      – room (optional)
  wastePercentage,  // Desperdicio (%)
}

class ElementFieldRule {
  final bool visible;
  final bool required;
  final bool clearWhenHidden;
  final String label;
  final String? unit;
  final num? min;
  final num? max;

  const ElementFieldRule({
    required this.visible,
    this.required = false,
    this.clearWhenHidden = true,
    required this.label,
    this.unit,
    this.min,
    this.max,
  });
}

class ElementTypeConfig {
  final Map<ElementField, ElementFieldRule> rules;

  const ElementTypeConfig({required this.rules});

  ElementFieldRule ruleFor(ElementField field) =>
      rules[field] ?? ElementFieldRule(visible: false, label: '');

  bool isVisible(ElementField field) => ruleFor(field).visible;
  bool isRequired(ElementField field) => ruleFor(field).required;
  String labelFor(ElementField field) => ruleFor(field).label;
  String? unitFor(ElementField field) => ruleFor(field).unit;

  Iterable<ElementField> get visibleFields =>
      rules.entries.where((e) => e.value.visible).map((e) => e.key);

  /// Fields that must be set to null when switching to this type.
  Iterable<ElementField> get fieldsToNull =>
      rules.entries.where((e) => !e.value.visible && e.value.clearWhenHidden).map((e) => e.key);

  /// Build a sanitized technical details map from a raw map.
  /// Only includes keys for visible fields mapped to [_technicalDetailsKeys].
  Map<String, dynamic> sanitizeTechnicalDetails(Map<String, dynamic> raw) {
    final result = <String, dynamic>{};
    for (final entry in rules.entries) {
      final key = _technicalDetailsKey(entry.key);
      if (key == null) continue;
      if (entry.value.visible && raw.containsKey(key)) {
        result[key] = raw[key];
      }
      // invisible fields are deliberately excluded
    }
    return result;
  }
}

/// Maps ElementField → jsonb key in `detalles_tecnicos`.
/// Fields stored as regular columns are excluded (return null).
String? _technicalDetailsKey(ElementField field) {
  switch (field) {
    case ElementField.thickness:        return 'thickness';
    case ElementField.doors:            return 'doors';
    case ElementField.windows:          return 'windows';
    case ElementField.blockType:        return 'blockType';
    case ElementField.tileWidth:        return 'tileWidth';
    case ElementField.tileLength:       return 'tileLength';
    case ElementField.installationType: return 'installationType';
    case ElementField.concreteType:     return 'concreteType';
    case ElementField.roofType:         return 'roofType';
    case ElementField.roofSlope:        return 'roofSlope';
    case ElementField.eave:             return 'eave';
    case ElementField.finishType:       return 'finishType';
    // stored as main columns – not in jsonb:
    case ElementField.length:
    case ElementField.width:
    case ElementField.wallHeight:
    case ElementField.wastePercentage:
      return null;
  }
}

// ---------------------------------------------------------------------------
// Configuration per element type
// ---------------------------------------------------------------------------

const Map<ElementType, ElementTypeConfig> elementTypePolicy = {
  ElementType.wall: ElementTypeConfig(rules: {
    ElementField.length: ElementFieldRule(
      visible: true, required: true, label: 'Largo de la pared', unit: 'm', min: 0.1),
    ElementField.width: ElementFieldRule(
      visible: false, label: 'Ancho', clearWhenHidden: true),
    ElementField.wallHeight: ElementFieldRule(
      visible: true, required: true, label: 'Altura de la pared', unit: 'm', min: 0.5, max: 15),
    ElementField.thickness: ElementFieldRule(
      visible: true, required: false, label: 'Espesor de pared', unit: 'm', min: 0.05, max: 0.6),
    ElementField.doors: ElementFieldRule(
      visible: true, required: false, label: 'Número de puertas', min: 0, max: 20),
    ElementField.windows: ElementFieldRule(
      visible: true, required: false, label: 'Número de ventanas', min: 0, max: 30),
    ElementField.blockType: ElementFieldRule(
      visible: true, required: false, label: 'Tipo de bloque/ladrillo'),
    ElementField.tileWidth:        ElementFieldRule(visible: false, label: 'Ancho baldosa', clearWhenHidden: true),
    ElementField.tileLength:       ElementFieldRule(visible: false, label: 'Largo baldosa', clearWhenHidden: true),
    ElementField.installationType: ElementFieldRule(visible: false, label: 'Instalación', clearWhenHidden: true),
    ElementField.concreteType:     ElementFieldRule(visible: false, label: 'Tipo hormigón', clearWhenHidden: true),
    ElementField.roofType:         ElementFieldRule(visible: false, label: 'Tipo cubierta', clearWhenHidden: true),
    ElementField.roofSlope:        ElementFieldRule(visible: false, label: 'Pendiente', clearWhenHidden: true),
    ElementField.eave:             ElementFieldRule(visible: false, label: 'Alero', clearWhenHidden: true),
    ElementField.finishType:       ElementFieldRule(visible: false, label: 'Acabado', clearWhenHidden: true),
    ElementField.wastePercentage:  ElementFieldRule(
      visible: true, required: false, label: 'Desperdicio', unit: '%', min: 0, max: 30),
  }),

  ElementType.ceramicFloor: ElementTypeConfig(rules: {
    ElementField.length: ElementFieldRule(
      visible: true, required: true, label: 'Largo del piso', unit: 'm', min: 0.1),
    ElementField.width: ElementFieldRule(
      visible: true, required: true, label: 'Ancho del piso', unit: 'm', min: 0.1),
    ElementField.wallHeight:       ElementFieldRule(visible: false, label: 'Altura', clearWhenHidden: true),
    ElementField.thickness:        ElementFieldRule(visible: false, label: 'Espesor', clearWhenHidden: true),
    ElementField.doors:            ElementFieldRule(visible: false, label: 'Puertas', clearWhenHidden: true),
    ElementField.windows:          ElementFieldRule(visible: false, label: 'Ventanas', clearWhenHidden: true),
    ElementField.blockType:        ElementFieldRule(visible: false, label: 'Tipo bloque', clearWhenHidden: true),
    ElementField.tileWidth: ElementFieldRule(
      visible: true, required: false, label: 'Ancho de baldosa', unit: 'm', min: 0.05),
    ElementField.tileLength: ElementFieldRule(
      visible: true, required: false, label: 'Largo de baldosa', unit: 'm', min: 0.05),
    ElementField.installationType: ElementFieldRule(
      visible: true, required: false, label: 'Tipo de instalación'),
    ElementField.concreteType:     ElementFieldRule(visible: false, label: 'Tipo hormigón', clearWhenHidden: true),
    ElementField.roofType:         ElementFieldRule(visible: false, label: 'Tipo cubierta', clearWhenHidden: true),
    ElementField.roofSlope:        ElementFieldRule(visible: false, label: 'Pendiente', clearWhenHidden: true),
    ElementField.eave:             ElementFieldRule(visible: false, label: 'Alero', clearWhenHidden: true),
    ElementField.finishType:       ElementFieldRule(visible: false, label: 'Acabado', clearWhenHidden: true),
    ElementField.wastePercentage:  ElementFieldRule(
      visible: true, required: false, label: 'Desperdicio', unit: '%', min: 0, max: 30),
  }),

  ElementType.concreteSlab: ElementTypeConfig(rules: {
    ElementField.length: ElementFieldRule(
      visible: true, required: true, label: 'Largo de la losa', unit: 'm', min: 0.1),
    ElementField.width: ElementFieldRule(
      visible: true, required: true, label: 'Ancho de la losa', unit: 'm', min: 0.1),
    ElementField.wallHeight:       ElementFieldRule(visible: false, label: 'Altura habitación', clearWhenHidden: true),
    ElementField.thickness: ElementFieldRule(
      visible: true, required: true, label: 'Espesor de la losa', unit: 'm', min: 0.08, max: 0.50),
    ElementField.doors:            ElementFieldRule(visible: false, label: 'Puertas', clearWhenHidden: true),
    ElementField.windows:          ElementFieldRule(visible: false, label: 'Ventanas', clearWhenHidden: true),
    ElementField.blockType:        ElementFieldRule(visible: false, label: 'Tipo bloque', clearWhenHidden: true),
    ElementField.tileWidth:        ElementFieldRule(visible: false, label: 'Ancho baldosa', clearWhenHidden: true),
    ElementField.tileLength:       ElementFieldRule(visible: false, label: 'Largo baldosa', clearWhenHidden: true),
    ElementField.installationType: ElementFieldRule(visible: false, label: 'Instalación', clearWhenHidden: true),
    ElementField.concreteType: ElementFieldRule(
      visible: true, required: false, label: 'Tipo de hormigón'),
    ElementField.roofType:         ElementFieldRule(visible: false, label: 'Tipo cubierta', clearWhenHidden: true),
    ElementField.roofSlope:        ElementFieldRule(visible: false, label: 'Pendiente', clearWhenHidden: true),
    ElementField.eave:             ElementFieldRule(visible: false, label: 'Alero', clearWhenHidden: true),
    ElementField.finishType:       ElementFieldRule(visible: false, label: 'Acabado', clearWhenHidden: true),
    ElementField.wastePercentage:  ElementFieldRule(
      visible: true, required: false, label: 'Desperdicio', unit: '%', min: 0, max: 30),
  }),

  ElementType.room: ElementTypeConfig(rules: {
    ElementField.length: ElementFieldRule(
      visible: true, required: true, label: 'Largo del cuarto', unit: 'm', min: 0.1),
    ElementField.width: ElementFieldRule(
      visible: true, required: true, label: 'Ancho del cuarto', unit: 'm', min: 0.1),
    ElementField.wallHeight: ElementFieldRule(
      visible: true, required: true, label: 'Altura interior', unit: 'm', min: 2.0, max: 6.0),
    ElementField.thickness:        ElementFieldRule(visible: false, label: 'Espesor losa', clearWhenHidden: true),
    ElementField.doors: ElementFieldRule(
      visible: true, required: false, label: 'Número de puertas', min: 0, max: 10),
    ElementField.windows: ElementFieldRule(
      visible: true, required: false, label: 'Número de ventanas', min: 0, max: 20),
    ElementField.blockType:        ElementFieldRule(visible: false, label: 'Tipo bloque', clearWhenHidden: true),
    ElementField.tileWidth:        ElementFieldRule(visible: false, label: 'Ancho baldosa', clearWhenHidden: true),
    ElementField.tileLength:       ElementFieldRule(visible: false, label: 'Largo baldosa', clearWhenHidden: true),
    ElementField.installationType: ElementFieldRule(visible: false, label: 'Instalación', clearWhenHidden: true),
    ElementField.concreteType:     ElementFieldRule(visible: false, label: 'Tipo hormigón', clearWhenHidden: true),
    ElementField.roofType:         ElementFieldRule(visible: false, label: 'Tipo cubierta', clearWhenHidden: true),
    ElementField.roofSlope:        ElementFieldRule(visible: false, label: 'Pendiente', clearWhenHidden: true),
    ElementField.eave:             ElementFieldRule(visible: false, label: 'Alero', clearWhenHidden: true),
    ElementField.finishType: ElementFieldRule(
      visible: true, required: false, label: 'Tipo de acabado'),
    ElementField.wastePercentage:  ElementFieldRule(
      visible: true, required: false, label: 'Desperdicio', unit: '%', min: 0, max: 30),
  }),

  ElementType.roof: ElementTypeConfig(rules: {
    ElementField.length: ElementFieldRule(
      visible: true, required: true, label: 'Largo del techo', unit: 'm', min: 0.1),
    ElementField.width: ElementFieldRule(
      visible: true, required: true, label: 'Ancho del techo', unit: 'm', min: 0.1),
    ElementField.wallHeight:       ElementFieldRule(visible: false, label: 'Altura habitación', clearWhenHidden: true),
    ElementField.thickness:        ElementFieldRule(visible: false, label: 'Espesor', clearWhenHidden: true),
    ElementField.doors:            ElementFieldRule(visible: false, label: 'Puertas', clearWhenHidden: true),
    ElementField.windows:          ElementFieldRule(visible: false, label: 'Ventanas', clearWhenHidden: true),
    ElementField.blockType:        ElementFieldRule(visible: false, label: 'Tipo bloque', clearWhenHidden: true),
    ElementField.tileWidth:        ElementFieldRule(visible: false, label: 'Ancho baldosa', clearWhenHidden: true),
    ElementField.tileLength:       ElementFieldRule(visible: false, label: 'Largo baldosa', clearWhenHidden: true),
    ElementField.installationType: ElementFieldRule(visible: false, label: 'Instalación', clearWhenHidden: true),
    ElementField.concreteType:     ElementFieldRule(visible: false, label: 'Tipo hormigón', clearWhenHidden: true),
    ElementField.roofType: ElementFieldRule(
      visible: true, required: true, label: 'Tipo de cubierta'),
    ElementField.roofSlope: ElementFieldRule(
      visible: true, required: false, label: 'Pendiente', unit: '%', min: 0, max: 100),
    ElementField.eave: ElementFieldRule(
      visible: true, required: false, label: 'Alero', unit: 'm', min: 0, max: 5),
    ElementField.finishType:       ElementFieldRule(visible: false, label: 'Acabado', clearWhenHidden: true),
    ElementField.wastePercentage:  ElementFieldRule(
      visible: true, required: false, label: 'Desperdicio', unit: '%', min: 0, max: 30),
  }),
};

/// Convenience accessor.
ElementTypeConfig configForElementType(ElementType type) {
  return elementTypePolicy[type] ?? elementTypePolicy[ElementType.wall]!;
}
