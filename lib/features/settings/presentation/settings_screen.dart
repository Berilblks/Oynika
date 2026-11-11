import 'package:go_router/go_router.dart';
import '../../../core/ads/ads_diagnostics.dart';
import 'package:flutter/material.dart';
import '../../games/domain/party_game.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_mode_provider.dart';
import '../../../core/ads/google_ads_backend.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_links.dart';
import '../../../core/utils/app_package_info.dart';
import '../../../core/utils/external_links.dart';
import '../../../shared/widgets/section_heading.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _openLink(
    BuildContext context,
    WidgetRef ref,
    Uri uri,
    String errorMessage,
  ) async {
    try {
      if (await ref.read(externalLinkOpenerProvider)(uri)) return;
    } catch (_) {
      // Missing handlers and platform errors must not interrupt settings.
    }
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedMode = ref.watch(themeModeProvider);
    final ads = ref.watch(adsServiceProvider);
    final packageInfo = ref.watch(appPackageInfoProvider);
    final version = packageInfo.asData?.value;
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppDimensions.contentMaxWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeading(title: 'Ayarlar'),
                const SizedBox(height: 8),
                const Text('Oynika’yı kendine göre ayarla.'),
                const SizedBox(height: 28),
                Text('Görünüm', style: theme.textTheme.titleLarge),
                const SizedBox(height: 6),
                const Text('Sistem seçeneği telefonunun temasını izler.'),
                const SizedBox(height: 12),
                RadioGroup<ThemeMode>(
                  groupValue: selectedMode,
                  onChanged: (mode) {
                    if (mode != null) {
                      ref.read(themeModeProvider.notifier).select(mode);
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final option in [
                        (
                          ThemeMode.system,
                          'Sistem',
                          Icons.brightness_auto_rounded,
                        ),
                        (ThemeMode.light, 'Açık', Icons.light_mode_rounded),
                        (ThemeMode.dark, 'Koyu', Icons.dark_mode_rounded),
                      ])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Material(
                            color: selectedMode == option.$1
                                ? theme.colorScheme.primary.withValues(
                                    alpha: 0.10,
                                  )
                                : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.035,
                                  ),
                            borderRadius: BorderRadius.circular(20),
                            child: RadioListTile<ThemeMode>(
                              key: ValueKey('theme-${option.$1.name}'),
                              value: option.$1,

                              title: Row(
                                children: [
                                  Icon(option.$3, size: 21),
                                  const SizedBox(width: 12),
                                  Flexible(child: Text(option.$2)),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Seçimin uygulama açıkken korunur.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 28),
                Text('Gizlilik ve Yasal', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                Material(
                  color: theme.colorScheme.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    key: const ValueKey('privacy-policy'),
                    leading: const Icon(Icons.policy_outlined),
                    title: const Text('Gizlilik Politikası'),
                    trailing: const Icon(Icons.open_in_new_rounded, size: 20),
                    onTap: () => _openLink(
                      context,
                      ref,
                      AppLinks.privacyTr,
                      'Gizlilik politikası açılamadı. Lütfen tekrar dene.',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Material(
                  color: theme.colorScheme.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    key: const ValueKey('support-contact'),
                    leading: const Icon(Icons.mail_outline_rounded),
                    title: const Text('Destek ve İletişim'),
                    subtitle: const Text(AppLinks.supportEmail),
                    onTap: () => _openLink(
                      context,
                      ref,
                      AppLinks.support,
                      'E-posta uygulaması açılamadı. '
                      '${AppLinks.supportEmail} adresine yazabilirsin.',
                    ),
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: ads.status,
                  builder: (context, status, _) => status.privacyOptions
                      ? TextButton.icon(
                          icon: const Icon(Icons.privacy_tip_outlined),
                          label: const Text('Reklam gizlilik seçenekleri'),
                          onPressed: status.busy
                              ? null
                              : () async {
                                  final success = await ads
                                      .openPrivacyOptions();
                                  if (!success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Gizlilik seçenekleri açılamadı.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 28),
                Text('Oynika hakkında', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                Text(
                  PartyGame.slogan,
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(PartyGame.aboutDescription),
                const SizedBox(height: 12),
                Text(PartyGame.availabilityMessage),
                const SizedBox(height: 24),
                Text(
                  packageInfo.when(
                    data: (info) => 'Sürüm ${packageVersionLabel(info)}',
                    loading: () => 'Sürüm bilgisi yükleniyor…',
                    error: (_, _) => 'Sürüm bilgisi alınamadı.',
                  ),
                  key: const ValueKey('app-version'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: () => showLicensePage(
                    context: context,
                    applicationName: 'Oynika',
                    applicationVersion: version == null
                        ? null
                        : packageVersionLabel(version),
                  ),
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Açık kaynak lisansları'),
                ),
                if (ref.watch(adsQaEnabledProvider))
                  TextButton.icon(
                    icon: const Icon(Icons.bug_report_outlined),
                    label: const Text('Reklam tanılama (QA)'),
                    onPressed: () => context.push('/qa/ads'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
