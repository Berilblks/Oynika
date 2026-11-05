import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/widgets/game_art.dart';
import '../../domain/party_game.dart';

/// The backdrop belongs to the whole page, including both fixed bars.
/// Scaffold still reserves their space so scrollable content stays unobscured.
class UndercoverScaffold extends StatelessWidget {
  const UndercoverScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;

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
      systemStatusBarContrastEnforced: false,
      systemNavigationBarContrastEnforced: false,
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: UndercoverBackdrop(
        child: Theme(
          data: theme.copyWith(
            appBarTheme: theme.appBarTheme.copyWith(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              systemOverlayStyle: overlay,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: appBar,
            bottomNavigationBar: bottomNavigationBar,
            body: body,
          ),
        ),
      ),
    );
  }
}

/// One source for the character throughout the Undercover flow.
class UndercoverArt extends StatelessWidget {
  const UndercoverArt({super.key, this.size = 96});
  final double size;
  @override
  Widget build(BuildContext context) =>
      Center(child: GameArt(game: PartyGame.undercover, height: size));
}

class UndercoverBackdrop extends StatelessWidget {
  const UndercoverBackdrop({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              dark
                  ? [theme.colorScheme.surface, theme.colorScheme.surface]
                  : [
                    const Color(0xFFF1E5FF),
                    const Color(0xFFFFF8F0),
                    const Color(0xFFF8E8FC),
                  ],
        ),
      ),
      child: CustomPaint(
        painter: _Waves(
          theme.colorScheme.primary.withValues(alpha: dark ? .05 : .09),
        ),
        child: child,
      ),
    );
  }
}

class _Waves extends CustomPainter {
  const _Waves(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final top =
        Path()
          ..lineTo(size.width * .34, 0)
          ..cubicTo(
            size.width * .30,
            size.height * .12,
            size.width * .08,
            size.height * .04,
            0,
            size.height * .19,
          )
          ..close();
    canvas.drawPath(top, paint);
    final bottom =
        Path()
          ..moveTo(size.width, size.height * .78)
          ..cubicTo(
            size.width * .78,
            size.height * .83,
            size.width * .83,
            size.height * .94,
            size.width * .58,
            size.height,
          )
          ..lineTo(size.width, size.height)
          ..close();
    canvas.drawPath(bottom, paint);
  }

  @override
  bool shouldRepaint(_Waves oldDelegate) => color != oldDelegate.color;
}

class UndercoverPanel extends StatelessWidget {
  const UndercoverPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withValues(alpha: .95),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colors.primary.withValues(alpha: .12)),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: .06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class UndercoverButton extends StatelessWidget {
  const UndercoverButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient:
            onPressed == null
                ? null
                : const LinearGradient(
                  colors: [Color(0xFF9854DE), Color(0xFF5730AB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        color:
            onPressed == null ? colors.onSurface.withValues(alpha: .12) : null,
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledForegroundColor: colors.onSurface.withValues(alpha: .38),
          minimumSize: const Size(double.infinity, 56),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 24,
                color:
                    onPressed == null
                        ? colors.onSurface.withValues(alpha: .38)
                        : Colors.white,
              ),
              const SizedBox(width: 10),
            ],
            Flexible(child: Text(label, textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}

class UndercoverProgress extends StatelessWidget {
  const UndercoverProgress({
    super.key,
    required this.index,
    required this.count,
  });
  final int index;
  final int count;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: '${index + 1} / $count oyuncu',
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 7,
        runSpacing: 7,
        children: [
          for (var i = 0; i < count; i++)
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < index ? colors.primary : colors.surface,
                border: Border.all(
                  color:
                      i <= index
                          ? colors.primary
                          : colors.primary.withValues(alpha: .25),
                  width: i == index ? 3 : 2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class UndercoverWinner extends StatelessWidget {
  const UndercoverWinner({super.key, required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: const LinearGradient(
        colors: [Color(0xFF9854DE), Color(0xFF5730AB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Column(
      children: [
        const Icon(
          Icons.emoji_events_rounded,
          size: 44,
          color: Color(0xFFFFD463),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontVariations: AppTheme.displayWeight,
          ),
        ),
      ],
    ),
  );
}
