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

  User? get usuarioActual => client.auth.currentUser;
}
