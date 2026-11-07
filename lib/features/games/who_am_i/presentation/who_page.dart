import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WhoPage extends StatelessWidget {
  const WhoPage({
    super.key,
    required this.body,
    required this.onBack,
    this.onRules,
    this.bottom,
    this.actions = const [],
    this.showAppBar = true,
    this.landscapeGame = false,
  });
  final Widget body;
  final VoidCallback onBack;
  final VoidCallback? onRules;
  final Widget? bottom;
  final List<Widget> actions;
  final bool showAppBar;
  final bool landscapeGame;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final overlay = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
      statusBarBrightness: dark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness:
          dark ? Brightness.light : Brightness.dark,
      systemNavigationBarContrastEnforced: false,
      systemStatusBarContrastEnforced: false,
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                landscapeGame
                    ? dark
                        ? [const Color(0xFF21182F), const Color(0xFF171220)]
                        : [const Color(0xFFF1ECFC), const Color(0xFFE8E1F7)]
                    : dark
                    ? [theme.colorScheme.surface, theme.colorScheme.surface]
                    : [const Color(0xFFFFF9F1), const Color(0xFFF0E7FF)],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar:
              !showAppBar
                  ? null
                  : AppBar(
                    backgroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    systemOverlayStyle: overlay,
                    leading: IconButton(
                      tooltip: 'Geri',
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    actions: [
                      ...actions,
                      if (onRules != null)
                        IconButton(
                          tooltip: 'Oyun kuralları',
                          onPressed: onRules,
                          icon: const Icon(Icons.info_outline_rounded),
                        ),
                    ],
                  ),
          bottomNavigationBar:
              bottom == null
                  ? null
                  : SafeArea(
                    top: false,
                    minimum: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Center(
                      heightFactor: 1,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: bottom,
                      ),
                    ),
                  ),
          body: SafeArea(top: !showAppBar, child: body),
        ),
      ),
    );
  }
}
