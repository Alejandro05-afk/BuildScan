// test/features/projects/form_logic_test.dart
//
// Unit and domain logic tests for the form refactoring.
// Tests cover: policy rules, copyWith null semantics, type switching,
// serialization cleanup, and calculation correctness.

import 'package:flutter_test/flutter_test.dart';
import 'package:buildscan_app/features/projects/domain/entities/building_project.dart';
import 'package:buildscan_app/features/projects/domain/policies/element_type_policy.dart';
import 'package:buildscan_app/features/projects/data/models/building_project_mapper.dart';
import 'package:buildscan_app/features/calculation/domain/entities/project_dimensions.dart';

void main() {
  // ── Helpers ──────────────────────────────────────────────────────────────

  BuildingProject makeHouse({int? bedrooms, int? bathrooms}) => BuildingProject(
        constructoraId: 'test',
        name: 'Casa Test',
        buildingType: BuildingType.house,
        totalArea: 120,
        floors: 1,
        constructionSystem: ConstructionSystem.reinforcedConcrete,
        finishLevel: FinishLevel.standard,
        bedrooms: bedrooms ?? 3,
        bathrooms: bathrooms ?? 2,
      );

  BuildingProject makeWarehouse() => BuildingProject(
        constructoraId: 'test',
        name: 'Bodega Test',
        buildingType: BuildingType.warehouse,
        totalArea: 600,
        floors: 1,
        constructionSystem: ConstructionSystem.steelStructure,
        finishLevel: FinishLevel.basic,
        clearHeight: 7.0,
        administrativeArea: 45,
        loadingArea: 80,
      );

  // ── Policy visibility tests ───────────────────────────────────────────────

  group('BuildingTypePolicy – visibility', () {
    test('Casa muestra dormitorios y oculta altura libre', () {
      final cfg = configForType('house');
      expect(cfg.isVisible(BuildingField.bedrooms), isTrue);
      expect(cfg.isVisible(BuildingField.clearHeight), isFalse);
    });

    test('Bodega oculta dormitorios y muestra altura libre', () {
      final cfg = configForType('warehouse');
      expect(cfg.isVisible(BuildingField.bedrooms), isFalse);
      expect(cfg.isVisible(BuildingField.clearHeight), isTrue);
    });

    test('Oficina oculta dormitorios y muestra puestos de trabajo', () {
      final cfg = configForType('office');
      expect(cfg.isVisible(BuildingField.bedrooms), isFalse);
      expect(cfg.isVisible(BuildingField.workstations), isTrue);
    });

    test('Edificio residencial muestra departamentos por planta', () {
      final cfg = configForType('residentialBuilding');
      expect(cfg.isVisible(BuildingField.apartmentsPerFloor), isTrue);
    });

    test('Local comercial oculta dormitorios', () {
      final cfg = configForType('commercialSpace');
      expect(cfg.isVisible(BuildingField.bedrooms), isFalse);
    });
  });

  // ── ElementTypePolicy visibility tests ───────────────────────────────────

  group('ElementTypePolicy – visibility', () {
    test('Piso cerámico no muestra altura', () {
      final cfg = configForElementType(ElementType.ceramicFloor);
      expect(cfg.isVisible(ElementField.wallHeight), isFalse);
    });

    test('Losa muestra espesor y no muestra altura', () {
      final cfg = configForElementType(ElementType.concreteSlab);
      expect(cfg.isVisible(ElementField.thickness), isTrue);
      expect(cfg.isVisible(ElementField.wallHeight), isFalse);
    });

    test('Pared muestra altura y oculta espesor de losa', () {
      final cfg = configForElementType(ElementType.wall);
      expect(cfg.isVisible(ElementField.wallHeight), isTrue);
      // thickness for walls is optional/visible as wall thickness, not slab
    });

    test('Techo no muestra dormitorios ni puertas', () {
      final cfg = configForElementType(ElementType.roof);
      expect(cfg.isVisible(ElementField.doors), isFalse);
      expect(cfg.isVisible(ElementField.windows), isFalse);
    });
  });

  // ── copyWith null semantics ───────────────────────────────────────────────

  group('BuildingProject.copyWith – sentinel null', () {
    test('copyWith permite limpiar dormitorios con null', () {
      final house = makeHouse(bedrooms: 3);
      final modified = house.copyWith(bedrooms: null);
      expect(modified.bedrooms, isNull);
    });

    test('copyWith sin argumento preserva el valor anterior', () {
      final house = makeHouse(bedrooms: 3);
      final modified = house.copyWith(name: 'Nuevo nombre');
      expect(modified.bedrooms, equals(3));
    });

    test('copyWith permite limpiar clearHeight con null', () {
      final warehouse = makeWarehouse();
      final modified = warehouse.copyWith(clearHeight: null);
      expect(modified.clearHeight, isNull);
    });
  });

  // ── Type switching cleans incompatible fields ────────────────────────────

  group('BuildingProject.withType() – limpieza de campos', () {
    test('Cambiar casa a bodega limpia dormitorios', () {
      final house = makeHouse(bedrooms: 3);
      final warehouse = house.withType(BuildingType.warehouse);
      expect(warehouse.bedrooms, isNull);
      expect(warehouse.buildingType, equals(BuildingType.warehouse));
    });

    test('Cambiar bodega a casa limpia clearHeight', () {
      final warehouse = makeWarehouse();
      final house = warehouse.withType(BuildingType.house);
      expect(house.clearHeight, isNull);
      expect(house.buildingType, equals(BuildingType.house));
    });

    test('Cambiar a bodega preserva numberOfFloors', () {
      final house = makeHouse().copyWith(floors: 2);
      final warehouse = house.withType(BuildingType.warehouse);
      expect(warehouse.floors, equals(2));
    });
  });

  // ── Serialization – BuildingProjectMapper ───────────────────────────────

  group('BuildingProjectMapper – serialización', () {
    test('toUpdateMap de bodega envía dormitorios: null', () {
      final warehouse = makeWarehouse();
      final map = BuildingProjectMapper.toUpdateMap(warehouse);
      expect(map['bedrooms'], isNull);
    });

    test('toInsertMap de casa incluye dormitorios', () {
      final house = makeHouse(bedrooms: 3);
      final map = BuildingProjectMapper.toInsertMap(house);
      expect(map['bedrooms'], equals(3));
    });

    test('toUpdateMap de bodega envía clear_height', () {
      final warehouse = makeWarehouse();
      final map = BuildingProjectMapper.toUpdateMap(warehouse);
      expect(map['clear_height'], equals(7.0));
    });

    test('fromMap retrocompatible con project_scope faltante', () {
      final map = {
        'id': '123',
        'constructora_id': 'c1',
        'nombre': 'Proyecto',
        'building_type': 'house',
        'total_area': 100.0,
        'floors': 1,
        'floor_height': 2.6,
        'construction_system': 'reinforcedConcrete',
        'finish_level': 'standard',
        'waste_percentage': 10.0,
        'has_roof_slab': true,
        'has_exterior_walls': true,
        'bedrooms': 3,
      };
      final project = BuildingProjectMapper.fromMap(map);
      expect(project.buildingType, equals(BuildingType.house));
      expect(project.bedrooms, equals(3));
    });

    test('fromMap de bodega ignora dormitorios residuales', () {
      final map = {
        'id': '456',
        'constructora_id': 'c1',
        'nombre': 'Bodega',
        'building_type': 'warehouse',
        'total_area': 600.0,
        'floors': 1,
        'floor_height': 2.6,
        'construction_system': 'steelStructure',
        'finish_level': 'basic',
        'waste_percentage': 5.0,
        'has_roof_slab': true,
        'has_exterior_walls': true,
        // Stale residual data from a previous type:
        'bedrooms': 3,
        'clear_height': 7.0,
      };
      final project = BuildingProjectMapper.fromMap(map);
      // bedrooms should be null because policy hides it for warehouses
      expect(project.bedrooms, isNull);
      expect(project.clearHeight, equals(7.0));
    });
  });

  // ── ElementType retrocompatibility ───────────────────────────────────────

  group('ElementType – retrocompatibilidad DB', () {
    test('Parsea valor antiguo paredLadrillo → wall', () {
      final type = ElementTypeDb.fromDbValue('paredLadrillo');
      expect(type, equals(ElementType.wall));
    });

    test('Parsea valor antiguo losaHormigon → concreteSlab', () {
      final type = ElementTypeDb.fromDbValue('losaHormigon');
      expect(type, equals(ElementType.concreteSlab));
    });

    test('Parsea valor antiguo pisoCeramico → ceramicFloor', () {
      final type = ElementTypeDb.fromDbValue('pisoCeramico');
      expect(type, equals(ElementType.ceramicFloor));
    });

    test('Parsea valor nuevo wall → wall', () {
      final type = ElementTypeDb.fromDbValue('wall');
      expect(type, equals(ElementType.wall));
    });

    test('Valor desconocido devuelve wall (fallback seguro)', () {
      final type = ElementTypeDb.fromDbValue('valor_inexistente');
      expect(type, equals(ElementType.wall));
    });
  });

  // ── ProjectDimensions – cálculos correctos ───────────────────────────────

  group('ProjectDimensions – cálculos semánticos', () {
    test('Losa calcula volumen con espesor, no con alto', () {
      final dim = ProjectDimensions(
        elementType: ElementType.concreteSlab,
        largo: 10,
        ancho: 8,
        thickness: 0.12,
      );
      expect(dim.volumenLosa, closeTo(9.6, 0.01));
    });

    test('Pared calcula área con alto (wallHeight)', () {
      final dim = ProjectDimensions(
        elementType: ElementType.wall,
        largo: 5,
        alto: 2.8,
      );
      expect(dim.areaPared, closeTo(14.0, 0.01));
    });

    test('Piso cerámico alto es null', () {
      final dim = ProjectDimensions(
        elementType: ElementType.ceramicFloor,
        largo: 4,
        ancho: 3,
      );
      expect(dim.alto, isNull);
    });

    test('withElementType limpia alto al cambiar pared a piso', () {
      final wall = ProjectDimensions(
        elementType: ElementType.wall,
        largo: 5,
        alto: 2.8,
      );
      final floor = wall.withElementType(ElementType.ceramicFloor);
      expect(floor.alto, isNull);
      expect(floor.elementType, equals(ElementType.ceramicFloor));
    });
  });

  // ── Technical details JSONB sanitization ─────────────────────────────────

  group('ElementTypeConfig.sanitizeTechnicalDetails', () {
    test('Piso solo incluye claves de baldosa, no thickness ni doors', () {
      final cfg = configForElementType(ElementType.ceramicFloor);
      final raw = {
        'thickness': 0.12, // incompatible
        'doors': 2,        // incompatible
        'tileWidth': 0.60,
        'tileLength': 0.60,
      };
      final sanitized = cfg.sanitizeTechnicalDetails(raw);
      expect(sanitized.containsKey('thickness'), isFalse);
      expect(sanitized.containsKey('doors'), isFalse);
      expect(sanitized['tileWidth'], equals(0.60));
    });

    test('Losa solo incluye thickness y concreteType', () {
      final cfg = configForElementType(ElementType.concreteSlab);
      final raw = {
        'thickness': 0.12,
        'concreteType': 'fcr_210',
        'doors': 2, // incompatible
      };
      final sanitized = cfg.sanitizeTechnicalDetails(raw);
      expect(sanitized['thickness'], equals(0.12));
      expect(sanitized['concreteType'], equals('fcr_210'));
      expect(sanitized.containsKey('doors'), isFalse);
    });
  });

  // ── Building validation ───────────────────────────────────────────────────

  group('BuildingProject.validate() – validaciones condicionales', () {
    test('Casa sin dormitorios falla validación', () {
      final house = BuildingProject(
        constructoraId: 'c',
        name: 'Casa',
        buildingType: BuildingType.house,
        totalArea: 100,
        constructionSystem: ConstructionSystem.reinforcedConcrete,
        finishLevel: FinishLevel.standard,
        bedrooms: null,
        bathrooms: 2,
      );
      final errors = house.validate();
      expect(errors, isNotEmpty);
      expect(errors.any((e) => e.contains('dormitorio')), isTrue);
    });

    test('Bodega sin clearHeight falla validación', () {
      final warehouse = BuildingProject(
        constructoraId: 'c',
        name: 'Bodega',
        buildingType: BuildingType.warehouse,
        totalArea: 600,
        constructionSystem: ConstructionSystem.steelStructure,
        finishLevel: FinishLevel.basic,
        clearHeight: null,
      );
      final errors = warehouse.validate();
      expect(errors.any((e) => e.contains('altura libre')), isTrue);
    });

    test('Bodega válida no tiene errores de dormitorios', () {
      final warehouse = makeWarehouse();
      final errors = warehouse.validate();
      // Should not complain about bedrooms since it's not required for warehouses
      expect(errors.where((e) => e.contains('dormitorio')), isEmpty);
    });
  });
}
