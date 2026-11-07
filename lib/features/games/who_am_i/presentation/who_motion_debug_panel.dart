import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const whoMotionDebugEnabled =
    kDebugMode &&
    bool.fromEnvironment('OYNIKA_WHO_MOTION_DEBUG', defaultValue: false);

/// Never rendered in release/profile, even if a caller requests visibility.
class WhoMotionDebugPanel extends StatelessWidget {
  const WhoMotionDebugPanel({
    super.key,
    required this.diagnostics,
    this.enabled = whoMotionDebugEnabled,
    this.debugBuild = kDebugMode,
  });
  final String diagnostics;
  final bool debugBuild;
  final bool enabled;
  @override
  Widget build(BuildContext context) {
    if (!kDebugMode || !debugBuild || !enabled) return const SizedBox.shrink();
    return SizedBox(
      height: 38,
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          diagnostics,
          key: const ValueKey('who-motion-debug'),
          maxLines: 3,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontSize: 10, height: 1.15),
        ),
      ),
    );
  }
}
