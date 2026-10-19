import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_mode_provider.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../shared/widgets/section_heading.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedMode = ref.watch(themeModeProvider);
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
                for (final option in [
                  (ThemeMode.system, 'Sistem', Icons.brightness_auto_rounded),
                  (ThemeMode.light, 'Açık', Icons.light_mode_rounded),
                  (ThemeMode.dark, 'Koyu', Icons.dark_mode_rounded),
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color:
                          selectedMode == option.$1
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
                        groupValue: selectedMode,
                        onChanged: (mode) {
                          if (mode != null) {
                            ref.read(themeModeProvider.notifier).select(mode);
                          }
                        },
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
                const SizedBox(height: 12),
                Text(
                  'Seçimin uygulama açıkken korunur.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 28),
                Text('Oynika hakkında', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                const Text(
                  'Oyun Başlasın, Eğlence Başlasın!',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Arkadaşlarını bir araya getiren beş parti oyunu. Tamamen Türkçe, çevrimdışı ve hesapsız.',
                ),
                const SizedBox(height: 12),
                const Text(
                  'Oyunlar geliştirme aşamasında. Bu sürümde oyun tanıtımlarını keşfedebilirsin.',
                ),
                const SizedBox(height: 24),
                Text(
                  'Sürüm 0.1.0+1 • Faz 2',
                  key: const ValueKey('app-version'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed:
                      () => showLicensePage(
                        context: context,
                        applicationName: 'Oynika',
                        applicationVersion: '0.1.0+1',
                      ),
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Açık kaynak lisansları'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
