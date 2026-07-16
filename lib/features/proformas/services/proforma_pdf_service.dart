import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../projects/domain/entities/building_project.dart';
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

  // Generate PDF for Complete Building Projects
  Future<Uint8List> generateCompleteBuildingPdf({
    required String proformaId,
    required dynamic project, // using dynamic or specific type
    required List<dynamic> materials, // from calculation result
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
                  pw.Text('ESTIMACIÓN DE EDIFICACIÓN COMPLETA', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.Text('ID: $proformaId', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  pw.Text('Fecha: $fechaFormateada', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          
          // Project Details – dynamic fields based on BuildingTypePolicy
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Proyecto: ${project.name}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text('Tipo: ${_buildingTypeLabel(project.buildingType)}'),
                pw.Text('Área construida: ${project.totalArea.toStringAsFixed(0)} m²'),
                pw.Text('Plantas: ${project.floors}'),
                pw.Text('Sistema constructivo: ${project.constructionSystem.toString().split('.').last}'),
                pw.Text('Nivel de acabados: ${project.finishLevel.toString().split('.').last}'),
                // Dynamic fields from policy:
                ..._buildingProjectDetails(project),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          
          // Materials Table
          pw.Text('Listado de Materiales (Cantidades Referenciales)', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: ['Material', 'Cantidad', 'Categoría'],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
            cellAlignment: pw.Alignment.centerLeft,
            data: materials.map((m) => [
              m.materialName,
              '${m.quantity.toStringAsFixed(1)} ${m.unit}',
              m.category,
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
              'Esta estimación es referencial y no sustituye planos arquitectónicos, estudios de suelo, cálculos estructurales ni la revisión de un profesional competente.',
              style: pw.TextStyle(color: PdfColors.orange900, fontSize: 10, fontStyle: pw.FontStyle.italic),
            ),
          ),
        ],
      ),
    );
 
    return pdf.save();
  }
  /// Returns policy-driven detail rows for a complete building project PDF.
  /// Omits null values and fields invisible for the building type.
  List<pw.Widget> _buildingProjectDetails(BuildingProject project) {
    final cfg = configForType(project.buildingType.toString().split('.').last);
    final rows = <pw.Widget>[];

    void addRow(String label, String value) {
      rows.add(pw.Text('$label: $value'));
    }

    if (cfg.isVisible(BuildingField.bedrooms) && project.bedrooms != null) {
      addRow(cfg.labelFor(BuildingField.bedrooms), '${project.bedrooms}');
    }
    if (cfg.isVisible(BuildingField.bathrooms) && project.bathrooms != null) {
      addRow(cfg.labelFor(BuildingField.bathrooms), '${project.bathrooms}');
    }
    if (cfg.isVisible(BuildingField.kitchens) && project.kitchens != null) {
      addRow(cfg.labelFor(BuildingField.kitchens), '${project.kitchens}');
    }
    if (cfg.isVisible(BuildingField.apartmentsPerFloor) &&
        project.apartmentsPerFloor != null) {
      addRow(cfg.labelFor(BuildingField.apartmentsPerFloor),
          '${project.apartmentsPerFloor}');
    }
    if (cfg.isVisible(BuildingField.clearHeight) && project.clearHeight != null) {
      addRow(cfg.labelFor(BuildingField.clearHeight),
          '${project.clearHeight} ${cfg.unitFor(BuildingField.clearHeight) ?? 'm'}');
    }
    if (cfg.isVisible(BuildingField.administrativeArea) &&
        project.administrativeArea != null) {
      addRow(cfg.labelFor(BuildingField.administrativeArea),
          '${project.administrativeArea} m²');
    }
    if (cfg.isVisible(BuildingField.commercialUnits) && project.commercialUnits != null) {
      addRow(cfg.labelFor(BuildingField.commercialUnits), '${project.commercialUnits}');
    }
    if (cfg.isVisible(BuildingField.workstations) && project.workstations != null) {
      addRow(cfg.labelFor(BuildingField.workstations), '${project.workstations}');
    }
    if (cfg.isVisible(BuildingField.loadingArea) && project.loadingArea != null) {
      addRow(cfg.labelFor(BuildingField.loadingArea), '${project.loadingArea} m²');
    }
    if (cfg.isVisible(BuildingField.parkingSpaces) && project.parkingSpaces != null) {
      addRow(cfg.labelFor(BuildingField.parkingSpaces), '${project.parkingSpaces}');
    }

    return rows;
  }

  String _buildingTypeLabel(BuildingType type) {
    switch (type) {
      case BuildingType.house: return 'Casa';
      case BuildingType.residentialBuilding: return 'Edificio Residencial';
      case BuildingType.commercialBuilding: return 'Edificio Comercial';
      case BuildingType.commercialSpace: return 'Local Comercial';
      case BuildingType.office: return 'Oficina';
      case BuildingType.warehouse: return 'Bodega / Industrial';
      case BuildingType.custom: return 'Construcción Personalizada';
    }
  }
}
