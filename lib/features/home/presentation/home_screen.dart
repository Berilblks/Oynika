import 'package:flutter/material.dart';
import '../../../core/constants/app_dimensions.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _games = [
    'Tabu',
    'Sessiz Sinema',
    'Ben Kimim?',
    '5 Saniyede Söyle!',
    'Ben Hiç...',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppDimensions.contentMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Oynika', style: theme.textTheme.headlineLarge),
                  const SizedBox(height: AppDimensions.itemSpacing),
                  Text(
                    'Oyun Başlasın, Eğlence Başlasın!',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppDimensions.sectionSpacing),
                  const Text(
                    'Oyunlar geliştirme aşamasında. Henüz oynanabilir değiller.',
                  ),
                  const SizedBox(height: AppDimensions.itemSpacing),
                  for (final game in _games)
                    ListTile(
                      title: Text(game),
                      subtitle: const Text('Geliştirme aşamasında'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
