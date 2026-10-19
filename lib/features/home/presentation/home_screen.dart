import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../shared/widgets/game_collection.dart';
import '../../../shared/widgets/section_heading.dart';
import 'widgets/home_header.dart';
import 'widgets/party_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _gamesKey = GlobalKey();

  void _exploreGames() {
    final target = _gamesKey.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        key: const PageStorageKey('home-scroll'),
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.homePadding,
          16,
          AppDimensions.homePadding,
          24,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppDimensions.contentMaxWidth,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -50,
                  right: -28,
                  width: 170,
                  height: 170,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color:
                          theme.brightness == Brightness.dark
                              ? theme.colorScheme.primary.withValues(
                                alpha: 0.06,
                              )
                              : const Color(0xFFFFE9CD).withValues(alpha: 0.65),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(100),
                        bottomRight: Radius.circular(55),
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: HomeHeader(),
                    ),
                    const SizedBox(height: 20),
                    PartyBanner(onExplore: _exploreGames),
                    const SizedBox(height: 10),
                    SectionHeading(
                      key: _gamesKey,
                      title: 'Oyunlar',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.045,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people_outline_rounded,
                              size: 15,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                'Her oyun, yeni bir hikaye',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.favorite_rounded,
                              size: 15,
                              color: Color(0xFFFF7D93),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const GameCollection(),
                    const SizedBox(height: 20),
                    Text(
                      'Oyunlar geliştirme aşamasında. Şimdilik oyunları keşfedebilirsin.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
