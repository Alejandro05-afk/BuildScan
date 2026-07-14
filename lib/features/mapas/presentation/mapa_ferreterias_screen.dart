import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../ferreterias/models/ferreteria_model.dart';
import '../data/location_service.dart';

class MapaFerreteriasScreen extends StatefulWidget {
  const MapaFerreteriasScreen({super.key});

  @override
  State<MapaFerreteriasScreen> createState() => _MapaFerreteriasScreenState();
}

class _MapaFerreteriasScreenState extends State<MapaFerreteriasScreen> {
  final LocationService _locationService = LocationService();
  LatLng? _currentLocation;
  // TODO: Esto vendrá del Riverpod provider de ferreterías.
  final List<FerreteriaModel> _ferreterias = []; 
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initMap();
  }

  Future<void> _initMap() async {
    try {
      final position = await _locationService.obtenerUbicacionActual();
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ferreterías Cercanas')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentLocation == null
              ? const Center(child: Text('No se pudo obtener la ubicación'))
              : FlutterMap(
                  options: MapOptions(
                    initialCenter: _currentLocation!,
                    initialZoom: 13,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.buildscan.app',
                    ),
                    MarkerLayer(
                      markers: _ferreterias.map((f) {
                        return Marker(
                          point: LatLng(f.latitud, f.longitud),
                          width: 48,
                          height: 48,
                          child: const Icon(Icons.store, color: Colors.orange, size: 36),
                        );
                      }).toList(),
                    ),
                    const RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution('OpenStreetMap contributors'),
                      ],
                    ),
                  ],
                ),
    );
  }
}
