import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/clay_container_alias.dart';

import '../../../calculation/domain/entities/project_dimensions.dart';
import '../providers/project_form_provider.dart';
import '../../../../core/widgets/clay_input_field.dart';
import '../../../../core/widgets/clay_submit_button.dart';
import '../../../../core/theme/buildscan_theme.dart';

class ProjectFormScreen extends ConsumerWidget {
  const ProjectFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(projectFormProvider);
    final notifier = ref.read(projectFormProvider.notifier);

    return Scaffold(
      backgroundColor: BuildScanColors.background,
      appBar: AppBar(
        title: const Text('Nuevo proyecto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClayInputField(
              labelText: 'Nombre del proyecto',
              initialValue: form.nombre,
              onChanged: notifier.updateNombre,
            ),
            const SizedBox(height: 24),
            
            ClayContainer(
              color: BuildScanColors.background,
              borderRadius: 12,
              depth: 20,
              spread: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ConstructionType>(
                    isExpanded: true,
                    value: form.tipoConstruccion,
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
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            ClayInputField(
              labelText: 'Largo (m)',
              keyboardType: TextInputType.number,
              initialValue: form.largo > 0 ? form.largo.toString() : null,
              onChanged: (value) => notifier.updateMedidas(
                largo: double.tryParse(value) ?? 0,
              ),
            ),
            const SizedBox(height: 16),
            
            ClayInputField(
              labelText: 'Ancho (m)',
              keyboardType: TextInputType.number,
              initialValue: form.ancho > 0 ? form.ancho.toString() : null,
              onChanged: (value) => notifier.updateMedidas(
                ancho: double.tryParse(value) ?? 0,
              ),
            ),
            const SizedBox(height: 16),
            
            ClayInputField(
              labelText: 'Alto (m) - Obligatorio para paredes',
              keyboardType: TextInputType.number,
              initialValue: form.alto > 0 ? form.alto.toString() : null,
              onChanged: (value) => notifier.updateMedidas(
                alto: double.tryParse(value) ?? 0,
              ),
            ),
            const SizedBox(height: 16),
            
            ClayInputField(
              labelText: 'Desperdicio (%)',
              keyboardType: TextInputType.number,
              initialValue: form.desperdicio.toStringAsFixed(0),
              onChanged: (value) => notifier.updateDesperdicio(
                double.tryParse(value) ?? 10,
              ),
            ),
            const SizedBox(height: 48),
            
            ClaySubmitButton(
              text: 'Calcular materiales',
              onPressed: form.isValid
                  ? () => context.push('/projects/result')
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, completa los campos obligatorios correctamente.')),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}
