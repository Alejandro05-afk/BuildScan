import '../../../calculation/domain/entities/project_dimensions.dart';

class ProjectFormState {
  final String nombre;
  final ConstructionType tipoConstruccion;
  final double largo;
  final double ancho;
  final double alto;
  final double desperdicio;
  final bool isValid;

  const ProjectFormState({
    this.nombre = '',
    this.tipoConstruccion = ConstructionType.paredLadrillo,
    this.largo = 0,
    this.ancho = 0,
    this.alto = 0,
    this.desperdicio = 10,
    this.isValid = false,
  });

  ProjectFormState copyWith({
    String? nombre,
    ConstructionType? tipoConstruccion,
    double? largo,
    double? ancho,
    double? alto,
    double? desperdicio,
    bool? isValid,
  }) {
    return ProjectFormState(
      nombre: nombre ?? this.nombre,
      tipoConstruccion: tipoConstruccion ?? this.tipoConstruccion,
      largo: largo ?? this.largo,
      ancho: ancho ?? this.ancho,
      alto: alto ?? this.alto,
      desperdicio: desperdicio ?? this.desperdicio,
      isValid: isValid ?? this.isValid,
    );
  }
}
