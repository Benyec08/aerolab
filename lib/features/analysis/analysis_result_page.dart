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
                _buildMissionPowerSection(),
                _buildEnergySection(),
                _buildPowerReserveSection(),
                _buildRecommendationCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Uçuş Analiz Raporu',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF102A43),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${result.aircraftType} için uygulanabilir performans, '
          'enerji ve güvenlik metrikleri',
          style: const TextStyle(fontSize: 15, color: Color(0xFF627D98)),
        ),
      ],
    );
  }

  Widget _buildRiskCard() {
    final statusColor = _statusColor(result.status);

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
    final scoreCards = <Widget>[
      if (result.aerodynamicScore != null)
        ResultCard(
          title: 'Aerodynamic Score',
          value: '${result.aerodynamicScore}/100',
          color: _scoreColor(result.aerodynamicScore!),
        )
      else
        const ResultCard(
          title: 'Aerodynamic Score',
          value: 'Uygulanamaz',
          color: Color(0xFF627D98),
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
    ];

    return ResultSection(
      title: 'Performance Score',
      icon: Icons.query_stats,
      child: _buildGrid(scoreCards),
    );
  }

  Widget _buildAerodynamicSection() {
    if (!result.hasFixedWingAerodynamics) {
      return ResultSection(
        title: 'Aerodynamic Performance',
        icon: Icons.air,
        child: _buildGrid(const [
          ResultCard(
            title: 'Fixed-Wing Lift Model',
            value: 'Uygulanamaz',
            color: Color(0xFF627D98),
          ),
          ResultCard(
            title: 'Wing Loading',
            value: 'Uygulanamaz',
            color: Color(0xFF627D98),
          ),
          ResultCard(
            title: 'Stall Speed',
            value: 'Uygulanamaz',
            color: Color(0xFF627D98),
          ),
        ]),
      );
    }

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

  Widget _buildMissionPowerSection() {
    final powerCards = <Widget>[
      ResultCard(
        title: 'Power Model',
        value: _shortPowerModelName(result.missionPowerModelName),
        color: const Color(0xFF0B3D91),
      ),
    ];

    if (result.hoverPowerW > 0) {
      powerCards.add(
        ResultCard(
          title: 'Hover Power',
          value: '${result.hoverPowerW.toStringAsFixed(1)} W',
        ),
      );
    }

    if (result.cruisePowerW > 0) {
      powerCards.add(
        ResultCard(
          title: 'Cruise Power',
          value: '${result.cruisePowerW.toStringAsFixed(1)} W',
        ),
      );
    }

    powerCards.addAll([
      ResultCard(
        title: 'Average Mission Power',
        value: '${result.averageMissionPowerW.toStringAsFixed(1)} W',
      ),
      ResultCard(
        title: 'Peak Mission Power',
        value: '${result.peakMissionPowerW.toStringAsFixed(1)} W',
        color: _peakPowerColor(result.peakPowerUsageRatio),
      ),
    ]);

    return ResultSection(
      title: 'Mission Power Analysis',
      icon: Icons.bolt,
      child: _buildGrid(powerCards),
    );
  }

  Widget _buildEnergySection() {
    final batteryUtilizationPercent = result.nominalBatteryEnergyWh > 0
        ? (result.usableBatteryEnergyWh / result.nominalBatteryEnergyWh) * 100
        : 0.0;

    return ResultSection(
      title: 'Energy & Endurance',
      icon: Icons.battery_charging_full,
      child: _buildGrid([
        ResultCard(
          title: 'Estimated Flight Time',
          value: '${result.estimatedFlightTime.toStringAsFixed(1)} dk',
        ),
        ResultCard(
          title: 'Average Battery Current',
          value: '${result.averageBatteryCurrentA.toStringAsFixed(1)} A',
          color: _currentColor(result.averageBatteryCurrentA),
        ),
        ResultCard(
          title: 'Nominal Battery Energy',
          value: '${result.nominalBatteryEnergyWh.toStringAsFixed(1)} Wh',
        ),
        ResultCard(
          title: 'Usable Battery Energy',
          value: '${result.usableBatteryEnergyWh.toStringAsFixed(1)} Wh',
        ),
        ResultCard(
          title: 'Battery Utilization',
          value: '${batteryUtilizationPercent.toStringAsFixed(0)}%',
          color: _batteryUtilizationColor(batteryUtilizationPercent),
        ),
      ]),
    );
  }

  Widget _buildPowerReserveSection() {
    final installedPowerW =
        result.peakMissionPowerW + result.installedPowerReserveW;

    final peakPowerUsagePercent = result.peakPowerUsageRatio * 100.0;

    final reserveStatus = result.hasSufficientInstalledPower
        ? _powerReserveStatus(result.installedPowerReservePercent)
        : 'Yetersiz Güç';

    return ResultSection(
      title: 'Power Reserve',
      icon: Icons.speed,
      child: _buildGrid([
        ResultCard(
          title: 'Installed Motor Power',
          value: '${installedPowerW.toStringAsFixed(1)} W',
        ),
        ResultCard(
          title: 'Installed Power Reserve',
          value:
              '${result.installedPowerReserveW >= 0 ? '+' : ''}'
              '${result.installedPowerReserveW.toStringAsFixed(1)} W',
          color: result.hasSufficientInstalledPower ? Colors.green : Colors.red,
        ),
        ResultCard(
          title: 'Power Reserve Ratio',
          value: '${result.installedPowerReservePercent.toStringAsFixed(1)}%',
          color: result.hasSufficientInstalledPower
              ? _reservePercentColor(result.installedPowerReservePercent)
              : Colors.red,
        ),
        ResultCard(
          title: 'Peak Power Usage',
          value: '${peakPowerUsagePercent.toStringAsFixed(1)}%',
          color: _peakPowerColor(result.peakPowerUsageRatio),
        ),
        ResultCard(
          title: 'Motor System Status',
          value: reserveStatus,
          color: result.hasSufficientInstalledPower
              ? _reservePercentColor(result.installedPowerReservePercent)
              : Colors.red,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 760 ? 3 : 1;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
          childAspectRatio: crossAxisCount == 3 ? 2.4 : 3.2,
          children: children,
        );
      },
    );
  }

  String _buildStars(int score) {
    if (score >= 90) return '★★★★★';
    if (score >= 80) return '★★★★☆';
    if (score >= 70) return '★★★☆☆';
    if (score >= 60) return '★★☆☆☆';
    return '★☆☆☆☆';
  }

  String _shortPowerModelName(String modelName) {
    if (modelName.contains('Multikopter')) {
      return 'Multikopter Hover';
    }

    if (modelName.contains('Sabit Kanat')) {
      return 'Sabit Kanat Seyir';
    }

    if (modelName.contains('VTOL')) {
      return 'VTOL Karma Görev';
    }

    return modelName;
  }

  String _powerReserveStatus(double reservePercent) {
    if (reservePercent >= 50) {
      return 'Yüksek Güç Rezervi';
    }

    if (reservePercent >= 25) {
      return 'İyi Güç Rezervi';
    }

    if (reservePercent >= 10) {
      return 'Sınırlı Güç Rezervi';
    }

    return 'Kritik Güç Rezervi';
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

    if (status == 'Orta' || status == 'Yeterli' || status == 'Uygulanamaz') {
      return Colors.orange;
    }

    return Colors.red;
  }

  Color _peakPowerColor(double usageRatio) {
    if (usageRatio <= 0.75) {
      return Colors.green;
    }

    if (usageRatio <= 0.90) {
      return Colors.orange;
    }

    return Colors.red;
  }

  Color _reservePercentColor(double reservePercent) {
    if (reservePercent >= 25) {
      return Colors.green;
    }

    if (reservePercent >= 10) {
      return Colors.orange;
    }

    return Colors.red;
  }

  Color _batteryUtilizationColor(double utilizationPercent) {
    if (utilizationPercent <= 85) {
      return Colors.green;
    }

    if (utilizationPercent <= 90) {
      return Colors.orange;
    }

    return Colors.red;
  }

  Color _currentColor(double currentA) {
    if (currentA <= 30) {
      return Colors.green;
    }

    if (currentA <= 60) {
      return Colors.orange;
    }

    return Colors.red;
  }
}
