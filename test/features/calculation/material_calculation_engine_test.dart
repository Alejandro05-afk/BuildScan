import 'package:flutter_test/flutter_test.dart';
import 'package:buildscan_app/features/calculation/domain/services/material_calculation_engine.dart';
import 'package:buildscan_app/features/calculation/domain/entities/project_dimensions.dart';

void main() {
  late MaterialCalculationEngine engine;

  setUp(() {
    engine = MaterialCalculationEngine();
  });

  group('MaterialCalculationEngine Tests', () {
    test('Calcula pared de ladrillo correctamente', () {
      final dimensions = ProjectDimensions(largo: 4, ancho: 0, alto: 3); // Área: 12m2
      final result = engine.calculate(
        type: ConstructionType.paredLadrillo,
        dimensions: dimensions,
        wastePercentage: 10,
      );

      expect(result.areaCalculada, 12.0);
      expect(result.materiales.length, 3);
      
      final ladrillos = result.materiales.firstWhere((m) => m.nombre.contains('Ladrillos'));
      // 12m2 * 42 ladrillos/m2 * 1.1 = 554.4 -> 555
      expect(ladrillos.cantidad, 555);
    });

    test('Calcula losa de hormigón correctamente', () {
      final dimensions = ProjectDimensions(largo: 5, ancho: 4, alto: 0); // Área: 20m2
      final result = engine.calculate(
        type: ConstructionType.losaHormigon,
        dimensions: dimensions,
        wastePercentage: 5,
      );

      expect(result.areaCalculada, 20.0);
      
      final cemento = result.materiales.firstWhere((m) => m.nombre.contains('Cemento'));
      // 20m2 * 0.65 sacos/m2 * 1.05 = 13.65
      expect(cemento.cantidad, closeTo(13.65, 0.01));
    });
    
    test('Calcula cuarto básico correctamente (perímetro)', () {
      // Cuarto de 4x3x2.5
      // Perímetro: (4+3)*2 = 14m
      // Área de paredes: 14m * 2.5m = 35m2
      final dimensions = ProjectDimensions(largo: 4, ancho: 3, alto: 2.5);
      final result = engine.calculate(
        type: ConstructionType.cuartoBasico,
        dimensions: dimensions,
        wastePercentage: 10,
      );
      
      expect(result.areaCalculada, 12.0); // área de piso: 4*3
      final ladrillos = result.materiales.firstWhere((m) => m.nombre.contains('Bloques/Ladrillos'));
      // 35m2 (pared) * 85 * 1.1 = 3272.5 -> 3273
      expect(ladrillos.cantidad, 3273);
    });
  });
}
