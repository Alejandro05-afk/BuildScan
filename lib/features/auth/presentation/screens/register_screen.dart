import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../../core/widgets/clay_input_field.dart';
import '../../../../core/widgets/clay_submit_button.dart';
import '../../../../core/widgets/password_strength_indicator.dart';
import '../../../../core/widgets/password_strength_indicator.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _rolSeleccionado = 'constructora';
  bool _isLoading = false;

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.registrarUsuario(
        email: _emailController.text,
        password: _passwordController.text,
        nombre: _nombreController.text,
        rol: _rolSeleccionado,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro exitoso')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _rolSeleccionado,
                  decoration: const InputDecoration(labelText: 'Tipo de Cuenta'),
                  items: const [
                    DropdownMenuItem(value: 'constructora', child: Text('Constructora')),
                    DropdownMenuItem(value: 'ferreteria', child: Text('Ferretería')),
                  ],
                  onChanged: (value) => setState(() => _rolSeleccionado = value!),
                ),
                const SizedBox(height: 24),
                ClayInputField(
                  controller: _nombreController,
                  labelText: 'Nombre o Razón Social',
                  validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 24),
                ClayInputField(
                  controller: _emailController,
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    if (!v.contains('@')) return 'Email inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ClayInputField(
                  controller: _passwordController,
                  labelText: 'Contraseña',
                  isPassword: true,
                  validator: (v) => (v == null || v.length < 8) ? 'Mínimo 8 caracteres' : null,
                ),
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: _passwordController,
                  builder: (context, _) {
                    return PasswordStrengthIndicator(password: _passwordController.text);
                  },
                ),
                const SizedBox(height: 32),
                ClaySubmitButton(
                  onPressed: _registrar,
                  text: 'Registrarse',
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
