import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';
import '../widgets/buildscan_login_animation.dart';
import '../../../../core/widgets/clay_input_field.dart';
import '../../../../core/widgets/clay_submit_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.iniciarSesion(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _translateAuthError(e.message);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Ocurrió un error inesperado. Verifica tu conexión e inténtalo de nuevo.';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _translateAuthError(String message) {
    final lower = message.toLowerCase();
    switch (lower) {
      case 'invalid login credentials':
        return 'Usuario o contraseña incorrectos';
      case 'email not confirmed':
        return 'Tu correo aún no ha sido confirmado. Revisa tu bandeja de entrada para activar tu cuenta.';
      case 'email rate limit exceeded':
        return 'Demasiados intentos. Espera unos minutos e inténtalo de nuevo.';
      default:
        return 'Usuario o contraseña incorrectos';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const BuildScanLoginAnimation(),
                const SizedBox(height: 24),
                ClayInputField(
                  controller: _emailController,
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'El email es requerido';
                    if (!v.contains('@')) return 'Ingresa un email válido';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ClayInputField(
                  controller: _passwordController,
                  labelText: 'Contraseña',
                  isPassword: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'La contraseña es requerida';
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                ClaySubmitButton(
                  onPressed: _login,
                  text: 'Ingresar',
                  isLoading: _isLoading,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.push('/register'),
                  child: const Text('Crear una cuenta'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
