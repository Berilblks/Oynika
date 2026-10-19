import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../domain/tabu_models.dart';

const tabuPastels = [
  Color(0xFFE8DDFB),
  Color(0xFFFFDCD8),
  Color(0xFFFFE5A8),
  Color(0xFFD9F5E8),
  Color(0xFFDCE9FF),
];

class CrownPainter extends CustomPainter {
  const CrownPainter({this.pink = false});
  final bool pink;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 90);
    final path =
        Path()
          ..moveTo(15, 35)
          ..lineTo(33, 49)
          ..lineTo(50, 17)
          ..lineTo(67, 49)
          ..lineTo(85, 35)
          ..lineTo(76, 76)
          ..quadraticBezierTo(50, 83, 24, 76)
          ..close();
    canvas.drawShadow(path, AppTheme.primary.withValues(alpha: .3), 7, false);
    final paint =
        Paint()
          ..shader = LinearGradient(
            colors:
                pink
                    ? [const Color(0xFFFFB6CC), const Color(0xFFEB4770)]
                    : [const Color(0xFFC795FF), const Color(0xFF6632E6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(const Rect.fromLTWH(10, 10, 80, 70));
    canvas.drawPath(path, paint);
    for (final point in [
      const Offset(15, 33),
      const Offset(50, 15),
      const Offset(85, 33),
    ]) {
      canvas.drawCircle(point, 6.5, paint);
    }
    final jewel =
        Path()
          ..moveTo(50, 48)
          ..lineTo(56, 57)
          ..lineTo(50, 67)
          ..lineTo(44, 57)
          ..close();
    canvas.drawPath(jewel, Paint()..color = Colors.white.withValues(alpha: .9));
    canvas.restore();
  }

  @override
  bool shouldRepaint(CrownPainter oldDelegate) => pink != oldDelegate.pink;
}

class TabuBackgroundPainter extends CustomPainter {
  const TabuBackgroundPainter({required this.dark, required this.playing});
  final bool dark, playing;
  @override
  void paint(Canvas canvas, Size size) {
    if (playing) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF382078), Color(0xFF5C2AA8), Color(0xFF382078)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Offset.zero & size),
      );
      return;
    }
    final opacity = dark ? .035 : .25;
    canvas.drawOval(
      Rect.fromLTWH(-65, size.height * .12, 150, 190),
      Paint()..color = tabuPastels[0].withValues(alpha: opacity),
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width - 55, size.height * .3, 125, 210),
      Paint()..color = tabuPastels[1].withValues(alpha: opacity),
    );
    canvas.drawOval(
      Rect.fromLTWH(-45, size.height - 80, 145, 140),
      Paint()..color = tabuPastels[2].withValues(alpha: opacity),
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width - 80, size.height - 90, 155, 155),
      Paint()..color = tabuPastels[3].withValues(alpha: opacity),
    );
  }

  @override
  bool shouldRepaint(TabuBackgroundPainter oldDelegate) =>
      dark != oldDelegate.dark || playing != oldDelegate.playing;
}

class TabuButton extends StatelessWidget {
  const TabuButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
    this.secondary = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  final bool secondary;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient:
          secondary
              ? null
              : const LinearGradient(
                colors: [Color(0xFF9360FF), Color(0xFF6131E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
      color: secondary ? Theme.of(context).colorScheme.primaryContainer : null,
      boxShadow:
          secondary
              ? null
              : [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: .15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
    ),
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor:
            secondary
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
          Icon(
            icon,
            color:
                secondary
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Colors.white,
          ),
        ],
      ),
    ),
  );
}

class TabuPanel extends StatelessWidget {
  const TabuPanel({super.key, required this.child, this.color});
  final Widget child;
  final Color? color;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: color ?? Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: AppTheme.primary.withValues(alpha: .07),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: child,
  );
}

class CelebrationIcon extends StatelessWidget {
  const CelebrationIcon({super.key, this.trophy = false, this.pink = false});
  final bool trophy, pink;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: trophy ? 142 : 94,
    width: 150,
    child: Stack(
      alignment: Alignment.center,
      children: [
        for (var i = 0; i < 6; i++)
          Positioned(
            left: i.isEven ? 12.0 + i * 2 : null,
            right: i.isOdd ? 10.0 + i * 2 : null,
            top: 10.0 + (i % 3) * 28,
            child: Transform.rotate(
              angle: i * .8,
              child: Container(
                width: 8,
                height: 15,
                decoration: BoxDecoration(
                  color:
                      tabuPastels[i % 5] == tabuPastels[0]
                          ? const Color(0xFFAA77FF)
                          : [Colors.amber, AppTheme.secondary][i % 2],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        if (!trophy)
          CustomPaint(
            size: const Size(90, 82),
            painter: CrownPainter(pink: pink),
          )
        else
          Icon(
            Icons.emoji_events_rounded,
            size: trophy ? 128 : 84,
            color:
                trophy
                    ? const Color(0xFFFFBE32)
                    : pink
                    ? const Color(0xFFFF7188)
                    : const Color(0xFF8751ED),
            shadows: [
              Shadow(
                color: AppTheme.primary.withValues(alpha: .18),
                blurRadius: 12,
                offset: const Offset(0, 7),
              ),
            ],
          ),
      ],
    ),
  );
}

class TabuCardWidget extends StatelessWidget {
  const TabuCardWidget({super.key, required this.card, required this.color});
  final TabuCard card;
  final Color color;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wordSize = constraints.maxWidth < 320 ? 22.0 : 24.0;
      return Semantics(
        label: 'Tabu kartı',
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF17132C),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 82,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                color: color,
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    card.word
                        .replaceAll('i', 'İ')
                        .replaceAll('ı', 'I')
                        .toUpperCase(),
                    style: const TextStyle(
                      fontSize: 31,
                      fontWeight: FontWeight.w900,
                      fontVariations: AppTheme.displayWeight,
                      color: AppTheme.ink,
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 14, bottom: 6),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(
                      Icons.block_rounded,
                      color: Color(0xFFFF8C85),
                      size: 19,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Yasaklı Kelimeler',
                      style: TextStyle(
                        color: Color(0xFFFFAAA4),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              for (final word in card.forbidden)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: wordSize + 30),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: Text(
                          word,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: wordSize,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                            fontVariations: AppTheme.labelWeight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      );
    },
  );
}

class TimerWidget extends StatelessWidget {
  const TimerWidget({super.key, required this.remaining});
  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final seconds = (remaining.inMilliseconds / 1000).ceil().clamp(0, 99999);
    final label =
        '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
    final urgent = seconds <= 10;
    final lastSeconds = seconds <= 5;
    final foreground =
        urgent ? const Color(0xFFFFDCD8) : const Color(0xFFE8DDFB);
    return Semantics(
      label: 'Kalan süre $label',
      child: Container(
        key: const ValueKey('timer-capsule'),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: urgent ? const Color(0xFF8C263D) : const Color(0xFF624398),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: urgent ? const Color(0xFFFF8C85) : const Color(0xFF8964B7),
            width: lastSeconds ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule_rounded, size: 18, color: foreground),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                height: 1.1,
                fontWeight: FontWeight.w800,
                fontVariations: AppTheme.titleWeight,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoundScoreCards extends StatelessWidget {
  const RoundScoreCards({super.key, required this.teams});
  final List<Team> teams;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < teams.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            child: Container(
              key: ValueKey('round-total-$i'),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              decoration: BoxDecoration(
                color: tabuPastels[i],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    teams[i].name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.ink,
                      fontSize: 16,
                      height: 1.3,
                      fontWeight: FontWeight.w800,
                      fontVariations: AppTheme.titleWeight,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${teams[i].score}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.ink,
                      fontSize: 34,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                      fontVariations: AppTheme.displayWeight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

class ScoreWidget extends StatelessWidget {
  const ScoreWidget({
    super.key,
    required this.teams,
    this.light = false,
    this.targetScore,
  });
  final List<Team> teams;
  final bool light;
  final int? targetScore;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var i = 0; i < teams.length; i++)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              children: [
                Text(
                  teams[i].name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: light ? Colors.white : null,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  targetScore == null
                      ? '${teams[i].score}'
                      : '${teams[i].score} / $targetScore',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color:
                        light
                            ? Colors.white
                            : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}
