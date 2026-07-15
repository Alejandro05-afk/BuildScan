import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ferreteria_model.dart';

class FerreteriaRepository {
  FerreteriaRepository(this.client);

  final SupabaseClient client;

  Future<List<FerreteriaModel>> obtenerFerreteriasActivas() async {
    final data = await client
        .from('ferreterias')
        .select()
        .eq('activa', true)
        .order('destacada', ascending: false);

    return (data as List)
        .map((item) => FerreteriaModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> crearFerreteria(Map<String, dynamic> data) async {
    await client.from('ferreterias').upsert(data, onConflict: 'user_id');
  }

  Future<void> actualizarFerreteria(String id, Map<String, dynamic> data) async {
    await client.from('ferreterias').update(data).eq('id', id);
  }
}
