import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_containers/clay_containers.dart';

import '../providers/project_form_provider.dart';
import '../providers/projects_provider.dart';
import '../../domain/entities/project_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class CalculationResultScreen extends ConsumerWidget {
  const CalculationResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(calculationResultProvider);
    final form = ref.watch(projectFormProvider);
    final saveState = ref.watch(saveProjectProvider);

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resultado')),
        body: const Center(
          child: Text('No hay datos de cálculo. Completa el formulario primero.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado del cálculo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClayContainer(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: 16,
              depth: 10,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Proyecto: ${form.nombre}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text('Área calculada: ${result.areaCalculada.toStringAsFixed(2)} m²', style: const TextStyle(fontSize: 16)),
                    Text('Desperdicio: ${result.desperdicio.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    ClayContainer(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: 12,
                      depth: -5,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(result.sugerencia, style: const TextStyle(fontStyle: FontStyle.italic)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Materiales estimados',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...result.materiales.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ClayContainer(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: 12,
                depth: 5,
                child: ListTile(
                  title: Text(m.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(m.observacion.isNotEmpty ? m.observacion : ''),
                  trailing: Text(
                    '${m.cantidad.toStringAsFixed(2)} ${m.unidad}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 16),
                  ),
                ),
              ),
            )),
            const SizedBox(height: 32),
            
            saveState.isLoading 
              ? const Center(child: CircularProgressIndicator())
              : Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/projects/image'),
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Visualizar IA'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final auth = ref.read(authStateProvider).value?.session?.user;
                          if (auth == null) return;
                          
                          final entity = ProjectEntity(
                            id: '',
                            constructoraId: auth.id,
                            nombre: form.nombre,
                            tipoConstruccion: form.tipoConstruccion,
                            largo: form.largo,
                            ancho: form.ancho,
                            alto: form.alto,
                            area: result.areaCalculada,
                            porcentajeDesperdicio: result.desperdicio,
                            sugerencia: result.sugerencia,
                            estado: 'activo',
                          );

                          final saved = await ref.read(saveProjectProvider.notifier).saveProject(entity);
                          if (context.mounted) {
                            if (saved != null) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Proyecto guardado correctamente')));
                              context.push('/proforma', extra: saved);
                            } else {
                              final errorState = ref.read(saveProjectProvider);
                              final errMsg = errorState.error?.toString() ?? 'Error desconocido al guardar';
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $errMsg'), backgroundColor: Colors.red));
                            }
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
