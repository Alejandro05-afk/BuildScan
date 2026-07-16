import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: Lottie.asset(
                      'assets/animations/buildscan_tools.json',
                      repeat: true,
                      animate: true,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.build_rounded,
                          size: 80,
                          color: Theme.of(context).colorScheme.primary,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No tienes solicitudes pendientes.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
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

                final Color estadoColor;
                final Color estadoBg;
                switch (estado) {
                  case 'enviada':
                    estadoColor = Colors.orange.shade800;
                    estadoBg = Colors.orange.shade50;
                    break;
                  case 'cotizada':
                    estadoColor = Colors.blue.shade700;
                    estadoBg = Colors.blue.shade50;
                    break;
                  case 'aceptada':
                    estadoColor = Colors.green.shade700;
                    estadoBg = Colors.green.shade50;
                    break;
                  case 'rechazada':
                    estadoColor = Colors.red.shade700;
                    estadoBg = Colors.red.shade50;
                    break;
                  default:
                    estadoColor = Colors.grey.shade700;
                    estadoBg = Colors.grey.shade100;
                }

                final Icon iconoEstado;
                switch (estado) {
                  case 'enviada':
                    iconoEstado = const Icon(Icons.send, color: Colors.white);
                    break;
                  case 'cotizada':
                    iconoEstado = const Icon(Icons.check_circle_outline, color: Colors.white);
                    break;
                  case 'aceptada':
                    iconoEstado = const Icon(Icons.thumb_up, color: Colors.white);
                    break;
                  case 'rechazada':
                    iconoEstado = const Icon(Icons.thumb_down, color: Colors.white);
                    break;
                  default:
                    iconoEstado = Icon(Icons.help_outline, color: Colors.grey.shade600);
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: estadoColor,
                      child: iconoEstado,
                    ),
                    title: Text(nombreProyecto, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'Fecha: ${sol['created_at']?.toString().substring(0, 10) ?? 'N/A'}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: estadoBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        estado.toString().toUpperCase(),
                        style: TextStyle(color: estadoColor, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
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
