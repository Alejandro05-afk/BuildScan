import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ConstructorHomeScreen extends ConsumerWidget {
  const ConstructorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BuildScan Constructora'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.construction, size: 48, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 12),
                    Text(
                      'Panel de Constructora',
                      style: Theme.of(context).textTheme.titleLarge,
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
            const SizedBox(height: 24),
            _MenuButton(
              icon: Icons.add_circle_outline,
              label: 'Nuevo Proyecto',
              onTap: () => context.push('/projects/new'),
            ),
            const SizedBox(height: 12),
            _MenuButton(
              icon: Icons.list_alt,
              label: 'Mis Proyectos',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _MenuButton(
              icon: Icons.picture_as_pdf,
              label: 'Generar Proforma',
              onTap: () => context.push('/proforma'),
            ),
            const SizedBox(height: 12),
            _MenuButton(
              icon: Icons.request_quote,
              label: 'Solicitudes de Cotización',
              onTap: () => context.push('/quotes'),
            ),
            const SizedBox(height: 12),
            _MenuButton(
              icon: Icons.map,
              label: 'Mapa de Ferreterías',
              onTap: () => context.push('/map'),
            ),
            const SizedBox(height: 12),
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
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
