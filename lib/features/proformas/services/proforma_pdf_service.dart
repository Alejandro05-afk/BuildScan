import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../calculation/domain/entities/material_estimate.dart';
 
class ProformaPdfService {
  Future<Uint8List> buildPdf({
    required String projectName,
    required double area,
    required String suggestion,
    required List<MaterialEstimate> materials,
  }) async {
    final pdf = pw.Document();
 
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('BuildScan - Proforma de materiales'),
          ),
          pw.Text('Proyecto: $projectName'),
          pw.Text('Área calculada: ${area.toStringAsFixed(2)} m²'),
          pw.SizedBox(height: 8),
          pw.Text('Sugerencia: $suggestion'),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: ['Material', 'Cantidad', 'Unidad'],
            data: materials.map((m) => [
              m.nombre,
              m.cantidad.toStringAsFixed(2),
              m.unidad,
            ]).toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Nota: valores estimados para fines de cotización inicial.'),
        ],
      ),
    );
 
    return pdf.save();
  }

  Future<void> shareProforma(Uint8List bytes) async {
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'buildscan_proforma.pdf',
    );
  }
}
