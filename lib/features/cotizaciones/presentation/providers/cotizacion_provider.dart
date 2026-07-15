import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/cotizacion_repository.dart';

final cotizacionRepositoryProvider = Provider<CotizacionRepository>((ref) {
  return CotizacionRepository(ref.watch(supabaseProvider));
});

final solicitudesFerreteriaProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final user = ref.watch(authStateProvider).value?.session?.user;
  if (user == null) return Stream.value([]);
  
  final repo = ref.watch(cotizacionRepositoryProvider);
  final controller = StreamController<List<Map<String, dynamic>>>();
  
  Future<void> fetchData() async {
    try {
      final data = await repo.obtenerSolicitudesFerreteria(user.id);
      if (!controller.isClosed) controller.add(data);
    } catch (e) {
      if (!controller.isClosed) controller.addError(e);
    }
  }
  
  fetchData(); // Initial load
  
  final channel = repo.client.channel('public:solicitudes_cotizacion');
  channel.onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'solicitudes_cotizacion',
    callback: (payload) {
      fetchData();
    },
  ).subscribe();
  
  ref.onDispose(() {
    channel.unsubscribe();
    controller.close();
  });
  
  return controller.stream;
});

final cotizacionesConstructoraProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final user = ref.watch(authStateProvider).value?.session?.user;
  if (user == null) return Stream.value([]);
  
  final repo = ref.watch(cotizacionRepositoryProvider);
  final controller = StreamController<List<Map<String, dynamic>>>();
  
  Future<void> fetchData() async {
    try {
      final data = await repo.obtenerCotizacionesConstructora(user.id);
      if (!controller.isClosed) controller.add(data);
    } catch (e) {
      if (!controller.isClosed) controller.addError(e);
    }
  }
  
  fetchData(); // Initial load
  
  final channel = repo.client.channel('public:solicitudes_cotizacion_constructora');
  channel.onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'solicitudes_cotizacion',
    callback: (payload) {
      fetchData();
    },
  ).subscribe();
  
  ref.onDispose(() {
    channel.unsubscribe();
    controller.close();
  });
  
  return controller.stream;
});
