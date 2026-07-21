import 'package:flutter/material.dart';

import '../../data/services/analysis_history_service.dart';
import '../analysis/new_analysis_page.dart';
import '../history/analysis_history_page.dart';

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
    _refreshAnalysisCount();
  }

  void _refreshAnalysisCount() {
    if (!mounted) {
      return;
    }

    try {
      final analysisCount = _historyService.analysisCount;

      setState(() {
        _analysisCount = analysisCount;
      });
    } on StateError {
      setState(() {
        _analysisCount = 0;
      });
    }
  }

  Future<void> _openPage(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));

    _refreshAnalysisCount();
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
                          _StatsRow(analysisCount: _analysisCount),
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
                                      Navigator.pushNamed(context, '/hangar');
                                      break;

                                    case 'Analiz Geçmişi':
                                      _openPage(const AnalysisHistoryPage());
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
                              'AeroLab v0.7 Alpha • Engineering Analysis Platform',
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
                              '© 2026 Yunus Emre Ceylan',
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

  const _StatsRow({required this.analysisCount});

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
              child: const _StatCard(title: 'Kayıtlı Araç', value: '0'),
            ),
            SizedBox(
              width: cardWidth,
              child: const _StatCard(title: 'Risk Raporu', value: '0'),
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
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: widget.onTap,
          child: Card(
            elevation: isHovered ? 8 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    widget.item.icon,
                    size: 34,
                    color: const Color(0xFF0B3D91),
                  ),
                  const Spacer(),
                  Text(
                    widget.item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF102A43),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.item.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF627D98),
                    ),
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
