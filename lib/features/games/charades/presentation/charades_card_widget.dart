import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../domain/charades_models.dart';

class CharadesCardWidget extends StatelessWidget {
  const CharadesCardWidget({super.key, required this.card});
  final CharadesCard card;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    constraints: const BoxConstraints(minHeight: 340),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
    decoration: BoxDecoration(
      color: AppTheme.background,
      borderRadius: BorderRadius.circular(32),
      boxShadow: const [
        BoxShadow(color: Colors.black26, blurRadius: 18, offset: Offset(0, 8)),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE8DDFB),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                card.category == 'Film'
                    ? Icons.movie_rounded
                    : Icons.tv_rounded,
                color: AppTheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                card.category == 'Film' ? 'FİLM' : 'DİZİ',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 54),
        Text(
          card.title,
          key: const ValueKey('charades-title'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.ink,
            fontSize: 32,
            height: 1.2,
            fontWeight: FontWeight.w900,
            fontVariations: AppTheme.displayWeight,
          ),
        ),
        const SizedBox(height: 54),
        const Text(
          'Konuşmadan anlat!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.muted,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}
