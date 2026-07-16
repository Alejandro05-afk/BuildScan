import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cotizaciones/presentation/providers/cotizacion_provider.dart';

class FerreteriaHomeScreen extends ConsumerWidget {
  const FerreteriaHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final solicitudesAsync = ref.watch(solicitudesFerreteriaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes Recibidas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configurar Ferretería',
            onPressed: () => context.push('/ferreteria/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authRepositoryProvider).cerrarSesion();
            },
          )
        ],
      ),
      body: solicitudesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (solicitudes) {
          if (solicitudes.isEmpty) {
            return const Center(child: Text('No tienes solicitudes pendientes.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              return ref.refresh(solicitudesFerreteriaProvider.future);
            },
            child: ListView.builder(
              itemCount: solicitudes.length,
              itemBuilder: (context, index) {
                final sol = solicitudes[index];
                final proforma = sol['proformas'];
                final proyecto = proforma?['proyectos'];
                final nombreProyecto = proyecto?['nombre'] ?? proforma?['nombre'] ?? 'Proforma sin nombre';
                final estado = sol['estado'];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.request_quote, color: Colors.white),
                    ),
                    title: Text(nombreProyecto, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Estado: ${estado.toString().toUpperCase()}\nFecha: ${sol['created_at']?.toString().substring(0, 10) ?? 'N/A'}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      if (estado == 'enviada') {
                        context.push('/responder-cotizacion', extra: sol);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Esta solicitud ya fue $estado')));
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
