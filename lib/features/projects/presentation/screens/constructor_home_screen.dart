import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/buildscan_handshake_hero.dart';

class ConstructorHomeScreen extends ConsumerWidget {
  const ConstructorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userEmail = authState.value?.session?.user.email ?? 'Constructor';
    final userName = userEmail.split('@').first;
    // Capitalize name
    final displayName = userName.isNotEmpty 
        ? userName[0].toUpperCase() + userName.substring(1) 
        : 'Andrés';

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh provider manually or via invalidation if needed
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: _HomeHeader(displayName: displayName),
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
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20),
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
                padding: const EdgeInsets.all(20),
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
                        title: 'Proformas',
                        route: '/projects/my_projects', // Proformas listing page uses projects
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
