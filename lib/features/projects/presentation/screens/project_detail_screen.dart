// lib/features/projects/presentation/screens/project_detail_screen.dart
//
// Shows project details dynamically based on the project scope.
// Detects whether the project is a simple construction element
// or a complete building project and renders the appropriate fields.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/clay_container_alias.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../domain/policies/element_type_policy.dart';
import '../../domain/entities/building_project.dart';
import '../../data/models/building_project_mapper.dart';
import '../../data/models/project_model.dart';

/// Returns the raw DB row for a project so we can detect project_scope.
final rawProjectProvider =
    FutureProvider.family.autoDispose<Map<String, dynamic>?, String>((ref, id) async {
  final client = ref.watch(supabaseProvider);
  final data = await client.from('proyectos').select().eq('id', id).maybeSingle();
  return data;
});

class ProjectDetailScreen extends ConsumerWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rawAsync = ref.watch(rawProjectProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Proyecto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            tooltip: 'Ver QR',
            onPressed: () {
              context.push('/projects/qr/$projectId');
            },
          ),
        ],
      ),
      body: rawAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (raw) {
          if (raw == null) {
            return const Center(child: Text('Proyecto no encontrado'));
          }

          final scope = raw['project_scope'] as String?;
          if (scope == 'completeBuilding') {
            return _BuildingProjectDetail(raw: raw);
          }
          return _ElementProjectDetail(raw: raw);
        },
      ),
    );
  }
}

// ── Element (simple construction) detail ──────────────────────────────────

class _ElementProjectDetail extends StatelessWidget {
  const _ElementProjectDetail({required this.raw});

  final Map<String, dynamic> raw;

  @override
  Widget build(BuildContext context) {
    final project = ProjectModel.fromMap(raw);
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

                  _InfoRow(label: 'Tipo', value: type.displayLabel),
                  _InfoRow(label: 'Área', value: '${project.area.toStringAsFixed(2)} m²'),
                  _InfoRow(label: 'Largo', value: '${project.largo} m'),

                  if (type != ElementType.wall && project.ancho > 0)
                    _InfoRow(label: 'Ancho', value: '${project.ancho} m'),

                  if ((type == ElementType.wall || type == ElementType.room) &&
                      project.alto != null)
                    _InfoRow(
                      label: type == ElementType.wall ? 'Altura de pared' : 'Altura interior',
                      value: '${project.alto} m',
                    ),

                  if (type == ElementType.concreteSlab) ...[
                    if (details['thickness'] != null)
                      _InfoRow(
                        label: 'Espesor de losa',
                        value: '${(details['thickness'] as num) * 100} cm',
                      ),
                  ],

                  if (type == ElementType.ceramicFloor) ...[
                    if (details['tileWidth'] != null && details['tileLength'] != null)
                      _InfoRow(
                        label: 'Dimensión baldosa',
                        value: '${details['tileWidth']}m × ${details['tileLength']}m',
                      ),
                    if (details['installationType'] != null)
                      _InfoRow(label: 'Tipo instalación', value: '${details['installationType']}'),
                  ],

                  if (type == ElementType.wall) ...[
                    if (details['doors'] != null)
                      _InfoRow(label: 'Puertas', value: '${details['doors']}'),
                    if (details['windows'] != null)
                      _InfoRow(label: 'Ventanas', value: '${details['windows']}'),
                    if (details['blockType'] != null)
                      _InfoRow(label: 'Tipo bloque', value: '${details['blockType']}'),
                  ],

                  if (type == ElementType.room) ...[
                    if (details['doors'] != null)
                      _InfoRow(label: 'Puertas', value: '${details['doors']}'),
                    if (details['windows'] != null)
                      _InfoRow(label: 'Ventanas', value: '${details['windows']}'),
                  ],

                  if (type == ElementType.roof) ...[
                    if (details['roofType'] != null)
                      _InfoRow(label: 'Tipo cubierta', value: '${details['roofType']}'),
                    if (details['roofSlope'] != null)
                      _InfoRow(label: 'Pendiente', value: '${details['roofSlope']}%'),
                    if (details['eave'] != null)
                      _InfoRow(label: 'Alero', value: '${details['eave']} m'),
                  ],

                  _InfoRow(label: 'Desperdicio', value: '${project.porcentajeDesperdicio}%'),
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
  }
}

// ── Complete building project detail ──────────────────────────────────────

class _BuildingProjectDetail extends StatelessWidget {
  const _BuildingProjectDetail({required this.raw});

  final Map<String, dynamic> raw;

  @override
  Widget build(BuildContext context) {
    final project = BuildingProjectMapper.fromMap(raw);
    final cfg = project.policy;

    final buildingTypeLabel = _buildingTypeLabel(project.buildingType);

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
                    project.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  _InfoRow(label: 'Tipo de edificación', value: buildingTypeLabel),
                  _InfoRow(label: 'Área total', value: '${project.totalArea.toStringAsFixed(2)} m²'),
                  if (cfg.isVisible(BuildingField.floors))
                    _InfoRow(
                        label: cfg.labelFor(BuildingField.floors),
                        value: '${project.floors}'),
                  _InfoRow(
                      label: 'Altura de planta',
                      value: '${project.floorHeight} m'),

                  // Residential
                  if (cfg.isVisible(BuildingField.bedrooms) && project.bedrooms != null)
                    _InfoRow(
                        label: cfg.labelFor(BuildingField.bedrooms),
                        value: '${project.bedrooms}'),
                  if (cfg.isVisible(BuildingField.bathrooms) && project.bathrooms != null)
                    _InfoRow(
                        label: cfg.labelFor(BuildingField.bathrooms),
                        value: '${project.bathrooms}'),
                  if (cfg.isVisible(BuildingField.kitchens) && project.kitchens != null)
                    _InfoRow(
                        label: cfg.labelFor(BuildingField.kitchens),
                        value: '${project.kitchens}'),
                  if (cfg.isVisible(BuildingField.apartmentsPerFloor) &&
                      project.apartmentsPerFloor != null)
                    _InfoRow(
                        label: cfg.labelFor(BuildingField.apartmentsPerFloor),
                        value: '${project.apartmentsPerFloor}'),

                  // Non-residential
                  if (cfg.isVisible(BuildingField.clearHeight) &&
                      project.clearHeight != null)
                    _InfoRow(
                        label: '${cfg.labelFor(BuildingField.clearHeight)} (${cfg.unitFor(BuildingField.clearHeight) ?? 'm'})',
                        value: '${project.clearHeight} m'),
                  if (cfg.isVisible(BuildingField.administrativeArea) &&
                      project.administrativeArea != null)
                    _InfoRow(
                        label: '${cfg.labelFor(BuildingField.administrativeArea)} (m²)',
                        value: '${project.administrativeArea} m²'),
                  if (cfg.isVisible(BuildingField.commercialUnits) &&
                      project.commercialUnits != null)
                    _InfoRow(
                        label: cfg.labelFor(BuildingField.commercialUnits),
                        value: '${project.commercialUnits}'),
                  if (cfg.isVisible(BuildingField.workstations) &&
                      project.workstations != null)
                    _InfoRow(
                        label: cfg.labelFor(BuildingField.workstations),
                        value: '${project.workstations}'),
                  if (cfg.isVisible(BuildingField.loadingArea) &&
                      project.loadingArea != null)
                    _InfoRow(
                        label: '${cfg.labelFor(BuildingField.loadingArea)} (m²)',
                        value: '${project.loadingArea} m²'),

                  // Common optional
                  if (cfg.isVisible(BuildingField.parkingSpaces) &&
                      project.parkingSpaces != null)
                    _InfoRow(
                        label: cfg.labelFor(BuildingField.parkingSpaces),
                        value: '${project.parkingSpaces}'),
                  _InfoRow(
                      label: cfg.labelFor(BuildingField.constructionSystem),
                      value: _constructionSystemLabel(project.constructionSystem)),
                  _InfoRow(
                      label: cfg.labelFor(BuildingField.finishLevel),
                      value: _finishLevelLabel(project.finishLevel)),
                  _InfoRow(
                      label: '${cfg.labelFor(BuildingField.wastePercentage)} (%)',
                      value: '${project.wastePercentage}%'),

                  if (cfg.isVisible(BuildingField.hasRoofSlab))
                    _InfoRow(
                        label: cfg.labelFor(BuildingField.hasRoofSlab),
                        value: project.hasRoofSlab ? 'Sí' : 'No'),
                  if (cfg.isVisible(BuildingField.hasExteriorWalls))
                    _InfoRow(
                        label: cfg.labelFor(BuildingField.hasExteriorWalls),
                        value: project.hasExteriorWalls ? 'Sí' : 'No'),

                  if (project.customDescription != null &&
                      project.customDescription!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                        label: 'Descripción personalizada',
                        value: project.customDescription!),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _buildingTypeLabel(BuildingType type) {
    switch (type) {
      case BuildingType.house:
        return 'Casa';
      case BuildingType.residentialBuilding:
        return 'Edificio Residencial';
      case BuildingType.commercialBuilding:
        return 'Edificio Comercial';
      case BuildingType.commercialSpace:
        return 'Local Comercial';
      case BuildingType.office:
        return 'Oficina';
      case BuildingType.warehouse:
        return 'Bodega / Almacén';
      case BuildingType.custom:
        return 'Personalizado';
    }
  }

  String _constructionSystemLabel(ConstructionSystem sys) {
    switch (sys) {
      case ConstructionSystem.reinforcedConcrete:
        return 'Hormigón Armado';
      case ConstructionSystem.masonry:
        return 'Albañilería';
      case ConstructionSystem.steelStructure:
        return 'Estructura Metálica';
      case ConstructionSystem.mixed:
        return 'Mixto';
    }
  }

  String _finishLevelLabel(FinishLevel level) {
    switch (level) {
      case FinishLevel.basic:
        return 'Básico';
      case FinishLevel.standard:
        return 'Estándar';
      case FinishLevel.premium:
        return 'Premium';
    }
  }
}

// ── Shared info row widget ────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}