import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/cotizacion_provider.dart';

class ResponderCotizacionScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> solicitud;
  const ResponderCotizacionScreen({super.key, required this.solicitud});

  @override
  ConsumerState<ResponderCotizacionScreen> createState() => _ResponderCotizacionScreenState();
}

class _ResponderCotizacionScreenState extends ConsumerState<ResponderCotizacionScreen> {
  final List<TextEditingController> _priceControllers = [];
  List<dynamic> _materiales = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final proforma = widget.solicitud['proformas'] as Map<String, dynamic>?;
    
    // Supabase returns jsonb as a Dart List/Map automatically, not as a String.
    final dynamic materialesData = proforma?['materiales_json'];
    
    if (materialesData is String) {
      _materiales = jsonDecode(materialesData);
    } else if (materialesData is List) {
      _materiales = materialesData;
    } else {
      _materiales = [];
    }
    
    for (int i = 0; i < _materiales.length; i++) {
      _priceControllers.add(TextEditingController());
    }
  }

  Future<void> _enviarCotizacion() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(cotizacionRepositoryProvider);
      
      final detalles = <Map<String, dynamic>>[];
      for (var i = 0; i < _materiales.length; i++) {
        final mat = _materiales[i];
        final priceText = _priceControllers[i].text;
        final price = double.tryParse(priceText) ?? 0.0;
        
        detalles.add({
          'material_nombre': mat['nombre'],
          'cantidad': mat['cantidad'],
          'unidad': mat['unidad'],
          'precio_unitario': price,
        });
      }

      await repo.responderCotizacion(
        solicitudId: widget.solicitud['id'],
        detalles: detalles,
      );
      
      // ref.refresh(solicitudesFerreteriaProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cotización enviada exitosamente')));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Responder Cotización')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Ingresa el precio unitario para cada material solicitado.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _materiales.length,
              itemBuilder: (context, index) {
                final mat = _materiales[index];
                return ListTile(
                  title: Text(mat['nombre']),
                  subtitle: Text('Cant: ${mat['cantidad']} ${mat['unidad']}'),
                  trailing: SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _priceControllers[index],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Precio',
                        prefixText: '\$ ',
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading 
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _enviarCotizacion,
                    icon: const Icon(Icons.send),
                    label: const Text('Enviar Precios'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  ),
          ),
        ],
      ),
    );
  }
}
