import '../entities/building_project.dart';

class AreaDistributionItem {
  final String spaceName;
  final double estimatedArea;
  final double percentage;

  AreaDistributionItem({
    required this.spaceName,
    required this.estimatedArea,
    required this.percentage,
  });
}

class BuildingAreaDistribution {
  final List<AreaDistributionItem> items;
  final double totalArea;

  BuildingAreaDistribution({
    required this.items,
    required this.totalArea,
  });
}

class BuildingAreaDistributionService {
  BuildingAreaDistribution estimateDistribution(BuildingType type, double totalArea) {
    final items = <AreaDistributionItem>[];

    switch (type) {
      case BuildingType.house:
        items.add(_createItem('Dormitorios', 0.30, totalArea)); // 30%
        items.add(_createItem('Sala y comedor', 0.25, totalArea)); // 25%
        items.add(_createItem('Cocina', 0.10, totalArea)); // 10%
        items.add(_createItem('Baños', 0.08, totalArea)); // 8%
        items.add(_createItem('Circulación', 0.12, totalArea)); // 12%
        items.add(_createItem('Servicio/Otros', 0.15, totalArea)); // 15%
        break;
      case BuildingType.residentialBuilding:
        items.add(_createItem('Área útil departamentos', 0.75, totalArea)); // 75%
        items.add(_createItem('Circulación', 0.12, totalArea)); // 12%
        items.add(_createItem('Escaleras/Comunes', 0.10, totalArea)); // 10%
        items.add(_createItem('Servicios', 0.03, totalArea)); // 3%
        break;
      case BuildingType.commercialBuilding:
      case BuildingType.commercialSpace:
        items.add(_createItem('Área comercial útil', 0.70, totalArea)); // 70%
        items.add(_createItem('Circulación', 0.15, totalArea)); // 15%
        items.add(_createItem('Administración', 0.08, totalArea)); // 8%
        items.add(_createItem('Sanitarios', 0.07, totalArea)); // 7%
        break;
      case BuildingType.warehouse:
        items.add(_createItem('Área libre almacenaje', 0.85, totalArea)); // 85%
        items.add(_createItem('Oficinas', 0.08, totalArea)); // 8%
        items.add(_createItem('Sanitarios', 0.02, totalArea)); // 2%
        items.add(_createItem('Circulación exterior/Carga', 0.05, totalArea)); // 5%
        break;
      case BuildingType.office:
        items.add(_createItem('Área de trabajo', 0.65, totalArea)); // 65%
        items.add(_createItem('Salas de reuniones', 0.10, totalArea)); // 10%
        items.add(_createItem('Circulación', 0.15, totalArea)); // 15%
        items.add(_createItem('Servicios sanitarios', 0.05, totalArea)); // 5%
        items.add(_createItem('Cafetería/Descanso', 0.05, totalArea)); // 5%
        break;
      case BuildingType.custom:
      default:
        items.add(_createItem('Área Principal', 0.70, totalArea)); // 70%
        items.add(_createItem('Circulación', 0.15, totalArea)); // 15%
        items.add(_createItem('Otros', 0.15, totalArea)); // 15%
        break;
    }

    return BuildingAreaDistribution(items: items, totalArea: totalArea);
  }

  AreaDistributionItem _createItem(String name, double percentage, double totalArea) {
    return AreaDistributionItem(
      spaceName: name,
      percentage: percentage * 100,
      estimatedArea: totalArea * percentage,
    );
  }
}
