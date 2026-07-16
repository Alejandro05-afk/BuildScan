import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/ai_prompt_service.dart';
import '../../services/construction_image_provider.dart';
import '../../../projects/presentation/providers/building_project_form_provider.dart';
import '../../../projects/presentation/providers/projects_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/storage_service.dart';

final buildingAiPromptServiceProvider = Provider<AiPromptService>((ref) {
  return AiPromptService();
});

class BuildingImageScreen extends ConsumerWidget {
  const BuildingImageScreen({super.key});

  static const Map<String, String> _typeLabels = {
    'house': 'Casa',
    'residentialBuilding': 'Edificio Residencial',
    'commercialBuilding': 'Edificio Comercial',
    'commercialSpace': 'Local Comercial',
    'office': 'Oficina',
    'warehouse': 'Bodega / Industrial',
    'custom': 'Construcción Personalizada',
  };

  static const Map<String, String> _systemLabels = {
    'reinforcedConcrete': 'Hormigón Armado',
    'steelStructure': 'Estructura Metálica',
    'mixed': 'Mixto',
    'masonry': 'Mampostería',
  };

  static const Map<String, String> _finishLabels = {
    'basic': 'Básico',
    'standard': 'Estándar',
    'premium': 'Premium',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(buildingProjectFormProvider);
    final imageState = ref.watch(constructionImageControllerProvider);
    final project = state.form;

    final typeName = _typeLabels[project.buildingType.name] ?? project.buildingType.name;
    final systemName = _systemLabels[project.constructionSystem.name] ?? project.constructionSystem.name;
    final finishName = _finishLabels[project.finishLevel.name] ?? project.finishLevel.name;

    return Scaffold(
      appBar: AppBar(title: const Text('Visualización IA - Edificación')),
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
                      'Proyecto: ${project.name}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Tipo: $typeName'),
                    Text('Área: ${project.totalArea.toStringAsFixed(0)} m²'),
                    Text('Plantas: ${project.floors}'),
                    Text('Sistema: $systemName'),
                    Text('Acabados: $finishName'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: imageState.isLoading
                  ? null
                  : () {
                      final promptService = ref.read(buildingAiPromptServiceProvider);
                      final prompt = promptService.buildCompleteBuildingPrompt(project: project);
                      ref
                          .read(constructionImageControllerProvider.notifier)
                          .generate(prompt: prompt);
                    },
              icon: imageState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(imageState.isLoading
                  ? 'Generando imagen...'
                  : 'Generar imagen con IA'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            imageState.when(
              loading: () => const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('La IA está diseñando tu edificación...'),
                    SizedBox(height: 8),
                    Text(
                      'La primera vez puede tardar hasta 2 minutos mientras el modelo se activa.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              error: (e, _) => Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        'Error al generar la imagen',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(e.toString(), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
              data: (file) => _buildImageResult(context, ref, file),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageResult(
      BuildContext context, WidgetRef ref, AiImageResult? result) {
    if (result == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.image_outlined, size: 64,
                  color: Theme.of(context).colorScheme.outline),
              const SizedBox(height: 12),
              const Text('Presiona el botón para generar una visualización de tu edificación'),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (result.source == 'placeholder')
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 12),
            color: Colors.orange.shade100,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade900),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No se pudo conectar con la IA. Mostrando imagen ilustrativa de respaldo.',
                    style: TextStyle(color: Colors.orange.shade900),
                  ),
                ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(result.file, fit: BoxFit.cover),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  final project = ref.read(buildingProjectFormProvider).form;
                  final prompt = ref.read(buildingAiPromptServiceProvider).buildCompleteBuildingPrompt(project: project);
                  ref.read(constructionImageControllerProvider.notifier).generate(prompt: prompt);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Regenerar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final calc = ref.read(buildingProjectFormProvider).calculation;
                  if (calc == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Primero calcula los materiales del proyecto.')),
                    );
                    return;
                  }

                  try {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Guardando proyecto e imagen...')),
                    );

                    final user = ref.read(authStateProvider).value?.session?.user;
                    if (user == null) return;

                    final repo = ref.read(projectRepositoryProvider);
                    final storage = ref.read(storageServiceProvider);
                    final project = ref.read(buildingProjectFormProvider).form.copyWith(constructoraId: user.id);

                    final savedProject = await repo.createCompleteBuildingProject(project);

                    final bytes = await result.file.readAsBytes();
                    final path = await storage.uploadAiImage(
                      userId: user.id,
                      projectId: savedProject.id!,
                      bytes: bytes,
                    );

                    await repo.updateProjectAiImage(
                      projectId: savedProject.id!,
                      storagePath: path,
                      source: result.source,
                    );

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Proyecto e imagen guardados exitosamente.')),
                      );
                      context.pop();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al guardar: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
