import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/clay_container_alias.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/buildscan_theme.dart';

class ConstructorHomeScreen extends ConsumerWidget {
  const ConstructorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: BuildScanColors.background,
      appBar: AppBar(
        title: const Text('BuildScan Constructora'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClayContainer(
              color: BuildScanColors.background,
              borderRadius: 20,
              depth: 15,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.construction, size: 64, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Panel de Constructora',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gestiona tus proyectos y proformas de materiales',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            _MenuButton(
              icon: Icons.list_alt,
              label: 'Mis Proyectos',
              onTap: () => context.push('/projects/my_projects'),
            ),
            const SizedBox(height: 16),
            _MenuButton(
              icon: Icons.request_quote,
              label: 'Solicitudes de Cotización',
              onTap: () => context.push('/quotes'),
            ),
            const SizedBox(height: 16),
            _MenuButton(
              icon: Icons.map,
              label: 'Mapa de Ferreterías',
              onTap: () => context.push('/map'),
            ),
            const SizedBox(height: 32),
            _MenuButton(
              icon: Icons.logout,
              label: 'Cerrar Sesión',
              onTap: () async {
                final repo = ref.read(authRepositoryProvider);
                await repo.cerrarSesion();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClayContainer(
        color: BuildScanColors.background,
        borderRadius: 12,
        depth: 10,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
