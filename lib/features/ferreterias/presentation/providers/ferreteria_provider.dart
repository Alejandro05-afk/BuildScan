import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../models/ferreteria_model.dart';
import '../../data/ferreteria_repository.dart';

final ferreteriaRepositoryProvider = Provider<FerreteriaRepository>((ref) {
  return FerreteriaRepository(ref.watch(supabaseProvider));
});

final ferreteriasActivasProvider = FutureProvider<List<FerreteriaModel>>((ref) async {
  final repo = ref.watch(ferreteriaRepositoryProvider);
  return await repo.obtenerFerreteriasActivas();
});
