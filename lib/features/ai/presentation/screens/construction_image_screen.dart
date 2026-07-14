import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/ai_prompt_service.dart';
import '../../services/construction_image_provider.dart';
import '../../../projects/presentation/providers/project_form_provider.dart';
import '../../../calculation/domain/entities/project_dimensions.dart';

final aiPromptServiceProvider = Provider<AiPromptService>((ref) {
  return AiPromptService();
});

class ConstructionImageScreen extends ConsumerWidget {
  const ConstructionImageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(projectFormProvider);
    final imageState = ref.watch(constructionImageControllerProvider);

    final dimensions = ProjectDimensions(
      largo: form.largo,
      ancho: form.ancho,
      alto: form.alto,
    );
    final area = form.largo * form.ancho;

    return Scaffold(
      appBar: AppBar(title: const Text('Visualización IA')),
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
                    Text('Tipo: ${_typeLabel(form.tipoConstruccion)}'),
                    Text('Área: ${area.toStringAsFixed(2)} m²'),
                    Text('Dimensiones: ${form.largo}m x ${form.ancho}m'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: imageState.isLoading
                  ? null
                  : () {
                      final promptService = ref.read(aiPromptServiceProvider);
                      final prompt = promptService.buildConstructionPrompt(
                        type: form.tipoConstruccion,
                        dimensions: dimensions,
                      );
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
                    Text('La IA está diseñando tu proyecto...'),
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
      BuildContext context, WidgetRef ref, File? file) {
    if (file == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.image_outlined, size: 64,
                  color: Theme.of(context).colorScheme.outline),
              const SizedBox(height: 12),
              const Text('Presiona el botón para generar una visualización de tu proyecto'),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(file, fit: BoxFit.cover),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(constructionImageControllerProvider.notifier).generate(
                    prompt: ref.read(aiPromptServiceProvider).buildConstructionPrompt(
                      type: ref.read(projectFormProvider).tipoConstruccion,
                      dimensions: ProjectDimensions(
                        largo: ref.read(projectFormProvider).largo,
                        ancho: ref.read(projectFormProvider).ancho,
                        alto: ref.read(projectFormProvider).alto,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Regenerar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Imagen guardada en el proyecto')),
                  );
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

  String _typeLabel(ConstructionType type) {
    switch (type) {
      case ConstructionType.paredLadrillo:
        return 'Pared de ladrillo';
      case ConstructionType.losaHormigon:
        return 'Losa de hormigón';
      case ConstructionType.pisoCeramico:
        return 'Piso cerámico';
      case ConstructionType.cuartoBasico:
        return 'Cuarto básico';
    }
  }
}
