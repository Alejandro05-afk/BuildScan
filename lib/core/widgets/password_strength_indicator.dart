import 'package:flutter/material.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  bool get _hasMinLength => password.length >= 8;
  bool get _hasUpperAndLower => password.contains(RegExp(r'[a-z]')) && password.contains(RegExp(r'[A-Z]'));
  bool get _hasNumber => password.contains(RegExp(r'[0-9]'));
  bool get _hasSymbol => password.contains(RegExp(r'[!@#\$&*~_.,-]'));

  int get _score {
    int s = 0;
    if (_hasMinLength) s++;
    if (_hasUpperAndLower) s++;
    if (_hasNumber) s++;
    if (_hasSymbol) s++;
    return s;
  }

  String get _strengthText {
    if (password.isEmpty) return 'Seguridad de contraseña';
    if (_score <= 1) return 'Débil';
    if (_score == 2) return 'Regular';
    if (_score == 3) return 'Fuerte';
    return 'Muy fuerte';
  }

  Color _getStrengthColor(BuildContext context) {
    if (password.isEmpty) return Colors.grey.shade400;
    if (_score <= 1) return Colors.red;
    if (_score == 2) return Colors.orange;
    return Theme.of(context).colorScheme.primary; // Teal
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Seguridad de contraseña',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: _getStrengthColor(context),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              child: Text(_strengthText),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 2,
          width: double.infinity,
          color: _getStrengthColor(context).withOpacity(0.5),
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 2,
            width: (MediaQuery.of(context).size.width - 48) * (_score / 4),
            color: _getStrengthColor(context),
          ),
        ),
        const SizedBox(height: 12),
        _buildRequirement(context, 'Mínimo de 8 caracteres', _hasMinLength),
        _buildRequirement(context, 'Letras minúsculas y mayúsculas', _hasUpperAndLower),
        _buildRequirement(context, 'Al menos 1 número', _hasNumber),
        _buildRequirement(context, 'Al menos 1 símbolo', _hasSymbol),
      ],
    );
  }

  Widget _buildRequirement(BuildContext context, String text, bool isMet) {
    final color = isMet ? Theme.of(context).colorScheme.primary : Colors.grey.shade400;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isMet ? color : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.5),
            ),
            padding: const EdgeInsets.all(2),
            child: Icon(
              Icons.check,
              size: 12,
              color: isMet ? Colors.white : Colors.transparent,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? Colors.black87 : Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
