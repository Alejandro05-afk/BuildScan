import '../entities/project_dimensions.dart';

class BuildingSuggestionService {
  String getSuggestion({required double area, required ConstructionType type}) {
    if (type == ConstructionType.paredLadrillo) {
      return 'La pared requiere cálculo por m². Se recomienda validar altura y dejar 10% de desperdicio.';
    }
 
    if (area < 20) {
      return 'El área es ideal para bodega, baño externo o módulo pequeño.';
    } else if (area < 45) {
      return 'El área puede funcionar como habitación básica, local pequeño u oficina.';
    } else if (area < 80) {
      return 'El área permite una vivienda pequeña o ampliación familiar.';
    }
 
    return 'Proyecto de mayor escala. Se recomienda dividir el cálculo por ambientes.';
  }
}
