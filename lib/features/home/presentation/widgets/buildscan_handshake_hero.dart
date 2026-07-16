import 'package:flutter/material.dart';
import 'buildscan_character_animation.dart';

class BuildScanHandshakeHero extends StatelessWidget {
  const BuildScanHandshakeHero({
    super.key,
    required this.onNewProject,
    required this.onQuotes,
    required this.primaryButtonText,
    required this.secondaryButtonText,
  });

  final VoidCallback onNewProject;
  final VoidCallback onQuotes;
  final String primaryButtonText;
  final String secondaryButtonText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 270,
            width: double.infinity,
            child: const BuildScanCharacterAnimation(),
          ),
          const SizedBox(height: 8),
          Text(
            'Construimos conexiones',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Conecta tus proyectos con ferreterías cercanas y recibe cotizaciones reales.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onNewProject,
                  icon: const Icon(Icons.add_business_rounded),
                  label: Text(primaryButtonText),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onQuotes,
                  icon: const Icon(Icons.request_quote_rounded),
                  label: Text(secondaryButtonText),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
