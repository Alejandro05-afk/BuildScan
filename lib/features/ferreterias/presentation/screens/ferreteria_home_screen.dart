import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cotizaciones/presentation/providers/cotizacion_provider.dart';
import '../../../../core/widgets/dashboard_stat_card.dart';

class FerreteriaHomeScreen extends ConsumerStatefulWidget {
  const FerreteriaHomeScreen({super.key});

  @override
  ConsumerState<FerreteriaHomeScreen> createState() => _FerreteriaHomeScreenState();
}

class _FerreteriaHomeScreenState extends ConsumerState<FerreteriaHomeScreen> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final solicitudesAsync = ref.watch(solicitudesFerreteriaProvider);
    final profileAsync = ref.watch(profileProvider);

    final userName = profileAsync.value?.nombre ?? 'Ferretería';

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(solicitudesFerreteriaProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: _HomeHeader(
                    displayName: userName,
                    onSettings: () => context.push('/ferreteria/profile'),
                    onLogout: () async {
                      await ref.read(authRepositoryProvider).cerrarSesion();
                    },
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                sliver: SliverToBoxAdapter(
                  child: solicitudesAsync.when(
                    loading: () => const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => SizedBox(
                      height: 100,
                      child: Center(child: Text('Error: $e')),
                    ),
                    data: (solicitudes) => _StatsSection(solicitudes: solicitudes),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Solicitudes recientes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (solicitudesAsync.value != null &&
                          solicitudesAsync.value!.isNotEmpty) ...[
                        if (solicitudesAsync.value!.length > 5)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showAll = !_showAll;
                              });
                            },
                            child: Text(_showAll ? 'Ver menos' : 'Ver todas'),
                          ),
                        Text(
                          '${solicitudesAsync.value!.length} total',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: solicitudesAsync.when(
                  loading: () => const SliverToBoxAdapter(
                    child: Center(child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    )),
                  ),
                  error: (e, _) => SliverToBoxAdapter(
                    child: Center(child: Text('Error: $e')),
                  ),
                  data: (solicitudes) {
                    if (solicitudes.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 120,
                                width: double.infinity,
                                child: Lottie.asset(
                                  'assets/animations/buildscan_tools.json',
                                  repeat: true,
                                  animate: true,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.build_rounded,
                                      size: 60,
                                      color: Theme.of(context).colorScheme.primary,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No tienes solicitudes pendientes',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Las solicitudes de cotización aparecerán aquí',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    final recent = _showAll ? solicitudes : solicitudes.take(5).toList();
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _SolicitudCard(solicitud: recent[index]),
                        ),
                        childCount: recent.length,
                      ),
                    );
                  },
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Accesos rápidos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                sliver: SliverGrid(
                  delegate: SliverChildListDelegate.fixed(
                    [
                      const _QuickAccessCard(
                        icon: Icons.person_outline_rounded,
                        title: 'Mi perfil',
                        route: '/ferreteria/profile',
                      ),
                      _QuickAccessCard(
                        icon: Icons.logout,
                        title: 'Cerrar Sesión',
                        route: '/login',
                        onTap: () async {
                          await ref.read(authRepositoryProvider).cerrarSesion();
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
  const _HomeHeader({
    required this.displayName,
    required this.onSettings,
    required this.onLogout,
  });

  final String displayName;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

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
                'Gestiona tus cotizaciones',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: onSettings,
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Configurar Ferretería',
        ),
        const SizedBox(width: 4),
        IconButton.filledTonal(
          onPressed: onLogout,
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'Cerrar Sesión',
        ),
      ],
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.solicitudes});

  final List<Map<String, dynamic>> solicitudes;

  @override
  Widget build(BuildContext context) {
    final total = solicitudes.length;
    final enviadas = solicitudes.where((s) => s['estado'] == 'enviada').length;
    final cotizadas = solicitudes.where((s) => s['estado'] == 'cotizada').length;
    final aceptadas = solicitudes.where((s) => s['estado'] == 'aceptada').length;
    final rechazadas = solicitudes.where((s) => s['estado'] == 'rechazada').length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DashboardStatCard(
                title: 'Recibidas',
                value: '$total',
                icon: Icons.inbox_rounded,
                color: const Color(0xFF0B7A75),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardStatCard(
                title: 'Pendientes',
                value: '$enviadas',
                icon: Icons.schedule_rounded,
                color: const Color(0xFFFF8A00),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardStatCard(
                title: 'Cotizadas',
                value: '$cotizadas',
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xFF1565C0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DashboardStatCard(
                title: 'Aceptadas',
                value: '$aceptadas',
                icon: Icons.thumb_up_alt_outlined,
                color: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardStatCard(
                title: 'Rechazadas',
                value: '$rechazadas',
                icon: Icons.thumb_down_alt_outlined,
                color: const Color(0xFFC62828),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }
}

class _SolicitudCard extends StatelessWidget {
  const _SolicitudCard({required this.solicitud});

  final Map<String, dynamic> solicitud;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final proforma = solicitud['proformas'];
    final proyecto = proforma?['proyectos'];
    final nombreProyecto = proyecto?['nombre'] ?? proforma?['nombre'] ?? 'Sin nombre';
    final estado = solicitud['estado'];
    final fecha = solicitud['created_at']?.toString().substring(0, 10) ?? 'N/A';

    final Color estadoColor;
    final Color estadoBg;
    final IconData estadoIcon;
    switch (estado) {
      case 'enviada':
        estadoColor = Colors.orange.shade800;
        estadoBg = Colors.orange.shade50;
        estadoIcon = Icons.send_rounded;
        break;
      case 'cotizada':
        estadoColor = Colors.blue.shade700;
        estadoBg = Colors.blue.shade50;
        estadoIcon = Icons.check_circle_outline_rounded;
        break;
      case 'aceptada':
        estadoColor = Colors.green.shade700;
        estadoBg = Colors.green.shade50;
        estadoIcon = Icons.thumb_up_alt_rounded;
        break;
      case 'rechazada':
        estadoColor = Colors.red.shade700;
        estadoBg = Colors.red.shade50;
        estadoIcon = Icons.thumb_down_alt_rounded;
        break;
      default:
        estadoColor = Colors.grey.shade700;
        estadoBg = Colors.grey.shade100;
        estadoIcon = Icons.help_outline_rounded;
    }

    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () {
          if (estado == 'enviada') {
            context.push('/responder-cotizacion', extra: solicitud);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Esta solicitud ya fue $estado')),
            );
          }
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: estadoColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(estadoIcon, color: estadoColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombreProyecto,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Fecha: $fecha',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: estadoBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  estado.toString().toUpperCase(),
                  style: TextStyle(
                    color: estadoColor,
                    fontSize: 11,
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
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
