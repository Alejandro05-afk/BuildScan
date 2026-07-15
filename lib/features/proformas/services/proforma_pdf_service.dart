import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../projects/domain/entities/project_entity.dart';
import '../../calculation/domain/entities/material_estimate.dart';
import 'package:intl/intl.dart';

class ProformaPdfService {
  Future<Uint8List> generatePdf({
    required String proformaId,
    required ProjectEntity project,
    required List<MaterialEstimate> materials,
    String? constructoraEmail,
    Uint8List? logoBytes,
  }) async {
    final pdf = pw.Document();
    
    // Configuración de logo
    pw.Widget logoWidget;
    if (logoBytes != null) {
      logoWidget = pw.Image(pw.MemoryImage(logoBytes), height: 50);
    } else {
      logoWidget = pw.Text('BuildScan', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.teal));
    }

    final fechaFormateada = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 10.0),
          child: pw.Text('Página ${context.pageNumber} de ${context.pagesCount}', style: const pw.TextStyle(color: PdfColors.grey)),
        ),
        build: (context) => [
          // Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              logoWidget,
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('PROFORMA DE MATERIALES', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text('ID: $proformaId', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  pw.Text('Fecha: $fechaFormateada', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  if (constructoraEmail != null)
                    pw.Text('Solicitante: $constructoraEmail', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          
          // Project Details
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Proyecto: ${project.nombre}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text('Tipo de obra: ${project.tipoConstruccion.name}'),
                pw.Text('Dimensiones: ${project.largo}m x ${project.ancho}m x ${project.alto}m'),
                pw.Text('Área calculada: ${project.area.toStringAsFixed(2)} m²'),
                pw.Text('Desperdicio aplicado: ${project.porcentajeDesperdicio}%'),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          
          if (project.sugerencia != null) ...[
            pw.Text('Criterio Técnico / Sugerencia:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(project.sugerencia!),
            pw.SizedBox(height: 16),
          ],
          
          // Materials Table
          pw.Text('Listado de Materiales (Cantidades Estimadas)', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: ['Material', 'Cantidad', 'Unidad'],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
            cellAlignment: pw.Alignment.centerLeft,
            data: materials.map((m) => [
              m.nombre,
              m.cantidad.toStringAsFixed(2),
              m.unidad,
            ]).toList(),
          ),
          pw.SizedBox(height: 30),
          
          // Warning footer
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.orange50,
              border: pw.Border.all(color: PdfColors.orange),
            ),
            child: pw.Text(
              'ADVERTENCIA: Las cantidades presentadas son estimaciones referenciales para facilitar una cotización inicial. No sustituyen cálculos estructurales, planos aprobados ni la revisión de un profesional competente.',
              style: pw.TextStyle(color: PdfColors.orange900, fontSize: 10, fontStyle: pw.FontStyle.italic),
            ),
          ),
        ],
      ),
    );
 
    return pdf.save();
  }
}
