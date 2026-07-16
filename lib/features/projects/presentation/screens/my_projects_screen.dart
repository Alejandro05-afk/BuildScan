import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/projects_provider.dart';

class MyProjectsScreen extends ConsumerWidget {
  const MyProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(myProjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Proyectos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(myProjectsProvider);
            },
          )
        ],
      ),
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (projects) {
          if (projects.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () async {
              return ref.refresh(myProjectsProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final proj = projects[index];
                  return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Dismissible(
                    key: ValueKey(proj.id),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Eliminar proyecto'),
                          content: Text('¿Eliminar "${proj.nombre}"? Esta acción no se puede deshacer.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) async {
                      final repo = ref.read(projectRepositoryProvider);
                      await repo.deleteProject(proj.id);
                      ref.invalidate(myProjectsProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('"${proj.nombre}" eliminado')),
                        );
                      }
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => context.push('/projects/detail/${proj.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  proj.nombre,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                _buildStatusBadge(proj.estado),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Área: ${proj.area.toStringAsFixed(2)} m²'),
                            Text('Tipo: ${proj.tipoConstruccion.name}'),
                            if (proj.createdAt != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Fecha: ${proj.createdAt!.toLocal().toString().split(' ')[0]}',
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
            ),
            builder: (ctx) => Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('¿Qué deseas calcular?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: const Icon(Icons.home_work_outlined, color: Colors.teal, size: 32),
                    title: const Text('Edificación Completa', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Casas, edificios, bodegas, etc.'),
                    onTap: () {
                      Navigator.pop(ctx);
                      context.push('/projects/building/new');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.foundation_outlined, color: Colors.orange, size: 32),
                    title: const Text('Elemento Constructivo', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Paredes, losas, pisos específicos.'),
                    onTap: () {
                      Navigator.pop(ctx);
                      context.push('/projects/new');
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
        label: const Text('Nuevo Proyecto'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Aún no tienes proyectos.',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    Color bgColor;
    String text;
    
    switch (status) {
      case 'activo':
        color = Colors.green.shade700;
        bgColor = Colors.green.shade50;
        text = 'Activo';
        break;
      case 'cotizado':
        color = Colors.blue.shade700;
        bgColor = Colors.blue.shade50;
        text = 'Cotizado';
        break;
      case 'en_progreso':
        color = Colors.orange.shade800;
        bgColor = Colors.orange.shade50;
        text = 'En Progreso';
        break;
      default:
        color = Colors.grey.shade700;
        bgColor = Colors.grey.shade100;
        text = status.toUpperCase();
    }
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
