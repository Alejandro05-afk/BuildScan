class MaterialEstimate {
  final String nombre;
  final String unidad;
  final double cantidad;
  final String observacion;
 
  const MaterialEstimate({
    required this.nombre,
    required this.unidad,
    required this.cantidad,
    this.observacion = '',
  });
}
 
class CalculationResult {
  final double areaCalculada;
  final double desperdicio;
  final String sugerencia;
  final List<MaterialEstimate> materiales;
 
  const CalculationResult({
    required this.areaCalculada,
    required this.desperdicio,
    required this.sugerencia,
    required this.materiales,
  });
}
