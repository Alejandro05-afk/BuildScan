import 'package:latlong2/latlong.dart';

class DistanceUtils {
  static double distanciaKm({
    required double origenLat,
    required double origenLng,
    required double destinoLat,
    required double destinoLng,
  }) {
    const distance = Distance();
    return distance.as(
      LengthUnit.Kilometer,
      LatLng(origenLat, origenLng),
      LatLng(destinoLat, destinoLng),
    );
  }
}
