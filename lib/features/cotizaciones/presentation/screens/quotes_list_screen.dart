import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cotizacion_provider.dart';

class QuotesListScreen extends ConsumerWidget {
  const QuotesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cotizacionesAsync = ref.watch(cotizacionesConstructoraProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparar y Administrar Ofertas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(cotizacionesConstructoraProvider);
            },
          )
        ],
      ),
      body: cotizacionesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (cotizaciones) {
          if (cotizaciones.isEmpty) {
            return const Center(child: Text('Aún no has enviado solicitudes de cotización.'));
          }

          // Group by proforma_id
          final Map<String, List<Map<String, dynamic>>> grouped = {};
          for (final cot in cotizaciones) {
            final proformaId = cot['proforma_id'];
            grouped.putIfAbsent(proformaId, () => []).add(cot);
          }

          return RefreshIndicator(
            onRefresh: () async {
              return ref.refresh(cotizacionesConstructoraProvider.future);
            },
            child: ListView.builder(
              itemCount: grouped.keys.length,
              itemBuilder: (context, index) {
                final proformaId = grouped.keys.elementAt(index);
                final offers = grouped[proformaId]!;
                final proforma = offers.first['proformas'];
                final proyecto = proforma?['proyectos'];
                final nombreProyecto = proyecto?['nombre'] ?? proforma?['nombre'] ?? 'Sin nombre';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  child: ExpansionTile(
                    title: Text('Proyecto: $nombreProyecto', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${offers.length} solicitud(es) enviada(s)'),
                    children: offers.map((cot) {
                      final ferreteria = cot['ferreterias'];
                      final estado = cot['estado'];
                      final total = cot['total_cotizado'];
                      final isCotizada = estado == 'cotizada';

                      return ListTile(
                        title: Text(ferreteria?['nombre_comercial'] ?? 'Desconocida'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Estado: ${estado.toUpperCase()}'),
                            if (isCotizada || estado == 'aceptada')
                              Text(
                                'Total Oferta: \$${total?.toStringAsFixed(2) ?? '0.00'}', 
                                style: TextStyle(color: estado == 'aceptada' ? Colors.green : Colors.blue, fontWeight: FontWeight.bold),
                              ),
                            if (isCotizada) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                      onPressed: () async {
                                        try {
                                          await ref.read(cotizacionRepositoryProvider).aceptarCotizacion(cot['id'], proformaId);
                                          ref.invalidate(cotizacionesConstructoraProvider);
                                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cotización aceptada, las demás fueron rechazadas.')));
                                        } catch (e) {
                                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                        }
                                      },
                                      child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                      onPressed: () async {
                                        await ref.read(cotizacionRepositoryProvider).rechazarCotizacion(cot['id']);
                                        ref.invalidate(cotizacionesConstructoraProvider);
                                      },
                                      child: const Text('Rechazar'),
                                    ),
                                  ),
                                ],
                              )
                            ]
                          ],
                        ),
                        isThreeLine: true,
                      );
                    }).toList(),
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
