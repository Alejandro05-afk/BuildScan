enum ConstructionType {
  paredLadrillo,
  losaHormigon,
  pisoCeramico,
  cuartoBasico,
}
 
class ProjectDimensions {
  final double largo;
  final double ancho;
  final double alto;
 
  const ProjectDimensions({
    required this.largo,
    required this.ancho,
    this.alto = 0,
  });
 
  double get areaPiso => largo * ancho;
  double get areaPared => largo * alto;
}
