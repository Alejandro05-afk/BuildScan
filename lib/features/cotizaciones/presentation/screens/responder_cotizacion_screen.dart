import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  void dispose() {
    for (final ctrl in _priceControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _enviarCotizacion() async {
    // Validate no empty materials
    if (_materiales.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay materiales para cotizar')),
        );
      }
      return;
    }

    // Validate all prices are filled and > 0
    for (var i = 0; i < _materiales.length; i++) {
      final priceText = _priceControllers[i].text.trim();
      if (priceText.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ingresa el precio de "${_materiales[i]['nombre']}"')),
          );
        }
        return;
      }
      final price = double.tryParse(priceText);
      if (price == null || price <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('El precio de "${_materiales[i]['nombre']}" debe ser mayor a 0')),
          );
        }
        return;
      }
    }

    // Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar envío'),
        content: Text('¿Enviar cotización con ${_materiales.length} material(es)?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Enviar')),
        ],
      ),
    );
    if (confirmed != true) return;

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

  Future<void> _rechazarSolicitud() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rechazar solicitud'),
        content: const Text('¿Estás seguro de rechazar esta solicitud de cotización?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Rechazar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(cotizacionRepositoryProvider);
      await repo.rechazarCotizacion(widget.solicitud['id']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud rechazada')));
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
            child: _materiales.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No hay materiales en esta proforma.', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
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
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
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
                : Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _enviarCotizacion,
                        icon: const Icon(Icons.send),
                        label: const Text('Enviar Precios'),
                        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _rechazarSolicitud,
                        icon: const Icon(Icons.close, color: Colors.red),
                        label: const Text('Rechazar Solicitud', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
