import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/clay_container_alias.dart';

import '../../../proformas/services/proforma_pdf_service.dart';
import '../../../cotizaciones/presentation/providers/cotizacion_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/project_form_provider.dart';
import '../../domain/entities/project_entity.dart';
import '../../../../core/services/storage_service.dart';

class ProformaPreviewScreen extends ConsumerStatefulWidget {
  final ProjectEntity? savedProject;

  const ProformaPreviewScreen({super.key, this.savedProject});

  @override
  ConsumerState<ProformaPreviewScreen> createState() => _ProformaPreviewScreenState();
}

class _ProformaPreviewScreenState extends ConsumerState<ProformaPreviewScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(calculationResultProvider);
    final form = ref.watch(projectFormProvider);
    final project = widget.savedProject;

    if (result == null || project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Proforma')),
        body: const Center(
          child: Text('No hay datos o no se ha guardado el proyecto.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proforma Guardada'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClayContainer(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: 16,
                  depth: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BuildScan - Proforma',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        Text('Proyecto: ${project.nombre}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('ID: ${project.id}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text('Área: ${result.areaCalculada.toStringAsFixed(2)} m²'),
                        Text('Desperdicio: ${result.desperdicio.toStringAsFixed(0)}%'),
                        const SizedBox(height: 12),
                        ClayContainer(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: 8,
                          depth: -5,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(result.sugerencia, style: const TextStyle(fontStyle: FontStyle.italic)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Detalle de materiales',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Table(
                  border: TableBorder.all(color: Colors.grey.shade300),
                  columnWidths: const {
                    0: FlexColumnWidth(3),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(2),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer),
                      children: const [
                        Padding(padding: EdgeInsets.all(12), child: Text('Material', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(12), child: Text('Cantidad', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(12), child: Text('Unidad', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                    ...result.materiales.map((m) => TableRow(children: [
                          Padding(padding: const EdgeInsets.all(12), child: Text(m.nombre)),
                          Padding(padding: const EdgeInsets.all(12), child: Text(m.cantidad.toStringAsFixed(0))),
                          Padding(padding: const EdgeInsets.all(12), child: Text(m.unidad)),
                        ])),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => _generarYSolicitarCotizacion(context, ref, project, result),
                  icon: const Icon(Icons.send_and_archive),
                  label: const Text('Solicitar Cotización'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _generarYSolicitarCotizacion(BuildContext context, WidgetRef ref, ProjectEntity project, dynamic result) async {
    setState(() => _isLoading = true);
    
    try {
      final user = ref.read(authStateProvider).value?.session?.user;
      if (user == null) throw Exception("Usuario no autenticado");

      final repo = ref.read(cotizacionRepositoryProvider);
      final storage = ref.read(storageServiceProvider);
      final pdfService = ProformaPdfService();

      final List<Map<String, dynamic>> materialesJson = result.materiales.map<Map<String, dynamic>>((m) => <String, dynamic>{
        'nombre': m.nombre,
        'cantidad': m.cantidad,
        'unidad': m.unidad,
      }).toList();

      // 1. Crear Proforma en BD
      final proformaId = await repo.crearProforma(
        proyectoId: project.id,
        constructoraId: user.id,
        nombre: 'Cotización - ${project.nombre}',
        materialesJson: materialesJson,
      );

      // 2. Generar PDF
      final pdfBytes = await pdfService.generatePdf(
        proformaId: proformaId,
        project: project,
        materials: result.materiales,
        constructoraEmail: user.email,
        // logoBytes: null, // Podría añadirse si lo cargamos de assets
      );

      // 3. Subir PDF a Storage
      final pdfPath = await storage.uploadProformaPdf(
        userId: user.id,
        proformaId: proformaId,
        bytes: pdfBytes,
      );

      // 4. Actualizar ruta en BD
      await repo.updateProformaPdfPath(proformaId, pdfPath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proforma generada exitosamente')),
        );
        context.push('/map/$proformaId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
