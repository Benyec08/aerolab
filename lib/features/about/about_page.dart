import 'package:flutter/material.dart';

import '../../core/constants/app_info.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Hakkında')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _AboutHeader(colorScheme: colorScheme),
                const SizedBox(height: 18),
                const _AboutSection(
                  title: 'AeroLab Nedir?',
                  icon: Icons.flight_takeoff_outlined,
                  child: Text(
                    'AeroLab; drone, sabit kanat ve kanatlı VTOL hava '
                    'araçları için aerodinamik, itki, enerji, batarya, '
                    'uçuş performansı, kararlılık ve risk değerlendirmeleri '
                    'üreten bir mühendislik analiz uygulamasıdır.',
                  ),
                ),
                const _AboutSection(
                  title: 'Temel Özellikler',
                  icon: Icons.dashboard_customize_outlined,
                  child: _FeatureList(
                    features: [
                      'Drone ve sabit kanat mühendislik analizleri',
                      'ISA tabanlı atmosfer ve çevre koşulları',
                      'Aerodinamik, güç, itki ve enerji hesapları',
                      'Batarya güvenliği ve uçuş süresi değerlendirmesi',
                      'Ağırlık merkezi, statik marj ve uçuş zarfı',
                      'Kalıcı araç kütüphanesi ve analiz geçmişi',
                      'Uygulama içi mühendislik raporları',
                      'Açık, koyu ve sistem teması desteği',
                    ],
                  ),
                ),
                const _AboutSection(
                  title: 'Teknoloji',
                  icon: Icons.code_outlined,
                  child: _FeatureList(
                    features: [
                      'Flutter ve Dart',
                      'Windows masaüstü',
                      'Hive CE yerel veri saklama',
                      'Material 3 kullanıcı arayüzü',
                      'Otomatik test ve statik analiz doğrulaması',
                    ],
                  ),
                ),
                const _AboutSection(
                  title: 'Geliştirici',
                  icon: Icons.person_outline,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppInfo.developer,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'AeroLab, mühendislik doğruluğu ve güvenilir '
                        'masaüstü analiz iş akışı hedefiyle geliştirilmektedir.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '© ${AppInfo.copyrightYear} ${AppInfo.developer}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AboutHeader extends StatelessWidget {
  final ColorScheme colorScheme;

  const _AboutHeader({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 560;

          final logo = Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.flight_takeoff,
              size: 38,
              color: colorScheme.onPrimary,
            ),
          );

          const details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppInfo.name,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(AppInfo.platformDescription),
              SizedBox(height: 8),
              Text(
                AppInfo.fullVersion,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [logo, const SizedBox(height: 16), details],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              logo,
              const SizedBox(width: 18),
              const Expanded(child: details),
            ],
          );
        },
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _AboutSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            DefaultTextStyle.merge(
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 15,
                height: 1.45,
              ),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureList extends StatelessWidget {
  final List<String> features;

  const _FeatureList({required this.features});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        for (final feature in features)
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 19,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 9),
                Expanded(child: Text(feature)),
              ],
            ),
          ),
      ],
    );
  }
}
