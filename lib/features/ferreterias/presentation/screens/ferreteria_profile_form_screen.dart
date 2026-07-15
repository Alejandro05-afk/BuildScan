import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/clay_container_alias.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../mapas/data/location_service.dart';
import '../providers/ferreteria_provider.dart';
import '../../../../core/widgets/clay_input_field.dart';
import '../../../../core/widgets/clay_submit_button.dart';

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
  void initState() {
    super.initState();
    _cargarDatosExistentes();
  }

  Future<void> _cargarDatosExistentes() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(ferreteriaRepositoryProvider);
      final authState = ref.read(authStateProvider).value;
      final userId = authState?.session?.user.id;
      
      if (userId == null) return;

      final result = await repo.client
          .from('ferreterias')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (result != null) {
        _nombreComercialCtrl.text = result['nombre_comercial'] ?? '';
        _rucCtrl.text = result['ruc'] ?? '';
        _telefonoCtrl.text = result['telefono'] ?? '';
        _direccionCtrl.text = result['direccion'] ?? '';
        
        if (result['latitud'] != null && result['longitud'] != null) {
          _selectedLocation = LatLng(
            (result['latitud'] as num).toDouble(),
            (result['longitud'] as num).toDouble(),
          );
        }
      }
    } catch (e) {
      // Si no existe, no hacemos nada, dejamos los campos vacíos
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
      appBar: AppBar(
        title: const Text('Configurar Ferretería'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClayInputField(
                      controller: _nombreComercialCtrl,
                      labelText: 'Nombre comercial',
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 24),
                    ClayInputField(
                      controller: _rucCtrl,
                      labelText: 'RUC (Opcional)',
                    ),
                    const SizedBox(height: 24),
                    ClayInputField(
                      controller: _telefonoCtrl,
                      labelText: 'Teléfono',
                      keyboardType: TextInputType.phone,
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 24),
                    ClayInputField(
                      controller: _direccionCtrl,
                      labelText: 'Dirección',
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 24),
                    ClayInputField(
                      controller: _descripcionCtrl,
                      labelText: 'Descripción',
                    ),
                    const SizedBox(height: 32),
                    
                    const Text('Ubicación de la Ferretería', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
                    const SizedBox(height: 16),
                    
                    GestureDetector(
                      onTap: _usarUbicacionActual,
                      child: ClayContainer(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: 12,
                        depth: 20,
                        spread: 2,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.my_location, color: Colors.teal),
                              SizedBox(width: 8),
                              Text('Usar mi ubicación actual', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    ClayContainer(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: 12,
                      depth: 10,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 200,
                          child: _selectedLocation != null
                              ? FlutterMap(
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
                                )
                              : Container(
                                  color: Colors.transparent,
                                  alignment: Alignment.center,
                                  child: const Text('Toca "Usar mi ubicación actual" o selecciona en el mapa', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    ClaySubmitButton(
                      onPressed: _guardarFerreteria,
                      text: 'Guardar Perfil',
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
