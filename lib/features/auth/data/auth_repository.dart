import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository(this.client);

  final SupabaseClient client;

  Future<AuthResponse> registrarUsuario({
    required String email,
    required String password,
    required String nombre,
    required String rol,
  }) {
    return client.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: 'https://web-confirm-eta.vercel.app/confirm',
      data: {
        'nombre': nombre,
        'rol': rol, // constructora o ferreteria
      },
    );
  }

  Future<AuthResponse> iniciarSesion({
    required String email,
    required String password,
  }) {
    return client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> cerrarSesion() async {
    await client.auth.signOut();
  }

  Future<void> restablecerContrasena(String email) {
    return client.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: 'https://web-confirm-eta.vercel.app/reset-password',
    );
  }

  User? get usuarioActual => client.auth.currentUser;

  Future<Map<String, dynamic>?> obtenerPerfil(String userId) async {
    try {
      return await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
    } catch (e) {
      return null;
    }
  }
}
