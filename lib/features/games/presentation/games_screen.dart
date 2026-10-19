import 'package:flutter/material.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../shared/widgets/game_collection.dart';
import '../../../shared/widgets/section_heading.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: SingleChildScrollView(
      key: const PageStorageKey('games-scroll'),
      padding: const EdgeInsets.all(AppDimensions.pagePadding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppDimensions.contentMaxWidth,
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeading(title: 'Oyunlar'),
              SizedBox(height: 8),
              Text('Bir oyun seç, arkadaşlarınla daha yakından tanış.'),
              SizedBox(height: 20),
              GameCollection(),
              SizedBox(height: 20),
              Text(
                'Oyunlar geliştirme aşamasında. Şimdilik nasıl oynandıklarını keşfedebilirsin.',
              ),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    ),
  );
}
