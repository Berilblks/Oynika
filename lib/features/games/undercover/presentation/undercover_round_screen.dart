import 'dart:async';

import 'package:flutter/material.dart';

import '../application/undercover_controller.dart';
import 'undercover_visuals.dart';

class UndercoverRoundScreen extends StatefulWidget {
  const UndercoverRoundScreen({
    super.key,
    required this.round,
    required this.names,
    required this.activeCount,
    required this.eliminatedRole,
    required this.onBeginVoting,
    required this.onVote,
    required this.onTie,
    required this.onElimination,
    required this.onResults,
    required this.enablePrivacy,
    required this.releasePrivacy,
    required this.onExit,
  });

  final UndercoverRound round;
  final Map<int, String> names;
  final int activeCount;
  final UndercoverRole? eliminatedRole;
  final VoidCallback onBeginVoting;
  final ValueChanged<int> onVote;
  final VoidCallback onTie;
  final VoidCallback onElimination;
  final VoidCallback onResults;
  final Future<void> Function() enablePrivacy;
  final Future<void> Function() releasePrivacy;
  final VoidCallback onExit;

  @override
  State<UndercoverRoundScreen> createState() => _UndercoverRoundScreenState();
}

class _UndercoverRoundScreenState extends State<UndercoverRoundScreen>
    with WidgetsBindingObserver {
  bool _ballotOpen = false;
  bool _opening = false;
  bool _asking = false;
  int _privacyEpoch = 0;
  int? _selected;

  UndercoverRound get round => widget.round;
  String name(int id) => widget.names[id]!;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_ballotOpen) unawaited(widget.releasePrivacy());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _closeBallot();
  }

  void _closeBallot() {
    _privacyEpoch++;
    if (!_ballotOpen) return;
    setState(() {
      _ballotOpen = false;
      _selected = null;
    });
    unawaited(widget.releasePrivacy());
  }

  Future<void> _openBallot() async {
    if (_opening || _asking) return;
    final epoch = _privacyEpoch;
    final releasePrivacy = widget.releasePrivacy;
    setState(() => _opening = true);
    try {
      await widget.enablePrivacy();
      if (!mounted || epoch != _privacyEpoch) {
        await releasePrivacy();
        return;
      }
      setState(() => _ballotOpen = true);
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gizlilik koruması açılamadı. Tekrar dene.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  void _confirmVote() {
    final selected = _selected;
    if (!_ballotOpen || selected == null) return;
    _closeBallot();
    widget.onVote(selected);
  }

  Future<void> _exit() async {
    if (_asking) return;
    if (round.winner != null) {
      widget.onExit();
      return;
    }
    _closeBallot();
    _asking = true;
    final leave = await showDialog<bool>(
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
    if (leave == true) widget.onExit();
  }

  Widget _row(int id, {int? position, VoidCallback? select}) {
    final colors = Theme.of(context).colorScheme;
    final selected = id == _selected;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: selected ? colors.primaryContainer : colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: selected ? colors.primary : colors.outlineVariant,
        ),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        selected: selected,
        onTap: select,
        leading: CircleAvatar(
          backgroundColor: colors.secondaryContainer,
          foregroundColor: colors.onSecondaryContainer,
          child:
              position == null
                  ? const Icon(Icons.person_outline_rounded)
                  : Text('$position'),
        ),
        title: Text(name(id)),
        subtitle: position == 1 ? const Text('İlk ipucu') : null,
        trailing:
            select == null
                ? null
                : Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    late final String title;
    String? description;
    late final String action;
    VoidCallback? onAction;
    Widget? avatar;
    Widget? progress;
    var rows = <Widget>[];
    Widget? outcome;
    final runoff = round.runoffCandidates.isNotEmpty;

    switch (round.phase) {
      case UndercoverPhase.clue:
        title = 'Herkes sırayla bir ipucu versin!';
        description =
            'Herkes sırayla tek kelimelik bir ipucu versin. Gizli kelimeyi doğrudan söylemeyin!';
        avatar = const UndercoverArt(size: 80);
        rows = [
          for (final (index, id) in round.order.indexed)
            _row(id, position: index + 1),
        ];
        action = 'Oylamaya Geç';
        onAction = widget.onBeginVoting;
      case UndercoverPhase.voting:
        progress = Text(
          '${round.votes.length} / ${round.order.length} oy',
          textAlign: TextAlign.center,
        );
        if (_ballotOpen) {
          title = 'Kimden şüpheleniyorsun?';
          avatar = const UndercoverArt(size: 64);
          rows = [
            for (final id in round.candidates)
              _row(id, select: () => setState(() => _selected = id)),
          ];
          action = 'Oyumu Onayla';
          onAction = _selected == null ? null : _confirmVote;
        } else {
          title = 'Telefonu bu oyuncuya ver';
          description =
              '${round.votes.length + 1}. Oyuncu: ${name(round.voter!)}';
          avatar = const UndercoverArt(size: 88);
          action = 'Oy Vermeye Başla';
          onAction = _opening ? null : _openBallot;
        }
      case UndercoverPhase.tie:
        title = runoff ? 'Bu tur kimse elenmedi!' : 'Oylar Eşit!';
        avatar = const UndercoverArt(size: 96);
        if (!runoff) rows = [for (final id in round.leaders) _row(id)];
        action = runoff ? 'Yeni Tura Geç' : 'Yeniden Oyla';
        onAction = widget.onTie;
      case UndercoverPhase.elimination:
        final spy = widget.eliminatedRole == UndercoverRole.spy;
        title = '${name(round.eliminatedId!)} Elendi!';
        avatar = const UndercoverArt(size: 144);
        outcome = Column(
          children: [
            UndercoverPanel(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Text(
                spy ? 'CASUSTU!' : 'NORMAL OYUNCUYDU',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: spy ? colors.tertiary : colors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('${widget.activeCount} oyuncu kaldı.'),
            if (round.winner != null) ...[
              const SizedBox(height: 20),
              UndercoverWinner(
                label:
                    round.winner == UndercoverRole.spy
                        ? 'CASUSLAR KAZANDI!'
                        : 'NORMAL OYUNCULAR KAZANDI!',
              ),
            ],
          ],
        );
        action = round.winner == null ? 'Yeni Tura Geç' : 'Oyun Sonuçları';
        onAction =
            round.winner == null ? widget.onElimination : widget.onResults;
      default:
        throw StateError('Unexpected round phase: ${round.phase}');
    }

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
          title: Text(
            runoff && round.phase == UndercoverPhase.voting
                ? 'Beraberlik Oylaması'
                : '${round.number}. Tur',
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SizedBox(
                width: double.infinity,
                child: UndercoverButton(label: action, onPressed: onAction),
              ),
            ),
          ),
        ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (progress != null) ...[
                                progress,
                                const SizedBox(height: 20),
                              ],
                              if (avatar != null) ...[
                                avatar,
                                const SizedBox(height: 16),
                              ],
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineMedium,
                              ),
                              if (description != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  description,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                              if (outcome != null) ...[
                                const SizedBox(height: 16),
                                outcome,
                              ],
                              if (rows.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                ...rows,
                              ],
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
