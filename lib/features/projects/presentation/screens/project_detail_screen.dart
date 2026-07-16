// lib/features/projects/presentation/screens/project_detail_screen.dart
//
// Shows project details dynamically based on the element type policy.
// Never shows "Dormitorios: 0" for warehouses or "Alto: 0" for floors.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/clay_container_alias.dart';
import '../../domain/policies/element_type_policy.dart';
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
          if (project == null) {
            return const Center(child: Text('Proyecto no encontrado'));
          }

          final type = project.tipoConstruccion;
          final details = project.detallesTecnicos ?? {};

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

                        _buildInfoRow('Tipo', type.displayLabel),
                        _buildInfoRow('Área', '${project.area.toStringAsFixed(2)} m²'),
                        _buildInfoRow('Largo', '${project.largo} m'),

                        // Ancho only for types that use it
                        if (type != ElementType.wall && project.ancho > 0)
                          _buildInfoRow('Ancho', '${project.ancho} m'),

                        // Wall height / room height – but NOT for floors or slabs
                        if ((type == ElementType.wall || type == ElementType.room) &&
                            project.alto != null)
                          _buildInfoRow(
                            type == ElementType.wall ? 'Altura de pared' : 'Altura interior',
                            '${project.alto} m',
                          ),

                        // Slab: show thickness from detalles_tecnicos
                        if (type == ElementType.concreteSlab) ...[
                          if (details['thickness'] != null)
                            _buildInfoRow(
                              'Espesor de losa',
                              '${(details['thickness'] as num) * 100} cm',
                            ),
                        ],

                        // Ceramic floor: show tile dimensions
                        if (type == ElementType.ceramicFloor) ...[
                          if (details['tileWidth'] != null && details['tileLength'] != null)
                            _buildInfoRow(
                              'Dimensión baldosa',
                              '${details['tileWidth']}m × ${details['tileLength']}m',
                            ),
                          if (details['installationType'] != null)
                            _buildInfoRow('Tipo instalación', details['installationType']),
                        ],

                        // Wall: show doors, windows, blockType
                        if (type == ElementType.wall) ...[
                          if (details['doors'] != null)
                            _buildInfoRow('Puertas', '${details['doors']}'),
                          if (details['windows'] != null)
                            _buildInfoRow('Ventanas', '${details['windows']}'),
                          if (details['blockType'] != null)
                            _buildInfoRow('Tipo bloque', details['blockType']),
                        ],

                        // Room: show doors and windows
                        if (type == ElementType.room) ...[
                          if (details['doors'] != null)
                            _buildInfoRow('Puertas', '${details['doors']}'),
                          if (details['windows'] != null)
                            _buildInfoRow('Ventanas', '${details['windows']}'),
                        ],

                        // Roof: show type and slope
                        if (type == ElementType.roof) ...[
                          if (details['roofType'] != null)
                            _buildInfoRow('Tipo cubierta', details['roofType']),
                          if (details['roofSlope'] != null)
                            _buildInfoRow('Pendiente', '${details['roofSlope']}%'),
                          if (details['eave'] != null)
                            _buildInfoRow('Alero', '${details['eave']} m'),
                        ],

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
                      child: Text(
                        'Sugerencia: ${project.sugerencia}',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
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
