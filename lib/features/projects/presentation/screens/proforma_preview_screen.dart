import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../proformas/services/proforma_pdf_service.dart';
import '../providers/project_form_provider.dart';

class ProformaPreviewScreen extends ConsumerWidget {
  const ProformaPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(calculationResultProvider);
    final form = ref.watch(projectFormProvider);

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Proforma')),
        body: const Center(
          child: Text('No hay datos para generar la proforma.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Vista previa - Proforma')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BuildScan - Proforma',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(),
                    Text('Proyecto: ${form.nombre}'),
                    Text('Área: ${result.areaCalculada.toStringAsFixed(2)} m²'),
                    Text('Desperdicio: ${result.desperdicio.toStringAsFixed(0)}%'),
                    const SizedBox(height: 8),
                    Text(result.sugerencia),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Detalle de materiales',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Table(
              border: TableBorder.all(),
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer),
                  children: const [
                    Padding(padding: EdgeInsets.all(8), child: Text('Material', style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(8), child: Text('Cantidad', style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(8), child: Text('Unidad', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
                ...result.materiales.map((m) => TableRow(children: [
                      Padding(padding: const EdgeInsets.all(8), child: Text(m.nombre)),
                      Padding(padding: const EdgeInsets.all(8), child: Text(m.cantidad.toStringAsFixed(2))),
                      Padding(padding: const EdgeInsets.all(8), child: Text(m.unidad)),
                    ])),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final service = ProformaPdfService();
                      final pdfBytes = await service.buildPdf(
                        projectName: form.nombre,
                        area: result.areaCalculada,
                        suggestion: result.sugerencia,
                        materials: result.materiales,
                      );
                      await service.shareProforma(pdfBytes);
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Compartir'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
