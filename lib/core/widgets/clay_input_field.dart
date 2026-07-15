import 'package:flutter/material.dart';
import 'package:clay_containers/clay_containers.dart';
import '../../core/theme/buildscan_theme.dart';

class ClayInputField extends StatefulWidget {
  final TextEditingController? controller;
  final String labelText;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String? initialValue;

  const ClayInputField({
    super.key,
    this.controller,
    required this.labelText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.initialValue,
  });

  @override
  State<ClayInputField> createState() => _ClayInputFieldState();
}

class _ClayInputFieldState extends State<ClayInputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return ClayContainer(
      color: BuildScanColors.background,
      borderRadius: 12,
      depth: 20,
      spread: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          onChanged: widget.onChanged,
          obscureText: widget.isPassword ? _obscureText : false,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          decoration: InputDecoration(
            labelText: widget.labelText,
            border: InputBorder.none,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
