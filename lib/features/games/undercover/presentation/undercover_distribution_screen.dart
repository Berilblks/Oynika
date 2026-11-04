import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_theme.dart';

class UndercoverDistributionScreen extends StatefulWidget {
  const UndercoverDistributionScreen({
    super.key,
    required this.playerName,
    required this.hasSeenWord,
    required this.onReveal,
    required this.onNext,
    required this.onExit,
  });

  final String? playerName;
  final bool hasSeenWord;
  final String? Function() onReveal;
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
  String? _visibleWord;

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
    if (_visibleWord != null) setState(() => _visibleWord = null);
  }

  void _reveal() {
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (_asking ||
        (lifecycle != null && lifecycle != AppLifecycleState.resumed)) {
      return;
    }
    if (_visibleWord != null) return;
    final word = widget.onReveal();
    if (word == null) return;
    setState(() => _visibleWord = word);
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
    final colors = theme.colorScheme;
    final ready = widget.playerName == null;
    final showCard = _armed && !ready;
    final action = FilledButton(
      style: FilledButton.styleFrom(minimumSize: const Size(0, 56)),
      onPressed:
          ready
              ? () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('İpucu turu Faz 5.3’te eklenecek.'),
                ),
              )
              : !_armed
              ? () => setState(() => _armed = true)
              : widget.hasSeenWord && _visibleWord == null
              ? () {
                _hide();
                widget.onNext();
              }
              : null,
      child: Text(
        ready
            ? 'İpucu Turuna Geç'
            : _armed
            ? 'Kelimeyi Gördüm'
            : 'Kelimemi Gör',
        textAlign: TextAlign.center,
      ),
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exit();
      },
      child: Scaffold(
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
                    constraints: BoxConstraints(
                      minHeight: ready ? 0 : viewport.maxHeight,
                    ),
                    child: Align(
                      alignment: ready ? Alignment.topCenter : Alignment.center,
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
                              Icon(
                                ready
                                    ? Icons.groups_rounded
                                    : Icons.person_search_rounded,
                                color: colors.primary,
                                size: 42,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                ready
                                    ? 'Herkes Hazır mı?'
                                    : 'Telefonu bu oyuncuya ver',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 12),
                              if (!ready)
                                Text(
                                  widget.playerName!,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleLarge,
                                ),
                              const SizedBox(height: 8),
                              Text(
                                ready
                                    ? 'Artık sırayla kelimenizi çağrıştıran tek bir ipucu söyleyin. Kelimenizi doğrudan söylemeyin!'
                                    : 'Kelimen yalnızca sana gösterilecek. Diğer oyuncuların görmediğinden emin ol.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge,
                              ),
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
                                    child: _SecretWordCard(word: _visibleWord),
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
  const _SecretWordCard({required this.word});

  final String? word;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final active = word != null;
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
          borderRadius: BorderRadius.circular(20),
        ),
        // Only the surface animates. The secret text is replaced immediately.
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              active ? Icons.visibility_outlined : Icons.fingerprint_rounded,
              color: foreground,
              size: 24,
            ),
            const SizedBox(height: 10),
            Text(
              word ?? 'Kelimeyi görmek için basılı tut',
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
                  ? 'Parmağını kaldırınca gizlenecek'
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
