import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_theme.dart';
import '../application/undercover_controller.dart';
import 'undercover_visuals.dart';

class UndercoverDistributionScreen extends StatefulWidget {
  const UndercoverDistributionScreen({
    super.key,
    required this.playerName,
    this.playerIndex = 0,
    this.playerCount = 6,
    required this.hasSeenWord,
    required this.onReveal,
    required this.onNext,
    required this.onExit,
  });

  final String playerName;
  final int playerIndex;
  final int playerCount;
  final bool hasSeenWord;
  final UndercoverSecret? Function() onReveal;
  final VoidCallback onNext;
  final VoidCallback onExit;

  @override
  State<UndercoverDistributionScreen> createState() =>
      _UndercoverDistributionScreenState();
}

class _UndercoverDistributionScreenState
    extends State<UndercoverDistributionScreen>
    with WidgetsBindingObserver {
  bool _armed = false;
  bool _asking = false;
  UndercoverSecret? _visibleSecret;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _hide();
  }

  void _hide() {
    if (_visibleSecret != null) setState(() => _visibleSecret = null);
  }

  void _reveal() {
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (_asking ||
        (lifecycle != null && lifecycle != AppLifecycleState.resumed)) {
      return;
    }
    if (_visibleSecret != null) return;
    final secret = widget.onReveal();
    if (secret == null) return;
    setState(() => _visibleSecret = secret);
    HapticFeedback.lightImpact();
  }

  Future<void> _exit() async {
    if (_asking) return;
    _hide();
    _asking = true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Oyundan çıkmak istiyor musun?'),
            content: const Text('Mevcut oyun sona erecek.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Oyunda Kal'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Çık'),
              ),
            ],
          ),
    );
    if (!mounted) return;
    _asking = false;
    if (confirmed == true) widget.onExit();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showCard = _armed;
    final action = UndercoverButton(
      label: _armed ? 'Bilgimi Gördüm' : 'Bilgimi Gör',
      onPressed:
          !_armed
              ? () => setState(() => _armed = true)
              : widget.hasSeenWord && _visibleSecret == null
              ? () {
                _hide();
                widget.onNext();
              }
              : null,
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exit();
      },
      child: UndercoverScaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Geri',
            onPressed: _exit,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        bottomNavigationBar:
            showCard
                ? SafeArea(
                  top: false,
                  minimum: const EdgeInsets.fromLTRB(20, 12, 20, 52),
                  child: Center(
                    heightFactor: 1,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: SizedBox(width: double.infinity, child: action),
                    ),
                  ),
                )
                : null,
        body: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder:
                (context, viewport) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: viewport.maxHeight),
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          showCard ? 12 : 24,
                          20,
                          showCard ? 12 : 24,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                '${widget.playerIndex + 1}. Oyuncu',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 12),
                              UndercoverProgress(
                                index: widget.playerIndex,
                                count: widget.playerCount,
                              ),
                              const SizedBox(height: 16),
                              UndercoverArt(size: showCard ? 100 : 136),
                              const SizedBox(height: 16),
                              if (!showCard) ...[
                                Text(
                                  'Telefonu bu oyuncuya ver',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 12),
                              ],
                              Text(
                                widget.playerName,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleLarge,
                              ),
                              if (!showCard) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Gizli bilgin yalnızca sana gösterilecek. Diğer oyuncuların görmediğinden emin ol.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ],
                              const SizedBox(height: 28),
                              if (showCard) ...[
                                Listener(
                                  onPointerUp: (_) => _hide(),
                                  onPointerCancel: (_) => _hide(),
                                  child: GestureDetector(
                                    key: const ValueKey('undercover-hold'),
                                    behavior: HitTestBehavior.opaque,
                                    onLongPressStart: (_) => _reveal(),
                                    onLongPressEnd: (_) => _hide(),
                                    onLongPressCancel: _hide,
                                    child: _SecretWordCard(
                                      secret: _visibleSecret,
                                    ),
                                  ),
                                ),
                              ],

                              if (showCard) ...[
                                const SizedBox(height: 20),
                                const UndercoverPanel(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'Bilgini gördükten sonra “Bilgimi Gördüm” butonuna bas ve telefonu sıradaki oyuncuya ver.',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                              if (!showCard) action,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }
}

class _SecretWordCard extends StatelessWidget {
  const _SecretWordCard({required this.secret});

  final UndercoverSecret? secret;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final active = secret != null;
    final spy = secret?.role == UndercoverRole.spy;
    final foreground = active ? Colors.white : colors.onPrimaryContainer;
    final duration =
        MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 150);

    return AnimatedScale(
      scale: active ? 1.02 : 1,
      duration: duration,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: duration,
        curve: Curves.easeOut,
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 180),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary : colors.primaryContainer,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: colors.primary.withValues(alpha: .30),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: .10),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        // Only the surface animates. The secret text is replaced immediately.
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              active ? Icons.visibility_outlined : Icons.fingerprint_rounded,
              color: foreground,
              size: active ? 24 : 44,
            ),
            const SizedBox(height: 10),
            if (active && !spy) ...[
              Text(
                'KELİMEN',
                style: theme.textTheme.labelLarge?.copyWith(color: foreground),
              ),
              const SizedBox(height: 6),
            ],
            Text(
              spy
                  ? 'SEN CASUSSUN!'
                  : secret?.word ?? 'Bilgini görmek için basılı tut',
              textAlign: TextAlign.center,
              style: (active
                      ? theme.textTheme.headlineMedium
                      : theme.textTheme.titleLarge)
                  ?.copyWith(
                    color: foreground,
                    fontWeight: active ? FontWeight.w900 : null,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              active
                  ? spy
                      ? 'Diğer oyuncuların ipuçlarını dinle ve kelimeyi öğrenmeye çalış.'
                      : 'Parmağını kaldırınca gizlenecek'
                  : 'Yalnızca sen görebilirsin',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}
