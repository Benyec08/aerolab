import 'package:flutter/material.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../core/constants/app_info.dart';
import '../../data/entities/aircraft_entity.dart';
import '../../data/hive/hive_boxes.dart';

import '../../data/services/analysis_history_service.dart';
import '../about/about_page.dart';
import '../analysis/new_analysis_page.dart';
import '../history/analysis_history_page.dart';
import '../reports/reports_page.dart';
import '../settings/settings_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  final AnalysisHistoryService _historyService = AnalysisHistoryService();
  int _analysisCount = 0;
  int _registeredAircraftCount = 0;
  int _riskyAnalysisCount = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    _refreshDashboardStats();
  }

  void _refreshDashboardStats() {
    if (!mounted) {
      return;
    }

    var analysisCount = 0;
    var registeredAircraftCount = 0;
    var riskyAnalysisCount = 0;

    if (Hive.isBoxOpen(HiveBoxes.analysisHistory)) {
      try {
        final analyses = _historyService.getAllAnalyses();
        analysisCount = analyses.length;

        for (final analysis in analyses) {
          try {
            final result = _historyService.restoreResult(analysis);

            if (result.riskScore < 60) {
              riskyAnalysisCount++;
            }
          } catch (_) {
            // Bozuk veya eski bir kayıt diğer istatistiklerin yüklenmesini engellemez.
          }
        }
      } catch (_) {
        analysisCount = 0;
        riskyAnalysisCount = 0;
      }
    }

    if (Hive.isBoxOpen(HiveBoxes.aircraft)) {
      try {
        registeredAircraftCount = Hive.box<AircraftEntity>(
          HiveBoxes.aircraft,
        ).length;
      } catch (_) {
        registeredAircraftCount = 0;
      }
    }

    setState(() {
      _analysisCount = analysisCount;
      _registeredAircraftCount = registeredAircraftCount;
      _riskyAnalysisCount = riskyAnalysisCount;
    });
  }

  Future<void> _openPage(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));

    _refreshDashboardStats();
  }

  Future<void> _openAircraftHangar() async {
    await Navigator.pushNamed(context, '/hangar');

    _refreshDashboardStats();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      const _DashboardItem(
        'Yeni Analiz',
        'Uçuş analizi oluştur',
        Icons.add_chart,
      ),
      const _DashboardItem(
        'Araç Kütüphanesi',
        'Araç profillerini kaydet',
        Icons.inventory_2,
      ),
      const _DashboardItem(
        'Analiz Geçmişi',
        'Eski analizleri görüntüle',
        Icons.history,
      ),
      const _DashboardItem(
        'Raporlar',
        'PDF ve teknik çıktılar',
        Icons.picture_as_pdf,
      ),
      const _DashboardItem('Ayarlar', 'Tema ve birimler', Icons.settings),
      const _DashboardItem('Hakkında', 'Proje bilgileri', Icons.info_outline),
    ];

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _Header(),
                          const SizedBox(height: 32),
                          const _HeroPanel(),
                          const SizedBox(height: 20),
                          _StatsRow(
                            analysisCount: _analysisCount,
                            registeredAircraftCount: _registeredAircraftCount,
                            riskyAnalysisCount: _riskyAnalysisCount,
                          ),
                          const SizedBox(height: 24),
                          GridView.builder(
                            itemCount: menuItems.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 300,
                                  mainAxisExtent: 190,
                                  mainAxisSpacing: 18,
                                  crossAxisSpacing: 18,
                                ),
                            itemBuilder: (context, index) {
                              final item = menuItems[index];

                              return _DashboardCard(
                                item: item,
                                onTap: () {
                                  switch (item.title) {
                                    case 'Yeni Analiz':
                                      _openPage(const NewAnalysisPage());
                                      break;

                                    case 'Araç Kütüphanesi':
                                      _openAircraftHangar();
                                      break;

                                    case 'Analiz Geçmişi':
                                      _openPage(const AnalysisHistoryPage());
                                      break;

                                    case 'Raporlar':
                                      _openPage(const ReportsPage());
                                      break;

                                    case 'Ayarlar':
                                      _openPage(const SettingsPage());
                                      break;

                                    case 'Hakkında':
                                      _openPage(const AboutPage());
                                      break;

                                    default:
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${item.title} modülü yakında eklenecek.',
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                  }
                                },
                              );
                            },
                          ),
                          const Divider(height: 30),
                          const Center(
                            child: Text(
                              '${AppInfo.fullVersion} • ${AppInfo.platformDescription}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF627D98),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Center(
                            child: Text(
                              '© ${AppInfo.copyrightYear} ${AppInfo.developer}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9FB3C8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 620;

        const logo = _DashboardLogo();

        const title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AeroLab',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF102A43),
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Aircraft Performance Analysis Platform',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: Color(0xFF627D98)),
            ),
          ],
        );

        if (isNarrow) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [logo, SizedBox(height: 14), title],
          );
        }

        return const Row(
          children: [
            logo,
            SizedBox(width: 16),
            Expanded(child: title),
          ],
        );
      },
    );
  }
}

class _DashboardLogo extends StatelessWidget {
  const _DashboardLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF0B3D91),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.flight_takeoff, color: Colors.white, size: 30),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 620;

        const icon = Icon(Icons.analytics, color: Colors.white, size: 46);

        const content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Engineering Analysis Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Drone ve sabit kanat hava araçları için performans, risk ve uçuş güvenliği analizleri.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ],
        );

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isNarrow ? 22 : 28),
          decoration: BoxDecoration(
            color: const Color(0xFF0B3D91),
            borderRadius: BorderRadius.circular(28),
          ),
          child: isNarrow
              ? const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [icon, SizedBox(height: 18), content],
                )
              : const Row(
                  children: [
                    icon,
                    SizedBox(width: 22),
                    Expanded(child: content),
                  ],
                ),
        );
      },
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int analysisCount;
  final int registeredAircraftCount;
  final int riskyAnalysisCount;

  const _StatsRow({
    required this.analysisCount,
    required this.registeredAircraftCount,
    required this.riskyAnalysisCount,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;

        final columnCount = constraints.maxWidth >= 850
            ? 3
            : constraints.maxWidth >= 520
            ? 2
            : 1;

        final cardWidth =
            (constraints.maxWidth - spacing * (columnCount - 1)) / columnCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: cardWidth,
              child: _StatCard(
                title: 'Analiz Sayısı',
                value: analysisCount.toString(),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _StatCard(
                title: 'Kayıtlı Araç',
                value: registeredAircraftCount.toString(),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _StatCard(
                title: 'Riskli Analiz',
                value: riskyAnalysisCount.toString(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9E2EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF102A43),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: Color(0xFF627D98)),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatefulWidget {
  final _DashboardItem item;
  final VoidCallback onTap;

  const _DashboardCard({required this.item, required this.onTap});

  @override
  State<_DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<_DashboardCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDarkMode
        ? (isHovered ? const Color(0xFF1E5BC6) : const Color(0xFF164EA6))
        : Theme.of(context).cardColor;

    final iconColor = isDarkMode ? Colors.white : const Color(0xFF0B3D91);
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF102A43);
    final subtitleColor = isDarkMode
        ? const Color(0xFFD9E8FF)
        : const Color(0xFF627D98);

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },
      child: AnimatedScale(
        scale: isHovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 180),
        child: Card(
          elevation: isHovered ? 8 : 2,
          color: cardColor,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: isDarkMode
                ? BorderSide(color: Colors.white.withValues(alpha: 0.10))
                : BorderSide.none,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(widget.item.icon, size: 34, color: iconColor),
                  const Spacer(),
                  Text(
                    widget.item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.item.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: subtitleColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardItem {
  final String title;
  final String subtitle;
  final IconData icon;

  const _DashboardItem(this.title, this.subtitle, this.icon);
}
