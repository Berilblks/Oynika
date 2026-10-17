import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oynika/app/app.dart';

void main() {
  Future<void> openApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: OynikaApp()));
    await tester.pumpAndSettle();
  }

  testWidgets('Uygulama hatasız açılır ve Oynika başlığı görünür', (
    tester,
  ) async {
    await openApp(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Oynika'), findsOneWidget);
    expect(find.text('Oyun Başlasın, Eğlence Başlasın!'), findsOneWidget);
  });

  testWidgets('Beş oyunun adı ve geliştirme durumu görünür', (tester) async {
    await openApp(tester);
    for (final game in [
      'Tabu',
      'Sessiz Sinema',
      'Ben Kimim?',
      '5 Saniyede Söyle!',
      'Ben Hiç...',
    ]) {
      expect(find.text(game), findsOneWidget);
    }
    expect(find.text('Geliştirme aşamasında'), findsNWidgets(5));
  });

  testWidgets('Küçük ekranda ve koyu temada taşma oluşmaz', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await openApp(tester);
    await tester.ensureVisible(find.text('Ben Hiç...'));
    expect(tester.takeException(), isNull);
    expect(
      Theme.of(tester.element(find.text('Oynika'))).brightness,
      Brightness.dark,
    );
  });
}
