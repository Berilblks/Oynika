import 'package:flutter/material.dart';
import '../../../games/domain/party_game.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      'Oynika',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontSize: 43,
                        height: 1,
                        letterSpacing: -2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 160,
                child: Text(
                  PartyGame.supportingText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Image.asset(
          'assets/branding/oynika_logo_borderless.png',
          key: const ValueKey('official-logo'),
          semanticLabel: 'Oynika resmî logosu',
          width: 43,
          height: 43,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}
