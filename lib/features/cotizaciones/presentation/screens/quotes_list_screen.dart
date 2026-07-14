import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cotizacion_provider.dart';

class QuotesListScreen extends ConsumerWidget {
  const QuotesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cotizacionesAsync = ref.watch(cotizacionesConstructoraProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Solicitudes y Cotizaciones')),
      body: cotizacionesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (cotizaciones) {
          if (cotizaciones.isEmpty) {
            return const Center(child: Text('Aún no has enviado solicitudes de cotización.'));
          }

          return ListView.builder(
            itemCount: cotizaciones.length,
            itemBuilder: (context, index) {
              final cot = cotizaciones[index];
              final proforma = cot['proformas'];
              final proyecto = proforma?['proyectos'];
              final nombreProyecto = proyecto?['nombre'] ?? proforma?['nombre'] ?? 'Sin nombre';
              final ferreteria = cot['ferreterias'];
              final estado = cot['estado'];
              final total = cot['total_cotizado'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Proyecto: $nombreProyecto', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Ferretería: ${ferreteria?['nombre_comercial'] ?? 'Desconocida'}'),
                      Text('Estado: $estado'),
                      if (estado == 'cotizada' || estado == 'aceptada')
                        Text('Total: \$${total?.toStringAsFixed(2) ?? '0.00'}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      if (estado == 'cotizada') ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              onPressed: () async {
                                final repo = ref.read(cotizacionRepositoryProvider);
                                await repo.aceptarCotizacion(cot['id']);
                                ref.refresh(cotizacionesConstructoraProvider);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cotización aceptada')));
                                }
                              },
                              child: const Text('Aceptar Oferta', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        )
                      ]
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
