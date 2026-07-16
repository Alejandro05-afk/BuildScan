import 'dart:async';
import 'package:flutter/material.dart';

class BuildScanLoginAnimation extends StatefulWidget {
  const BuildScanLoginAnimation({super.key});

  @override
  State<BuildScanLoginAnimation> createState() => _BuildScanLoginAnimationState();
}

class _BuildScanLoginAnimationState extends State<BuildScanLoginAnimation> {
  int _currentAnimationIndex = 0;
  Timer? _timer;

  // Alternating JSON Lottie files for Constructor and Hardware Store
  final List<String> _lottiePaths = [
    'assets/animations/construction_anim.json',
    'assets/animations/hardware_store_anim.json',
  ];

  @override
  void initState() {
    super.initState();
    // Alternates animation every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentAnimationIndex = (_currentAnimationIndex + 1) % _lottiePaths.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Since the JSON files are currently empty placeholders {},
    // Lottie.asset throws an error internally, so we should switch directly between fallbacks
    // using the index to avoid Lottie trying to load/render empty structures.
    final widgetToShow = _currentAnimationIndex == 0
        ? _buildFallback(colorScheme, true)
        : _buildFallback(colorScheme, false);

    return SizedBox(
      height: 250,
      width: double.infinity,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: animation.drive(Tween(begin: 0.9, end: 1.0)),
                child: child,
              ),
            );
          },
          child: widgetToShow,
        ),
      ),
    );
  }

  Widget _buildFallback(ColorScheme colorScheme, bool isConstructor) {
    return Container(
      key: ValueKey<bool>(isConstructor),
      width: 170,
      height: 170,
      decoration: BoxDecoration(
        color: isConstructor
            ? const Color(0xFFFFB300).withValues(alpha: 0.15)
            : const Color(0xFF0F3D3E).withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isConstructor ? Icons.construction_rounded : Icons.store_rounded,
        size: 80,
        color: isConstructor ? const Color(0xFFFFB300) : const Color(0xFF0F3D3E),
      ),
    );
  }
}
