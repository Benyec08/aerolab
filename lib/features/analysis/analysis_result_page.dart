import 'package:flutter/material.dart';
import 'models/analysis_result.dart';

class AnalysisResultPage extends StatelessWidget {
  final AnalysisResult result;

  const AnalysisResultPage({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Analiz Sonucu'),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildRiskCard(),
                const SizedBox(height: 24),
                _buildResultGrid(),
                const SizedBox(height: 24),
                _buildRecommendationCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Uçuş Analiz Raporu',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF102A43),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Aerodinamik performans ve temel güvenlik değerlendirmesi',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF627D98),
          ),
        ),
      ],
    );
  }

  Widget _buildRiskCard() {
    Color statusColor;

    if (result.status == 'Güvenli') {
      statusColor = Colors.green;
    } else if (result.status == 'Dikkat') {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.red;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.shield,
            size: 48,
            color: statusColor,
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.status,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Risk Skoru: ${result.riskScore}/100',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF486581),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultGrid() {
    final items = [
      _ResultItem('Lift Force', '${result.liftN.toStringAsFixed(2)} N'),
      _ResultItem('Drag Force', '${result.dragN.toStringAsFixed(2)} N'),
      _ResultItem('Wing Loading', '${result.wingLoading.toStringAsFixed(2)} kg/m²'),
      _ResultItem('Stall Speed', '${result.stallSpeed.toStringAsFixed(2)} m/s'),
      _ResultItem('Thrust / Weight', result.thrustToWeight.toStringAsFixed(2)),
      _ResultItem('Flight Time', '${result.estimatedFlightTime.toStringAsFixed(1)} dk'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        mainAxisSpacing: 18,
        crossAxisSpacing: 18,
        childAspectRatio: 1.8,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFD9E2EC)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF627D98),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item.value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF102A43),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecommendationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFD9E2EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Öneri',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF102A43),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            result.recommendation,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Color(0xFF486581),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultItem {
  final String title;
  final String value;

  _ResultItem(this.title, this.value);
}