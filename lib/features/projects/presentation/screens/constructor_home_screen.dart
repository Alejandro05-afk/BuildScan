import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/widgets/buildscan_handshake_hero.dart';
import '../../../cotizaciones/presentation/providers/cotizacion_provider.dart';
import '../../../projects/presentation/providers/projects_provider.dart';
import '../../../../core/widgets/dashboard_stat_card.dart';

class ConstructorHomeScreen extends ConsumerWidget {
  const ConstructorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final projectsAsync = ref.watch(myProjectsRawProvider);
    final cotizacionesAsync = ref.watch(cotizacionesConstructoraProvider);

    final userName = profileAsync.value?.nombre ?? 'Constructor';

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myProjectsRawProvider);
            ref.invalidate(cotizacionesConstructoraProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: _HomeHeader(displayName: userName),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                sliver: SliverToBoxAdapter(
                  child: _StatsSection(
                    projectsAsync: projectsAsync,
                    cotizacionesAsync: cotizacionesAsync,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(
                  child: BuildScanHandshakeHero(
                    primaryButtonText: 'Nuevo proyecto',
                    secondaryButtonText: 'Cotizaciones',
                    onNewProject: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (ctx) => Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '¿Qué deseas calcular?',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)
                              ),
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
                    onQuotes: () {
                      context.push('/quotes');
                    },
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                sliver: projectsAsync.when(
                  loading: () => const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 60,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (e, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                  data: (projects) {
                    if (projects.isEmpty) {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }
                    final recent = projects.take(3).toList();
                    return SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Proyectos recientes',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.push('/projects/my_projects'),
                                child: const Text('Ver todos'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...recent.map((p) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _RecentProjectCard(project: p),
                          )),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Accesos rápidos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                sliver: SliverGrid(
                  delegate: SliverChildListDelegate.fixed(
                    [
                      const _QuickAccessCard(
                        icon: Icons.folder_copy_rounded,
                        title: 'Mis proyectos',
                        route: '/projects/my_projects',
                      ),
                      const _QuickAccessCard(
                        icon: Icons.map_rounded,
                        title: 'Ferreterías',
                        route: '/map',
                      ),
                      const _QuickAccessCard(
                        icon: Icons.description_rounded,
                        title: 'Cotizaciones',
                        route: '/quotes',
                      ),
                      const _QuickAccessCard(
                        icon: Icons.qr_code_scanner,
                        title: 'Escanear QR',
                        route: '/projects/scan',
                      ),
                      _QuickAccessCard(
                        icon: Icons.logout,
                        title: 'Cerrar Sesión',
                        route: '/login',
                        onTap: () async {
                          final repo = ref.read(authRepositoryProvider);
                          await repo.cerrarSesion();
                        },
                      ),
                    ],
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final String displayName;
  const _HomeHeader({required this.displayName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, $displayName',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Gestiona tus proyectos de construcción',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none_rounded,
          ),
        ),
      ],
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({
    required this.projectsAsync,
    required this.cotizacionesAsync,
  });

  final AsyncValue<List> projectsAsync;
  final AsyncValue<List<Map<String, dynamic>>> cotizacionesAsync;

  @override
  Widget build(BuildContext context) {
    final totalProjects = projectsAsync.value?.length ?? 0;
    final cotizaciones = cotizacionesAsync.value ?? [];
    final pendingQuotes = cotizaciones.where((c) => c['estado'] == 'enviada').length;
    final acceptedQuotes = cotizaciones.where((c) => c['estado'] == 'aceptada').length;

    return Row(
      children: [
        Expanded(
          child: DashboardStatCard(
            title: 'Proyectos',
            value: '$totalProjects',
            icon: Icons.folder_copy_rounded,
            color: const Color(0xFF0B7A75),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DashboardStatCard(
            title: 'Pendientes',
            value: '$pendingQuotes',
            icon: Icons.schedule_rounded,
            subtitle: 'cotizaciones',
            color: const Color(0xFFFF8A00),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DashboardStatCard(
            title: 'Aceptadas',
            value: '$acceptedQuotes',
            icon: Icons.check_circle_outline_rounded,
            color: const Color(0xFF2E7D32),
          ),
        ),
      ],
    );
  }
}

class _RecentProjectCard extends StatelessWidget {
  const _RecentProjectCard({required this.project});

  final Map<String, dynamic> project;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tipoLabel = _typeLabel(project);
    final area = ((project['area'] as num?) ?? (project['area_m2'] as num?) ?? 0).toDouble();
    final createdAt = project['created_at'] != null
        ? DateTime.tryParse(project['created_at'].toString())
        : null;

    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => context.push('/projects/detail/${project['id']}'),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.construction_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project['nombre'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tipoLabel,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${area.toStringAsFixed(1)} m²',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  if (createdAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _typeLabel(Map<String, dynamic> proj) {
    final scope = proj['project_scope'] as String?;
    if (scope == 'completeBuilding') {
      return _buildingTypeLabel(proj['building_type'] as String?);
    }
    final rawType = proj['tipo_construccion'] as String? ?? 'wall';
    switch (rawType) {
      case 'wall':
      case 'paredLadrillo':
      case 'pared_ladrillo':
      case 'pared':
        return 'Pared';
      case 'ceramic_floor':
      case 'pisoCeramico':
      case 'piso_ceramico':
      case 'piso':
        return 'Piso cerámico';
      case 'concrete_slab':
      case 'losaHormigon':
      case 'losa_hormigon':
      case 'losa':
        return 'Losa de hormigón';
      case 'room':
      case 'cuartoBasico':
      case 'cuarto_basico':
      case 'cuarto':
        return 'Cuarto básico';
      case 'roof':
      case 'techo':
        return 'Techo / Cubierta';
      default:
        return rawType;
    }
  }

  String _buildingTypeLabel(String? buildingType) {
    switch (buildingType) {
      case 'house':
        return 'Casa';
      case 'residentialBuilding':
        return 'Edificio Residencial';
      case 'commercialBuilding':
        return 'Edificio Comercial';
      case 'commercialSpace':
        return 'Local Comercial';
      case 'office':
        return 'Oficina';
      case 'warehouse':
        return 'Bodega / Almacén';
      case 'custom':
      default:
        return 'Personalizado';
    }
  }
}

class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.route,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String route;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap ?? () {
          context.push(route);
        },
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
