import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/cotizacion_repository.dart';

final cotizacionRepositoryProvider = Provider<CotizacionRepository>((ref) {
  return CotizacionRepository(ref.watch(supabaseProvider));
});

final solicitudesFerreteriaProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(authStateProvider).value?.session?.user;
  if (user == null) return [];
  
  final repo = ref.watch(cotizacionRepositoryProvider);
  return await repo.obtenerSolicitudesFerreteria(user.id);
});

final cotizacionesConstructoraProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(authStateProvider).value?.session?.user;
  if (user == null) return [];
  
  final repo = ref.watch(cotizacionRepositoryProvider);
  return await repo.obtenerCotizacionesConstructora(user.id);
});
