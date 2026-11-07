import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oynika/features/games/who_am_i/presentation/who_motion_debug_panel.dart';

void main() {
  testWidgets('Debug olmayan derleme koşulunda panel oluşturulmaz', (t) async {
    await t.pumpWidget(
      const MaterialApp(
        home: WhoMotionDebugPanel(
          diagnostics: 'ACC secret diagnostic',
          enabled: true,
          debugBuild: false,
        ),
      ),
    );
    expect(find.byKey(const ValueKey('who-motion-debug')), findsNothing);
    expect(find.textContaining('ACC'), findsNothing);
  });
  testWidgets('Debug paneli tüm tanı metnini gösterir', (t) async {
    await t.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WhoMotionDebugPanel(
            enabled: true,
            diagnostics:
                'active ACC 10 GYR 10\nA[0,0,9.8] açı 40\nnötr kilitli son Doğru',
          ),
        ),
      ),
    );
    expect(find.byKey(const ValueKey('who-motion-debug')), findsOneWidget);
  });
  testWidgets('Debug APK varsayılanında teknik panel gizlidir', (t) async {
    expect(whoMotionDebugEnabled, isFalse);
    await t.pumpWidget(
      const MaterialApp(
        home: WhoMotionDebugPanel(diagnostics: 'active ACC GYR'),
      ),
    );
    expect(find.byKey(const ValueKey('who-motion-debug')), findsNothing);
    expect(find.textContaining('ACC'), findsNothing);
  });
}
