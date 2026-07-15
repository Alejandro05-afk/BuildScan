import 'package:flutter/material.dart';
import 'package:clay_containers/clay_containers.dart';
import '../../core/theme/buildscan_theme.dart';

class ClaySubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isLoading;

  const ClaySubmitButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: ClayContainer(
        color: BuildScanColors.background,
        borderRadius: 12,
        depth: 30,
        spread: 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: BuildScanColors.tealDark,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
