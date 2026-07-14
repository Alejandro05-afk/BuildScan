import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../calculation/domain/entities/project_dimensions.dart';
import '../providers/project_form_provider.dart';

class ProjectFormScreen extends ConsumerWidget {
  const ProjectFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(projectFormProvider);
    final notifier = ref.read(projectFormProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo proyecto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nombre del proyecto',
                border: OutlineInputBorder(),
              ),
              onChanged: notifier.updateNombre,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ConstructionType>(
              initialValue: form.tipoConstruccion,
              decoration: const InputDecoration(
                labelText: 'Tipo de obra',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: ConstructionType.paredLadrillo, child: Text('Pared de ladrillo')),
                DropdownMenuItem(value: ConstructionType.losaHormigon, child: Text('Losa de hormigón')),
                DropdownMenuItem(value: ConstructionType.pisoCeramico, child: Text('Piso cerámico')),
                DropdownMenuItem(value: ConstructionType.cuartoBasico, child: Text('Cuarto básico')),
              ],
              onChanged: (value) {
                if (value != null) notifier.updateTipo(value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Largo (m)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => notifier.updateMedidas(
                largo: double.tryParse(value) ?? 0,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Ancho (m)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => notifier.updateMedidas(
                ancho: double.tryParse(value) ?? 0,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Alto (m) - opcional para paredes',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => notifier.updateMedidas(
                alto: double.tryParse(value) ?? 0,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Desperdicio (%)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              initialValue: '10',
              onChanged: (value) => notifier.updateDesperdicio(
                double.tryParse(value) ?? 10,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: form.isValid
                  ? () => context.push('/projects/result')
                  : null,
              icon: const Icon(Icons.calculate),
              label: const Text('Calcular materiales'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
