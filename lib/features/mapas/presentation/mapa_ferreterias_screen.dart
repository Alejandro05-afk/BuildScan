import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../ferreterias/presentation/providers/ferreteria_provider.dart';
import '../../cotizaciones/presentation/providers/cotizacion_provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../ferreterias/models/ferreteria_model.dart';
import '../data/location_service.dart';

class MapaFerreteriasScreen extends ConsumerStatefulWidget {
  final String? proformaId;
  const MapaFerreteriasScreen({super.key, this.proformaId});

  @override
  ConsumerState<MapaFerreteriasScreen> createState() => _MapaFerreteriasScreenState();
}

class _MapaFerreteriasScreenState extends ConsumerState<MapaFerreteriasScreen> {
  final LocationService _locationService = LocationService();
  LatLng? _currentLocation;
  bool _isLoadingLocation = true;

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
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ferreteriasAsync = ref.watch(ferreteriasActivasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ferreterías Cercanas')),
      body: _isLoadingLocation
          ? const Center(child: CircularProgressIndicator())
          : _currentLocation == null
              ? const Center(child: Text('No se pudo obtener la ubicación'))
              : ferreteriasAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                  data: (ferreterias) {
                    return FlutterMap(
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
                          markers: ferreterias.map((f) {
                            return Marker(
                              point: LatLng(f.latitud, f.longitud),
                              width: 60,
                              height: 60,
                              child: GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (ctx) {
                                      return Container(
                                        padding: const EdgeInsets.all(16),
                                        width: double.infinity,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(f.nombreComercial, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 8),
                                            if (f.telefono != null) Text('Teléfono: ${f.telefono}'),
                                            if (f.direccion != null) Text('Dirección: ${f.direccion}'),
                                            const SizedBox(height: 16),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Cerrar'),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    }
                                  );
                                },
                                child: const Icon(Icons.location_on, color: Colors.orange, size: 48),
                              ),
                            );
                          }).toList(),
                        ),
                        const RichAttributionWidget(
                          attributions: [
                            TextSourceAttribution('OpenStreetMap contributors'),
                          ],
                        ),
                      ],
                    );
                  },
                ),
      floatingActionButton: widget.proformaId != null
          ? FloatingActionButton.extended(
              onPressed: () async {
                final ferreterias = ferreteriasAsync.value;
                if (ferreterias == null || ferreterias.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay ferreterías para enviar')));
                  return;
                }
                
                final ids = ferreterias.map((f) => f.id).toList();
                try {
                  final repo = ref.read(cotizacionRepositoryProvider);
                  await repo.enviarSolicitudAFerreterias(
                    proformaId: widget.proformaId!,
                    ferreteriasIds: ids,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud enviada a ferreterías')));
                    context.pop();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              icon: const Icon(Icons.send),
              label: const Text('Enviar a Ferreterías'),
            )
          : null,
    );
  }
}
