import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ads_diagnostics.dart';
import 'google_ads_backend.dart';

class AdsQaScreen extends ConsumerWidget {
  const AdsQaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(adsQaEnabledProvider)) return const SizedBox.shrink();
    final ads = ref.watch(adsServiceProvider);
    final diagnostics = ads.diagnostics;
    if (diagnostics == null) return const SizedBox.shrink();
    return Scaffold(
      appBar: AppBar(title: const Text('Reklam tanılama (QA)')),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([diagnostics, ads.status]),
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Bu kayıtlar yalnızca bu uygulama oturumunda cihaz belleğinde '
                'tutulur. Test düğmeleri oyun sayacını artırmaz.',
              ),
              const SizedBox(height: 16),
              for (final field in AdQaField.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        field.label,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(diagnostics.value(field)),
                    ],
                  ),
                ),
              FilledButton(
                onPressed: ads.qaCanLoad ? () => ads.loadQaTestAd() : null,
                child: const Text('Test reklamını yükle'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: ads.qaCanShow
                    ? () => ads.showQaTestAd(
                        () =>
                            context.mounted &&
                            ModalRoute.isCurrentOf(context) != false,
                      )
                    : null,
                child: const Text('Test reklamını göster'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: ads.status.value.busy
                    ? null
                    : () async {
                        final attempted = await ads.retryConsent();
                        if (!attempted && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Durumu kontrol edin. Yeniden denemeler arasında '
                                'en az 15 saniye bekleyin.',
                              ),
                            ),
                          );
                        }
                      },
                child: const Text('Rıza ve SDK durumunu yeniden dene'),
              ),
              const SizedBox(height: 24),
              Text(
                'Son olaylar',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              for (final event in diagnostics.events.reversed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(event),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
