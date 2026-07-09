import 'package:flutter/material.dart';

import 'models/analysis_result.dart';
import 'widgets/result_card.dart';
import 'widgets/result_section.dart';

class AnalysisResultPage extends StatelessWidget {
  final AnalysisResult result;

  const AnalysisResultPage({super.key, required this.result});

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
          constraints: const BoxConstraints(maxWidth: 1100),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildRiskCard(),
                const SizedBox(height: 28),
                _buildScoreSection(),
                _buildAerodynamicSection(),
                _buildPropulsionSection(),
                _buildEnergySection(),
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
          'Aerodinamik performans, tahrik sistemi, enerji ve güvenlik değerlendirmesi',
          style: TextStyle(fontSize: 15, color: Color(0xFF627D98)),
        ),
      ],
    );
  }

  Widget _buildRiskCard() {
    final Color statusColor = _statusColor(result.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: statusColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.shield, size: 56, color: statusColor),
          const SizedBox(width: 24),
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
              const SizedBox(height: 8),
              const Text(
                'Overall Engineering Score',
                style: TextStyle(fontSize: 15, color: Color(0xFF486581)),
              ),
              const SizedBox(height: 8),
              Text(
                '${result.overallScore}/100',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF102A43),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _buildStars(result.overallScore),
                style: const TextStyle(fontSize: 22, color: Colors.amber),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSection() {
    return ResultSection(
      title: 'Performance Score',
      icon: Icons.query_stats,
      child: _buildGrid([
        ResultCard(
          title: 'Aerodynamic Score',
          value: '${result.aerodynamicScore}/100',
          color: _scoreColor(result.aerodynamicScore),
        ),
        ResultCard(
          title: 'Propulsion Score',
          value: '${result.propulsionScore}/100',
          color: _scoreColor(result.propulsionScore),
        ),
        ResultCard(
          title: 'Energy Score',
          value: '${result.energyScore}/100',
          color: _scoreColor(result.energyScore),
        ),
      ]),
    );
  }

  Widget _buildAerodynamicSection() {
    return ResultSection(
      title: 'Aerodynamic Performance',
      icon: Icons.air,
      child: _buildGrid([
        ResultCard(
          title: 'Lift Force',
          value: '${result.liftN.toStringAsFixed(2)} N',
        ),
        ResultCard(
          title: 'Drag Force',
          value: '${result.dragN.toStringAsFixed(2)} N',
        ),
        ResultCard(
          title: 'Aspect Ratio',
          value: result.aspectRatio.toStringAsFixed(2),
        ),
        ResultCard(
          title: 'Wing Loading',
          value: '${result.wingLoading.toStringAsFixed(2)} kg/m²',
        ),
        ResultCard(
          title: 'Wing Loading Status',
          value: result.wingLoadingStatus,
          color: _statusCardColor(result.wingLoadingStatus),
        ),
        ResultCard(
          title: 'Stall Speed',
          value: '${result.stallSpeed.toStringAsFixed(2)} m/s',
        ),
      ]),
    );
  }

  Widget _buildPropulsionSection() {
    return ResultSection(
      title: 'Propulsion System',
      icon: Icons.settings,
      child: _buildGrid([
        ResultCard(
          title: 'Estimated Thrust',
          value: '${result.estimatedThrustN.toStringAsFixed(2)} N',
        ),
        ResultCard(
          title: 'Thrust / Weight',
          value: result.thrustToWeight.toStringAsFixed(2),
        ),
        ResultCard(
          title: 'Thrust Status',
          value: result.thrustToWeightStatus,
          color: _statusCardColor(result.thrustToWeightStatus),
        ),
        ResultCard(
          title: 'Power / Weight',
          value: '${result.powerToWeight.toStringAsFixed(1)} W/kg',
        ),
        ResultCard(
          title: 'Power Status',
          value: result.powerToWeightStatus,
          color: _statusCardColor(result.powerToWeightStatus),
        ),
      ]),
    );
  }

  Widget _buildEnergySection() {
    return ResultSection(
      title: 'Energy & Endurance',
      icon: Icons.battery_charging_full,
      child: _buildGrid([
        ResultCard(
          title: 'Estimated Flight Time',
          value: '${result.estimatedFlightTime.toStringAsFixed(1)} dk',
        ),
      ]),
    );
  }

  Widget _buildRecommendationCard() {
    final recommendations = result.recommendation.split('\n');

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
          const Row(
            children: [
              Icon(Icons.tips_and_updates, color: Color(0xFF0B3D91)),
              SizedBox(width: 10),
              Text(
                'Engineering Recommendation',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF102A43),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...recommendations.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: Color(0xFF486581),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<Widget> children) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 18,
      mainAxisSpacing: 18,
      childAspectRatio: 2.4,
      children: children,
    );
  }

  String _buildStars(int score) {
    if (score >= 90) return '★★★★★';
    if (score >= 80) return '★★★★☆';
    if (score >= 70) return '★★★☆☆';
    if (score >= 60) return '★★☆☆☆';
    return '★☆☆☆☆';
  }

  Color _statusColor(String status) {
    if (status == 'Güvenli') {
      return Colors.green;
    }

    if (status == 'Dikkat') {
      return Colors.orange;
    }

    return Colors.red;
  }

  Color _scoreColor(int score) {
    if (score >= 90) {
      return Colors.green;
    }

    if (score >= 70) {
      return Colors.orange;
    }

    return Colors.red;
  }

  Color _statusCardColor(String status) {
    if (status == 'İyi' || status == 'Çok İyi' || status == 'Çok Güçlü') {
      return Colors.green;
    }

    if (status == 'Orta' || status == 'Yeterli') {
      return Colors.orange;
    }

    return Colors.red;
  }
}
