import 'package:flutter/material.dart';

class ClayContainer extends StatelessWidget {
  final Widget? child;
  final Color? color;
  final double? borderRadius;
  final double? depth;
  final double? spread;

  const ClayContainer({
    super.key,
    this.child,
    this.color,
    this.borderRadius,
    this.depth,
    this.spread,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        side: const BorderSide(color: Color(0xFFECECEC), width: 1),
      ),
      margin: EdgeInsets.zero,
      color: color ?? Colors.white,
      child: child ?? const SizedBox(),
    );
  }
}
