import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/project_form_provider.dart';

class CalculationResultScreen extends ConsumerWidget {
  const CalculationResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(calculationResultProvider);
    final form = ref.watch(projectFormProvider);

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resultado')),
        body: const Center(
          child: Text('No hay datos de cálculo. Completa el formulario primero.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Resultado del cálculo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Proyecto: ${form.nombre}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Área calculada: ${result.areaCalculada.toStringAsFixed(2)} m²'),
                    Text('Desperdicio: ${result.desperdicio.toStringAsFixed(0)}%'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(result.sugerencia),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Materiales estimados',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...result.materiales.map((m) => Card(
                  child: ListTile(
                    title: Text(m.nombre),
                    subtitle: Text(m.observacion.isNotEmpty ? m.observacion : ''),
                    trailing: Text(
                      '${m.cantidad.toStringAsFixed(2)} ${m.unidad}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/projects/image'),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Visualizar con IA'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => context.push('/proforma'),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Ver proforma'),
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
