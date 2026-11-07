import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oynika/features/games/who_am_i/domain/who_models.dart';
import 'package:oynika/features/games/who_am_i/application/who_controller.dart';

void main() {
  test('Ayarlar isimleri temizler, kimlikleri ve varsayılan süreyi tutar', () {
    final settings = WhoGameSettings(names: [' Ece ', 'Deniz']);
    expect(settings.duration, WhoRoundDuration.standard);
    expect(settings.players.map((p) => p.name), ['Ece', 'Deniz']);
    expect(settings.players.map((p) => p.id), [0, 1]);
    expect(() => settings.players.clear(), throwsUnsupportedError);
  });
  for (final count in [0, 1, 21]) {
    test(
      'Geçersiz oyuncu sayısı: $count',
      () => expect(
        () => WhoGameSettings(names: List.generate(count, (i) => 'Oyuncu $i')),
        throwsArgumentError,
      ),
    );
  }
  for (final count in [2, 20]) {
    test(
      'Oyuncu sınırı kabul edilir: $count',
      () => expect(
        WhoGameSettings(
          names: List.generate(count, (i) => 'Oyuncu $i'),
        ).players,
        hasLength(count),
      ),
    );
  }
  for (final names in [
    ['Ece', ' '],
    ['Ece', ' ece '],
    ['IŞIK', 'ışık'],
    ['İPEK', 'ipek'],
  ]) {
    test(
      'Boş ve Türkçe tekrar eden isimler reddedilir: $names',
      () => expect(() => WhoGameSettings(names: names), throwsArgumentError),
    );
  }
  for (final duration in WhoRoundDuration.values) {
    test('Controller süre ve oyuncuları korur: ${duration.seconds}', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final subscription = container.listen(whoSessionProvider, (_, _) {});
      addTearDown(subscription.close);
      final controller = container.read(whoSessionProvider.notifier);
      controller.start(names: [' Ece ', 'Deniz'], duration: duration);
      final session = container.read(whoSessionProvider)!;
      expect(session.settings.duration, duration);
      expect(session.currentPlayerIndex, 0);
      expect(session.currentPlayer.name, 'Ece');
      controller.start(
        names: ['Can', 'Mert'],
        duration: WhoRoundDuration.short,
      );
      expect(container.read(whoSessionProvider), same(session));
      controller.reset();
      expect(container.read(whoSessionProvider), isNull);
    });
  }
}
