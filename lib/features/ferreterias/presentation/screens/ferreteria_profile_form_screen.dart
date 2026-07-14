import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../mapas/data/location_service.dart';
import '../providers/ferreteria_provider.dart';

class FerreteriaProfileFormScreen extends ConsumerStatefulWidget {
  const FerreteriaProfileFormScreen({super.key});

  @override
  ConsumerState<FerreteriaProfileFormScreen> createState() => _FerreteriaProfileFormScreenState();
}

class _FerreteriaProfileFormScreenState extends ConsumerState<FerreteriaProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreComercialCtrl = TextEditingController();
  final _rucCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();

  final LocationService _locationService = LocationService();
  LatLng? _selectedLocation;
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreComercialCtrl.dispose();
    _rucCtrl.dispose();
    _telefonoCtrl.dispose();
    _direccionCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _usarUbicacionActual() async {
    setState(() => _isLoading = true);
    try {
      final position = await _locationService.obtenerUbicacionActual();
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al obtener ubicación: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _guardarFerreteria() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, selecciona una ubicación en el mapa')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authState = ref.read(authStateProvider).value;
      final userId = authState?.session?.user.id;
      
      if (userId == null) throw Exception('Usuario no autenticado');

      final repo = ref.read(ferreteriaRepositoryProvider);
      await repo.crearFerreteria({
        'user_id': userId,
        'nombre_comercial': _nombreComercialCtrl.text,
        'ruc': _rucCtrl.text.isNotEmpty ? _rucCtrl.text : null,
        'telefono': _telefonoCtrl.text,
        'direccion': _direccionCtrl.text,
        'latitud': _selectedLocation!.latitude,
        'longitud': _selectedLocation!.longitude,
        'activa': true, // Por defecto la activamos para el MVP
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil de ferretería guardado')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar Ferretería')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nombreComercialCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre comercial', prefixIcon: Icon(Icons.store)),
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _rucCtrl,
                      decoration: const InputDecoration(labelText: 'RUC (Opcional)', prefixIcon: Icon(Icons.assignment)),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _telefonoCtrl,
                      decoration: const InputDecoration(labelText: 'Teléfono', prefixIcon: Icon(Icons.phone)),
                      keyboardType: TextInputType.phone,
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _direccionCtrl,
                      decoration: const InputDecoration(labelText: 'Dirección', prefixIcon: Icon(Icons.location_on)),
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descripcionCtrl,
                      decoration: const InputDecoration(labelText: 'Descripción', prefixIcon: Icon(Icons.description)),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    const Text('Ubicación de la Ferretería', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _usarUbicacionActual,
                      icon: const Icon(Icons.my_location),
                      label: const Text('Usar mi ubicación actual'),
                    ),
                    const SizedBox(height: 12),
                    if (_selectedLocation != null)
                      SizedBox(
                        height: 200,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: _selectedLocation!,
                            initialZoom: 15,
                            onTap: (tapPosition, point) {
                              setState(() => _selectedLocation = point);
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.buildscan.app',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _selectedLocation!,
                                  width: 40,
                                  height: 40,
                                  child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        height: 200,
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Text('Toca "Usar mi ubicación actual" o selecciona en el mapa', textAlign: TextAlign.center),
                      ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _guardarFerreteria,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Guardar Ferretería', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
