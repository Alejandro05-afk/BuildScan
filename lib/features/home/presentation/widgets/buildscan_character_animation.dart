import 'dart:math';
import 'package:flutter/material.dart';

class BuildScanCharacterAnimation extends StatefulWidget {
  const BuildScanCharacterAnimation({super.key});

  @override
  State<BuildScanCharacterAnimation> createState() =>
      _BuildScanCharacterAnimationState();
}

class _BuildScanCharacterAnimationState
    extends State<BuildScanCharacterAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _moveController;
  late final AnimationController _shakeController;
  late final AnimationController _sparkController;

  late final Animation<double> _constructorSlide;
  late final Animation<double> _vendorSlide;
  late final Animation<double> _shakeAnimation;
  late final Animation<double> _sparkOpacity;

  @override
  void initState() {
    super.initState();

    // Phase 1: Characters move toward each other
    _moveController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _constructorSlide = Tween<double>(begin: -0.35, end: 0.0).animate(
      CurvedAnimation(parent: _moveController, curve: Curves.easeOutCubic),
    );

    _vendorSlide = Tween<double>(begin: 0.35, end: 0.0).animate(
      CurvedAnimation(parent: _moveController, curve: Curves.easeOutCubic),
    );

    // Phase 2: Handshake shake
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );

    // Phase 3: Sparks
    _sparkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _sparkOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkController, curve: Curves.easeOut),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    while (mounted) {
      // Reset all
      _moveController.reset();
      _shakeController.reset();
      _sparkController.reset();

      // Phase 1: Move together
      await _moveController.forward();
      await Future.delayed(const Duration(milliseconds: 200));

      // Phase 2: Shake hands
      _shakeController.repeat(reverse: true);
      await Future.delayed(const Duration(milliseconds: 600));
      _shakeController.stop();

      // Phase 3: Sparks
      _sparkController.forward();

      // Hold
      await Future.delayed(const Duration(milliseconds: 1500));

      // Fade out sparks
      await _sparkController.reverse();

      // Pause before loop
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  @override
  void dispose() {
    _moveController.dispose();
    _shakeController.dispose();
    _sparkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _moveController,
          _shakeController,
          _sparkController,
        ]),
        builder: (context, child) {
          final shakeOffset =
              sin(_shakeAnimation.value * pi * 4) * 4;

          return Stack(
            alignment: Alignment.center,
            children: [
              // Glow behind handshake
              if (_sparkController.isAnimating)
                Positioned(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.15 * _sparkOpacity.value),
                    ),
                  ),
                ),

              // Constructor (left)
              Positioned(
                left: 20,
                child: Transform.translate(
                  offset: Offset(
                    _constructorSlide.value * 160 + shakeOffset,
                    0,
                  ),
                  child: Image.asset(
                    'assets/images/constructor.png',
                    height: 220,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return _FallbackCharacter(
                        icon: Icons.construction_rounded,
                        color: const Color(0xFFFFB300),
                        label: 'Constructor',
                      );
                    },
                  ),
                ),
              ),

              // Vendor (right)
              Positioned(
                right: 20,
                child: Transform.translate(
                  offset: Offset(
                    _vendorSlide.value * 160 - shakeOffset,
                    0,
                  ),
                  child: Image.asset(
                    'assets/images/vendor.png',
                    height: 220,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return _FallbackCharacter(
                        icon: Icons.store_rounded,
                        color: const Color(0xFF0F3D3E),
                        label: 'Ferretería',
                      );
                    },
                  ),
                ),
              ),

              // Sparks
              if (_sparkController.isAnimating || _sparkController.isCompleted)
                ..._buildSparks(_sparkOpacity.value),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildSparks(double opacity) {
    final random = Random(42);
    return List.generate(6, (i) {
      final angle = (i / 6) * 2 * pi;
      final distance = 40.0 + random.nextDouble() * 30;
      final size = 6.0 + random.nextDouble() * 6;
      final delay = i * 0.1;
      final sparkOpacity =
          (opacity - delay).clamp(0.0, 1.0);

      return Positioned(
        left: 200 + cos(angle) * distance * sparkOpacity - size / 2,
        top: 130 + sin(angle) * distance * sparkOpacity - size / 2,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i.isEven
                ? const Color(0xFFFFD700)
                : const Color(0xFF00A8A9),
          ),
        ),
      );
    });
  }
}

class _FallbackCharacter extends StatelessWidget {
  const _FallbackCharacter({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 44, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }
}
