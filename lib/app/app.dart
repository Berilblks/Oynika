import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/ads/google_ads_backend.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_mode_provider.dart';
import 'launch_splash.dart';

class OynikaApp extends ConsumerStatefulWidget {
  const OynikaApp({super.key});

  @override
  ConsumerState<OynikaApp> createState() => _OynikaAppState();
}

class _OynikaAppState extends ConsumerState<OynikaApp>
    with WidgetsBindingObserver {
  bool _launchFinished = false;
  bool _adsStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void _startAds({bool resumed = false}) {
    if (!_adsStarted) {
      _adsStarted = true;
      unawaited(ref.read(adsServiceProvider).start());
    } else if (resumed) {
      unawaited(ref.read(adsServiceProvider).retryConsent(automatic: true));
    }
  }

  void _finishLaunch() {
    _launchFinished = true;
    final state = WidgetsBinding.instance.lifecycleState;
    if (state == null || state == AppLifecycleState.resumed) _startAds();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_launchFinished && state == AppLifecycleState.resumed) {
      _startAds(resumed: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Oynika',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: ref.watch(themeModeProvider),
    builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: LaunchSplash(onFinished: _finishLaunch, child: child!),
    ),
    routerConfig: ref.watch(appRouterProvider),
  );
}
