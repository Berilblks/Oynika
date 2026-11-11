import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oynika/app/launch_splash.dart';
import 'package:oynika/app/theme/app_theme.dart';
import 'package:oynika/features/home/presentation/widgets/party_banner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('Nunito')
      ..addFont(rootBundle.load('assets/fonts/Nunito-Variable.ttf'));
    await font.load();
  });
  for (final dark in [false, true]) {
    testWidgets('Splash lasts 2500ms with a final fade, theme: $dark', (
      tester,
    ) async {
      var finished = 0;
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          home: LaunchSplash(
            onFinished: () => finished++,
            child: Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => taps++,
                  child: const Text('Ana ekran'),
                ),
              ),
            ),
          ),
        ),
      );
      final splash = find.byKey(const ValueKey('launch-splash'));
      double opacity() => tester.widget<FadeTransition>(splash).opacity.value;
      expect(opacity(), 1);
      final surface = tester.widget<ColoredBox>(
        find.descendant(of: splash, matching: find.byType(ColoredBox)),
      );
      expect(
        surface.color,
        (dark ? AppTheme.dark : AppTheme.light).scaffoldBackgroundColor,
      );
      expect(
        find.descendant(of: splash, matching: find.byType(Image)),
        findsOneWidget,
      );
      await tester.pump(const Duration(milliseconds: 2150));
      expect(opacity(), 1);
      expect(finished, 0);
      await tester.pump(LaunchSplash.fadeDuration ~/ 2);
      expect(opacity(), inExclusiveRange(0, 1));
      expect(finished, 0);
      await tester.pump(const Duration(milliseconds: 175));
      await tester.pump(const Duration(milliseconds: 1));
      expect(splash, findsNothing);
      expect(finished, 1);
      await tester.tap(find.text('Ana ekran'));
      await tester.pumpAndSettle();
      expect(taps, 1);
      expect(finished, 1);
      expect(tester.takeException(), isNull);
    });

    for (final width in [320.0, 375.0, 430.0]) {
      for (final scale in [1.0, 2.5]) {
        testWidgets('Hero stays on two lines: $width / $scale / dark=$dark', (
          tester,
        ) async {
          tester.view.physicalSize = Size(width, 1100);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            MaterialApp(
              theme: dark ? AppTheme.dark : AppTheme.light,
              home: MediaQuery(
                data: MediaQueryData(
                  size: Size(width, 1100),
                  textScaler: TextScaler.linear(scale),
                ),
                child: Scaffold(
                  body: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: PartyBanner(onExplore: () {}),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final title = find.byKey(const ValueKey('home-hero-slogan'));
          final text = tester.widget<Text>(title);
          expect(text.data, 'Eğlence\nBir Araya Getirir!');
          expect(text.maxLines, 2);
          expect(text.softWrap, isFalse);
          final banner = tester.renderObject<RenderBox>(
            find.byType(PartyBanner),
          );
          final paragraph = tester.renderObject<RenderParagraph>(title);
          final rect = MatrixUtils.transformRect(
            paragraph.getTransformTo(banner),
            Offset.zero & paragraph.size,
          );
          expect(rect.left, greaterThanOrEqualTo(0));
          expect(rect.right, lessThanOrEqualTo(banner.size.width));
          expect(rect.bottom, lessThanOrEqualTo(banner.size.height));
          expect(rect.height / 2, greaterThan(20));
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
