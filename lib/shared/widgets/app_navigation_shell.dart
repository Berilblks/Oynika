import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_theme.dart';

class AppNavigationShell extends StatelessWidget {
  const AppNavigationShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.05),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.resolveWith(
              (states) => TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontVariations:
                    states.contains(WidgetState.selected)
                        ? AppTheme.titleWeight
                        : AppTheme.labelWeight,
                fontWeight:
                    states.contains(WidgetState.selected)
                        ? FontWeight.w800
                        : FontWeight.w600,
                color:
                    states.contains(WidgetState.selected)
                        ? colors.primary
                        : colors.onSurfaceVariant,
              ),
            ),
            iconTheme: WidgetStateProperty.resolveWith(
              (states) => IconThemeData(
                size: 27,
                color:
                    states.contains(WidgetState.selected)
                        ? colors.primary
                        : colors.onSurfaceVariant.withValues(alpha: 0.65),
              ),
            ),
          ),
          child: NavigationBar(
            height: 72,
            elevation: 0,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            indicatorColor: colors.primary.withValues(alpha: 0.09),
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected:
                (index) => navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                ),
            destinations: const [
              NavigationDestination(
                key: ValueKey('nav-home'),
                icon: Icon(Icons.home_rounded),
                label: 'Ana Sayfa',
              ),
              NavigationDestination(
                key: ValueKey('nav-games'),
                icon: Icon(Icons.bar_chart_rounded),
                label: 'Oyunlar',
              ),
              NavigationDestination(
                key: ValueKey('nav-settings'),
                icon: Icon(Icons.settings_rounded),
                label: 'Ayarlar',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
