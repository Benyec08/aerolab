import 'package:flutter/material.dart';
import '../analysis/new_analysis_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      _DashboardItem('Yeni Analiz', 'Uçuş analizi oluştur', Icons.add_chart),
      _DashboardItem('Araç Kütüphanesi', 'Araç profillerini kaydet', Icons.inventory_2),
      _DashboardItem('Analiz Geçmişi', 'Eski analizleri görüntüle', Icons.history),
      _DashboardItem('Raporlar', 'PDF ve teknik çıktılar', Icons.picture_as_pdf),
      _DashboardItem('Ayarlar', 'Tema ve birimler', Icons.settings),
      _DashboardItem('Hakkında', 'Proje bilgileri', Icons.info_outline),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header(),
              const SizedBox(height: 40),
              Expanded(
                child: GridView.builder(
                  itemCount: menuItems.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 280,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: 1.35,
                  ),
                  itemBuilder: (context, index) {
                    final item = menuItems[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        if (item.title == 'Yeni Analiz') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NewAnalysisPage(),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFD9E2EC)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(item.icon, size: 34, color: const Color(0xFF0B3D91)),
                            const Spacer(),
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF102A43),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.subtitle,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF627D98),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF0B3D91),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.flight_takeoff, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 16),
        const Column(
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
            Text(
              'Aircraft Performance Analysis Platform',
              style: TextStyle(fontSize: 14, color: Color(0xFF627D98)),
            ),
          ],
        ),
      ],
    );
  }
}

class _DashboardItem {
  final String title;
  final String subtitle;
  final IconData icon;

  _DashboardItem(this.title, this.subtitle, this.icon);
}