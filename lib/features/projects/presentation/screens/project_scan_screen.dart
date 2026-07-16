import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/storage_service.dart';

class ProjectScanScreen extends ConsumerStatefulWidget {
  const ProjectScanScreen({super.key});

  @override
  ConsumerState<ProjectScanScreen> createState() => _ProjectScanScreenState();
}

class _ProjectScanScreenState extends ConsumerState<ProjectScanScreen> {
  MobileScannerController? _controller;
  bool _scanned = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String? _parseProjectId(String rawValue) {
    final uri = Uri.tryParse(rawValue);
    if (uri != null && uri.scheme == 'buildscan' && uri.pathSegments.length >= 2) {
      return uri.pathSegments.last;
    }
    if (rawValue.length == 36 && rawValue.contains('-')) {
      return rawValue;
    }
    return null;
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_scanned || _loading) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final projectId = _parseProjectId(barcode.rawValue!);
    if (projectId == null || projectId.isEmpty) return;

    _scanned = true;
    setState(() => _loading = true);

    try {
      final client = Supabase.instance.client;

      // Look up proforma for this project
      final proformas = await client
          .from('proformas')
          .select('id, pdf_path, nombre')
          .eq('proyecto_id', projectId)
          .order('created_at', ascending: false)
          .limit(1);

      if (proformas.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay proforma generada para este proyecto')),
          );
          setState(() { _loading = false; _scanned = false; });
        }
        return;
      }

      final proforma = proformas[0];
      final pdfPath = proforma['pdf_path'] as String?;

      if (pdfPath == null || pdfPath.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('El PDF de la proforma aún no está disponible')),
          );
          setState(() { _loading = false; _scanned = false; });
        }
        return;
      }

      // Download PDF from storage
      final storage = ref.read(storageServiceProvider);
      final signedUrl = await storage.getSignedUrl('proformas', pdfPath);

      // Download the bytes using dio
      final dio = Dio();
      final response = await dio.get(signedUrl, options: Options(responseType: ResponseType.bytes));
      final pdfBytes = Uint8List.fromList(response.data);

      if (mounted) {
        context.push('/projects/pdf-viewer', extra: {
          'pdfBytes': pdfBytes,
          'title': proforma['nombre'] ?? 'Proforma',
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar proforma: $e')),
        );
        setState(() { _loading = false; _scanned = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: _loading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Cargando proforma...'),
                      ],
                    ),
                  )
                : MobileScanner(
                    controller: _controller,
                    onDetect: _handleBarcode,
                  ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner, size: 48, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 12),
                  const Text(
                    'Apunta la cámara al código QR\ndel proyecto',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
