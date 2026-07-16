// test/features/projects/presentation/providers/project_form_provider_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildscan_app/features/projects/presentation/providers/project_form_provider.dart';
import 'package:buildscan_app/features/calculation/domain/entities/project_dimensions.dart';

void main() {
  group('ProjectFormProvider Tests', () {
    test('El estado inicial debe ser invalido', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(projectFormProvider);

      expect(state.nombre, '');
      expect(state.largo, 0.0);
      expect(state.ancho, 0.0);
      expect(state.alto, isNull);
      expect(state.desperdicio, 10.0);
      expect(state.tipoConstruccion, ElementType.wall);
      expect(state.isValid, false);
    });

    test('Losa de hormigon valida con nombre, largo, ancho y espesor', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(projectFormProvider.notifier);

      notifier.updateNombre('Losa Test');
      notifier.changeElementType(ElementType.concreteSlab);
      notifier.updateMedidas(largo: 5, ancho: 4);
      notifier.updateThickness(0.12);

      final state = container.read(projectFormProvider);

      expect(state.isValid, true);
    });

    test('Pared de ladrillo invalida sin alto', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(projectFormProvider.notifier);

      notifier.updateNombre('Pared Test');
      notifier.changeElementType(ElementType.wall);
      notifier.updateMedidas(largo: 5, ancho: 0); // No alto

      final state = container.read(projectFormProvider);

      expect(state.isValid, false);
    });

    test('Pared de ladrillo valida con alto', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(projectFormProvider.notifier);

      notifier.updateNombre('Pared Test');
      notifier.changeElementType(ElementType.wall);
      notifier.updateMedidas(largo: 5, ancho: 0, alto: 3);

      final state = container.read(projectFormProvider);

      expect(state.isValid, true);
    });

    test('Desperdicio no puede ser mayor a 30', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(projectFormProvider.notifier);

      notifier.updateDesperdicio(50);

      final state = container.read(projectFormProvider);

      expect(state.desperdicio, 30.0);
    });

    test('Desperdicio no puede ser menor a 0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(projectFormProvider.notifier);

      notifier.updateDesperdicio(-5);

      final state = container.read(projectFormProvider);

      expect(state.desperdicio, 0.0);
    });
  });
}
