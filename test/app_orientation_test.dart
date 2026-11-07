import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oynika/core/utils/app_orientation.dart';

void main() {
  test('Portrait varsayılanı ve iki landscape yönü', () async {
    final calls = <List<DeviceOrientation>>[];
    final manager = AppOrientation((directions) async {
      calls.add(directions);
    });
    await manager.portrait();
    final lease = manager.acquire();
    await lease.setLandscape(true);
    await lease.close();
    expect(calls, [
      [DeviceOrientation.portraitUp],
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
      [DeviceOrientation.portraitUp],
    ]);
  });
  test(
    'Gecikmiş yatay isteğinden sonra çıkışın son isteği portrait olur',
    () async {
      final wait = Completer<void>();
      final calls = <List<DeviceOrientation>>[];
      final manager = AppOrientation((directions) async {
        calls.add(directions);
        if (directions.contains(DeviceOrientation.landscapeLeft)) {
          await wait.future;
        }
      });
      final lease = manager.acquire();
      final pending = lease.setLandscape(true);
      await Future<void>.delayed(Duration.zero);
      final released = lease.close();
      wait.complete();
      expect(await pending, isFalse);
      expect(await released, isTrue);
      expect(calls.last, [DeviceOrientation.portraitUp]);
      expect(await lease.setLandscape(true), isFalse);
    },
  );
  test('Eski ekranın dispose u yeni ekranın yönünü bozamaz', () async {
    final calls = <List<DeviceOrientation>>[];
    final manager = AppOrientation((directions) async {
      calls.add(directions);
    });
    final old = manager.acquire();
    await old.setLandscape(true);
    final current = manager.acquire();
    await current.setLandscape(true);
    expect(await old.close(), isFalse);
    expect(calls.last, contains(DeviceOrientation.landscapeLeft));
    await current.close();
    expect(calls.last, [DeviceOrientation.portraitUp]);
  });
  test(
    'Platform hatasından sonra portrait temizliği ve yeniden deneme çalışır',
    () async {
      var fail = true;
      final calls = <List<DeviceOrientation>>[];
      final manager = AppOrientation((directions) async {
        if (fail) {
          fail = false;
          throw PlatformException(code: 'orientation');
        }
        calls.add(directions);
      });
      final lease = manager.acquire();
      await expectLater(
        lease.setLandscape(true),
        throwsA(isA<PlatformException>()),
      );
      expect(await lease.close(), isTrue);
      expect(calls.last, [DeviceOrientation.portraitUp]);
    },
  );
}
