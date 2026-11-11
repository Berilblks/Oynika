import 'package:flutter/material.dart';

/// A first-launch Flutter overlay; native splash removal is left to Flutter.
class LaunchSplash extends StatefulWidget {
  const LaunchSplash({
    super.key,
    required this.child,
    required this.onFinished,
  });

  static const duration = Duration(milliseconds: 2500);
  static const fadeDuration = Duration(milliseconds: 350);

  final Widget child;
  final VoidCallback onFinished;

  @override
  State<LaunchSplash> createState() => _LaunchSplashState();
}

class _LaunchSplashState extends State<LaunchSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: LaunchSplash.duration,
    );
    _opacity = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.86, 1, curve: Curves.easeInOut),
      ),
    );
    _controller.addStatusListener((status) {
      if (status != AnimationStatus.completed || !mounted) return;
      setState(() => _finished = true);
      // Consent UI may open only after the splash has left the rendered frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onFinished();
      });
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ExcludeSemantics(
          excluding: !_finished,
          child: IgnorePointer(ignoring: !_finished, child: widget.child),
        ),
        if (!_finished)
          Positioned.fill(
            child: FadeTransition(
              key: const ValueKey('launch-splash'),
              opacity: _opacity,
              child: ColoredBox(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: SafeArea(
                  child: Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.48,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 240),
                        child: Image.asset(
                          'assets/branding/oynika_logo_borderless.png',
                          fit: BoxFit.contain,
                          semanticLabel: 'Oynika',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
