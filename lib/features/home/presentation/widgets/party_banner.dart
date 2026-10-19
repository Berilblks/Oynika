import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';

class PartyBanner extends StatelessWidget {
  const PartyBanner({super.key, required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(1);
      final compact = constraints.maxWidth < 350;
      final height = (compact ? 220.0 : 200.0) + (scale - 1).clamp(0, 3) * 160;
      return SizedBox(
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -78,
              right: -8,
              width: constraints.maxWidth * 0.71,
              height: 210,
              child: ExcludeSemantics(
                child: Image.asset(
                  'assets/illustrations/friends.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.topRight,
                ),
              ),
            ),
            Positioned.fill(child: CustomPaint(painter: _PartyWavePainter())),
            Positioned(
              left: 24,
              top: 40,
              right: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PARTİ ZAMANI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      fontVariations: AppTheme.titleWeight,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Oyunlarla\ndaha yakın olun!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 25 : 28,
                      fontWeight: FontWeight.w900,
                      fontVariations: AppTheme.displayWeight,
                      height: 1.08,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 34,
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFCE76),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(right: 44),
                    child: const Text(
                      '5 farklı oyun, sınırsız kahkaha!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontVariations: AppTheme.bodyWeight,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 15,
              bottom: 21,
              child: IconButton.filled(
                key: const ValueKey('explore-games'),
                tooltip: 'Oyunları keşfet',
                onPressed: onExplore,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFFFFBF5),
                  foregroundColor: const Color(0xFF382579),
                  fixedSize: const Size(43, 43),
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 26),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _PartyWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path =
        Path()
          ..moveTo(0, h * 0.38)
          ..cubicTo(0, -h * 0.08, w * 0.20, 0, w * 0.35, h * 0.06)
          ..cubicTo(w * 0.58, h * 0.11, w * 0.49, h * 0.43, w * 0.77, h * 0.43)
          ..cubicTo(w * 0.94, h * 0.36, w, h * 0.51, w, h * 0.68)
          ..cubicTo(w, h * 1.04, w * 0.92, h * 0.96, w * 0.70, h * 0.96)
          ..cubicTo(w * 0.45, h * 0.93, w * 0.12, h * 1.08, w * 0.04, h * 0.85)
          ..cubicTo(w * 0.01, h * 0.77, 0, h * 0.57, 0, h * 0.38)
          ..close();
    final paint =
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5840B2), Color(0xFF382579)],
          ).createShader(Offset.zero & size);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PartyWavePainter oldDelegate) => false;
}
