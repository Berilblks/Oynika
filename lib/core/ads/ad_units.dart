import 'package:flutter/foundation.dart';

String? interstitialAdUnitFor(
  TargetPlatform platform, {
  required bool release,
  bool testMode = false,
  bool qa = false,
  bool web = false,
}) {
  if (web) return null;
  final live = release && !testMode && !qa;
  return switch (platform) {
    TargetPlatform.android =>
      live
          ? 'ca-app-pub-8170413007027196/4528638952'
          : 'ca-app-pub-3940256099942544/1033173712',
    TargetPlatform.iOS =>
      live
          ? 'ca-app-pub-8170413007027196/3293392996'
          : 'ca-app-pub-3940256099942544/4411468910',
    _ => null,
  };
}

bool isGoogleTestInterstitialUnit(String? unit) =>
    unit == 'ca-app-pub-3940256099942544/4411468910' ||
    unit == 'ca-app-pub-3940256099942544/1033173712';
