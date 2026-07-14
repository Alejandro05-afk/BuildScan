import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/auth_repository.dart';
import '../../models/profile_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseProvider));
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseProvider).auth.onAuthStateChange;
});

final profileProvider = FutureProvider<ProfileModel?>((ref) async {
  final authState = ref.watch(authStateProvider).value;
  final user = authState?.session?.user;

  if (user == null) return null;

  final repo = ref.watch(authRepositoryProvider);
  final data = await repo.obtenerPerfil(user.id);
  
  if (data != null) {
    return ProfileModel.fromMap(data);
  }
  return null;
});
