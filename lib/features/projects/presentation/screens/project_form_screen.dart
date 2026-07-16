// lib/features/projects/presentation/screens/project_form_screen.dart
//
// Dynamic form for simple construction elements.
// Fields shown/hidden/labeled based on ElementTypePolicy.
// Changing the type clears incompatible controller values via changeElementType().

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/buildscan_theme.dart';
import '../../../../core/widgets/clay_container_alias.dart';
import '../../../../core/widgets/clay_input_field.dart';
import '../../../../core/widgets/clay_submit_button.dart';
import '../../../projects/domain/policies/element_type_policy.dart';
import '../providers/project_form_provider.dart';

class ProjectFormScreen extends ConsumerStatefulWidget {
  const ProjectFormScreen({super.key});

  @override
  ConsumerState<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends ConsumerState<ProjectFormScreen> {
  // Controllers that need to be cleared when element type changes.
  final _largoCtr = TextEditingController();
  final _anchoCtr = TextEditingController();
  final _altoCtr = TextEditingController();
  final _thicknessCtr = TextEditingController();
  final _doorsCtr = TextEditingController();
  final _windowsCtr = TextEditingController();
  final _tileWidthCtr = TextEditingController();
  final _tileLengthCtr = TextEditingController();
  final _roofSlopeCtr = TextEditingController();
  final _eaveCtr = TextEditingController();

  @override
  void dispose() {
    _largoCtr.dispose();
    _anchoCtr.dispose();
    _altoCtr.dispose();
    _thicknessCtr.dispose();
    _doorsCtr.dispose();
    _windowsCtr.dispose();
    _tileWidthCtr.dispose();
    _tileLengthCtr.dispose();
    _roofSlopeCtr.dispose();
    _eaveCtr.dispose();
    super.dispose();
  }

  void _clearControllersForType(ElementType newType) {
    final cfg = configForElementType(newType);
    if (!cfg.isVisible(ElementField.width)) _anchoCtr.clear();
    if (!cfg.isVisible(ElementField.wallHeight)) _altoCtr.clear();
    if (!cfg.isVisible(ElementField.thickness)) _thicknessCtr.clear();
    if (!cfg.isVisible(ElementField.doors)) _doorsCtr.clear();
    if (!cfg.isVisible(ElementField.windows)) _windowsCtr.clear();
    if (!cfg.isVisible(ElementField.tileWidth)) _tileWidthCtr.clear();
    if (!cfg.isVisible(ElementField.tileLength)) _tileLengthCtr.clear();
    if (!cfg.isVisible(ElementField.roofSlope)) _roofSlopeCtr.clear();
    if (!cfg.isVisible(ElementField.eave)) _eaveCtr.clear();
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(projectFormProvider);
    final notifier = ref.read(projectFormProvider.notifier);
    final cfg = configForElementType(form.tipoConstruccion);

    return Scaffold(
      backgroundColor: BuildScanColors.background,
      appBar: AppBar(title: const Text('Nuevo proyecto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Nombre ──────────────────────────────────────────────────────
            ClayInputField(
              labelText: 'Nombre del proyecto',
              initialValue: form.nombre,
              onChanged: notifier.updateNombre,
            ),
            const SizedBox(height: 24),

            // ── Tipo de elemento ────────────────────────────────────────────
            ClayContainer(
              color: BuildScanColors.background,
              borderRadius: 12,
              depth: 20,
              spread: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ElementType>(
                    isExpanded: true,
                    value: form.tipoConstruccion,
                    items: ElementType.values.map((t) {
                      return DropdownMenuItem(value: t, child: Text(t.displayLabel));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _clearControllersForType(value);
                        notifier.changeElementType(value);
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Largo (always visible) ──────────────────────────────────────
            ClayInputField(
              controller: _largoCtr,
              labelText: '${cfg.labelFor(ElementField.length)} (${cfg.unitFor(ElementField.length) ?? 'm'})',
              keyboardType: TextInputType.number,
              onChanged: (v) => notifier.updateMedidas(largo: double.tryParse(v) ?? 0),
            ),
            const SizedBox(height: 16),

            // ── Ancho (floors, slabs, rooms, roofs) ────────────────────────
            if (cfg.isVisible(ElementField.width)) ...[
              ClayInputField(
                controller: _anchoCtr,
                labelText: '${cfg.labelFor(ElementField.width)} (${cfg.unitFor(ElementField.width) ?? 'm'})',
                keyboardType: TextInputType.number,
                onChanged: (v) => notifier.updateMedidas(ancho: double.tryParse(v) ?? 0),
              ),
              const SizedBox(height: 16),
            ],

            // ── Altura de pared / Altura interior (walls, rooms) ───────────
            if (cfg.isVisible(ElementField.wallHeight)) ...[
              ClayInputField(
                controller: _altoCtr,
                labelText: '${cfg.labelFor(ElementField.wallHeight)} (m)',
                keyboardType: TextInputType.number,
                onChanged: (v) => notifier.updateMedidas(alto: double.tryParse(v)),
              ),
              const SizedBox(height: 16),
            ],

            // ── Espesor (slabs only) ───────────────────────────────────────
            if (cfg.isVisible(ElementField.thickness)) ...[
              ClayInputField(
                controller: _thicknessCtr,
                labelText: '${cfg.labelFor(ElementField.thickness)} (m - ej: 0.12)',
                keyboardType: TextInputType.number,
                onChanged: (v) => notifier.updateThickness(double.tryParse(v)),
              ),
              const SizedBox(height: 16),
            ],

            // ── Puertas (walls, rooms) ─────────────────────────────────────
            if (cfg.isVisible(ElementField.doors)) ...[
              ClayInputField(
                controller: _doorsCtr,
                labelText: cfg.labelFor(ElementField.doors),
                keyboardType: TextInputType.number,
                onChanged: (v) => notifier.updateDoors(int.tryParse(v)),
              ),
              const SizedBox(height: 16),
            ],

            // ── Ventanas (walls, rooms) ────────────────────────────────────
            if (cfg.isVisible(ElementField.windows)) ...[
              ClayInputField(
                controller: _windowsCtr,
                labelText: cfg.labelFor(ElementField.windows),
                keyboardType: TextInputType.number,
                onChanged: (v) => notifier.updateWindows(int.tryParse(v)),
              ),
              const SizedBox(height: 16),
            ],

            // ── Dimensión baldosa (ceramic floors) ─────────────────────────
            if (cfg.isVisible(ElementField.tileWidth)) ...[
              ClayInputField(
                controller: _tileWidthCtr,
                labelText: '${cfg.labelFor(ElementField.tileWidth)} (m)',
                keyboardType: TextInputType.number,
                onChanged: (v) =>
                    notifier.updateStringField(tileWidth: double.tryParse(v)),
              ),
              const SizedBox(height: 16),
            ],

            if (cfg.isVisible(ElementField.tileLength)) ...[
              ClayInputField(
                controller: _tileLengthCtr,
                labelText: '${cfg.labelFor(ElementField.tileLength)} (m)',
                keyboardType: TextInputType.number,
                onChanged: (v) => notifier.updateStringField(tileLength: double.tryParse(v)),
              ),
              const SizedBox(height: 16),
            ],

            // ── Tipo de cubierta (roofs) ───────────────────────────────────
            if (cfg.isVisible(ElementField.roofType)) ...[
              ClayContainer(
                color: BuildScanColors.background,
                borderRadius: 12,
                depth: 20,
                spread: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: form.roofType,
                      hint: Text(cfg.labelFor(ElementField.roofType)),
                      items: const [
                        DropdownMenuItem(value: 'teja', child: Text('Teja')),
                        DropdownMenuItem(value: 'zinc', child: Text('Zinc / Galvalume')),
                        DropdownMenuItem(
                            value: 'termoacustica', child: Text('Panel termoacústico')),
                        DropdownMenuItem(value: 'hormigon', child: Text('Losa de hormigón')),
                        DropdownMenuItem(value: 'policarbonato', child: Text('Policarbonato')),
                      ],
                      onChanged: (v) => notifier.updateStringField(roofType: v),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Pendiente (roofs) ──────────────────────────────────────────
            if (cfg.isVisible(ElementField.roofSlope)) ...[
              ClayInputField(
                controller: _roofSlopeCtr,
                labelText: '${cfg.labelFor(ElementField.roofSlope)} (%)',
                keyboardType: TextInputType.number,
                onChanged: (v) =>
                    notifier.updateStringField(roofSlope: double.tryParse(v)),
              ),
              const SizedBox(height: 16),
            ],

            // ── Alero (roofs) ──────────────────────────────────────────────
            if (cfg.isVisible(ElementField.eave)) ...[
              ClayInputField(
                controller: _eaveCtr,
                labelText: '${cfg.labelFor(ElementField.eave)} (m)',
                keyboardType: TextInputType.number,
                onChanged: (v) => notifier.updateStringField(eave: double.tryParse(v)),
              ),
              const SizedBox(height: 16),
            ],

            // ── Desperdicio (always visible) ───────────────────────────────
            ClayInputField(
              labelText: 'Desperdicio (%)',
              keyboardType: TextInputType.number,
              initialValue: form.desperdicio.toStringAsFixed(0),
              onChanged: (v) => notifier.updateDesperdicio(double.tryParse(v) ?? 10),
            ),
            const SizedBox(height: 48),

            // ── Submit ────────────────────────────────────────────────────
            ClaySubmitButton(
              text: 'Calcular materiales',
              onPressed: form.isValid
                  ? () => context.push('/projects/result')
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Por favor, completa los campos obligatorios correctamente.'),
                        ),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}
