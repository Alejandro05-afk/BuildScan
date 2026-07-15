import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_containers/clay_containers.dart';
import '../providers/projects_provider.dart';

final projectDetailProvider = FutureProvider.family.autoDispose((ref, String id) async {
  final repo = ref.watch(projectRepositoryProvider);
  return repo.getProjectById(id);
});

class ProjectDetailScreen extends ConsumerWidget {
  final String projectId;
  
  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(projectDetailProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Proyecto'),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (project) {
          if (project == null) return const Center(child: Text('Proyecto no encontrado'));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClayContainer(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: 16,
                  depth: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.nombre,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Tipo', project.tipoConstruccion.name),
                        _buildInfoRow('Área', '${project.area.toStringAsFixed(2)} m²'),
                        _buildInfoRow('Largo', '${project.largo} m'),
                        _buildInfoRow('Ancho', '${project.ancho} m'),
                        _buildInfoRow('Alto', '${project.alto} m'),
                        _buildInfoRow('Desperdicio', '${project.porcentajeDesperdicio}%'),
                      ],
                    ),
                  ),
                ),
                if (project.sugerencia != null) ...[
                  const SizedBox(height: 16),
                  ClayContainer(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: 16,
                    depth: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Sugerencia: ${project.sugerencia}', style: const TextStyle(fontStyle: FontStyle.italic)),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                // Aquí se podrían listar las cotizaciones asociadas usando otro provider.
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
