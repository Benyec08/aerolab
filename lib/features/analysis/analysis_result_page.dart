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
                _buildAtmosphereSection(),
                _buildWindSection(),
                _buildAerodynamicSection(),
                _buildPropulsionSection(),
                _buildMissionPowerSection(),
                _buildEnergySection(),
                _buildBatteryRecommendationSection(),
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

  Widget _buildAtmosphereSection() {
    return ResultSection(
      title: 'Atmosphere Analysis',
      icon: Icons.cloud_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGrid([
            ResultCard(
              title: 'Geometric Altitude',
              value: '${result.geometricAltitudeM.toStringAsFixed(0)} m',
            ),
            ResultCard(
              title: 'Density Altitude',
              value: _formatMetersWithoutNegativeZero(result.densityAltitudeM),
              color: _densityAltitudeColor(result.densityAltitudeDifferenceM),
            ),
            ResultCard(
              title: 'Density Altitude Difference',
              value: _formatSignedMetersWithoutNegativeZero(
                result.densityAltitudeDifferenceM,
              ),
              color: _densityAltitudeColor(result.densityAltitudeDifferenceM),
            ),
            ResultCard(
              title: 'Environment Temperature',
              value: '${result.environmentTemperatureC.toStringAsFixed(1)} °C',
            ),
            ResultCard(
              title: 'ISA Temperature',
              value: '${result.isaTemperatureC.toStringAsFixed(1)} °C',
            ),
            ResultCard(
              title: 'ISA Temperature Deviation',
              value:
                  '${result.temperatureDeviationC >= 0 ? '+' : ''}'
                  '${result.temperatureDeviationC.toStringAsFixed(1)} °C',
              color: _temperatureDeviationColor(result.temperatureDeviationC),
            ),
            ResultCard(
              title: 'Environment Pressure',
              value: '${result.environmentPressureHpa.toStringAsFixed(1)} hPa',
            ),
            ResultCard(
              title: 'ISA Pressure',
              value: '${result.isaPressureHpa.toStringAsFixed(1)} hPa',
            ),
            ResultCard(
              title: 'Pressure Deviation',
              value:
                  '${result.pressureDeviationPercent >= 0 ? '+' : ''}'
                  '${result.pressureDeviationPercent.toStringAsFixed(1)}%',
              color: _pressureDeviationColor(result.pressureDeviationPercent),
            ),
          ]),
          const SizedBox(height: 24),
          const Text(
            'Humidity & Air Density',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF102A43),
            ),
          ),
          const SizedBox(height: 14),
          _buildGrid([
            ResultCard(
              title: 'Relative Humidity',
              value: '${result.relativeHumidityPercent.toStringAsFixed(1)}%',
            ),
            ResultCard(
              title: 'Humid Air Density',
              value: '${result.humidAirDensityKgM3.toStringAsFixed(4)} kg/m³',
            ),
            ResultCard(
              title: 'ISA Air Density',
              value: '${result.isaDensityKgM3.toStringAsFixed(4)} kg/m³',
            ),
            ResultCard(
              title: 'Density Deviation',
              value:
                  '${result.densityDeviationPercent >= 0 ? '+' : ''}'
                  '${result.densityDeviationPercent.toStringAsFixed(1)}%',
              color: _densityDeviationColor(result.densityDeviationPercent),
            ),
            ResultCard(
              title: 'Vapor Pressure',
              value: '${result.vaporPressureHpa.toStringAsFixed(2)} hPa',
            ),
            ResultCard(
              title: 'Dry Air Partial Pressure',
              value:
                  '${result.dryAirPartialPressureHpa.toStringAsFixed(2)} hPa',
            ),
            ResultCard(
              title: 'Atmosphere Status',
              value: result.atmosphereStatus,
              color: _atmosphereStatusColor(
                result.isAtmosphereWithinSupportedLimits,
                result.atmosphereStatus,
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildWindSection() {
    return ResultSection(
      title: 'Wind System Analysis',
      icon: Icons.air,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGrid([
            ResultCard(
              title: 'Wind Speed',
              value:
                  '${result.windSpeedKmh.toStringAsFixed(1)} km/h'
                  ' (${result.windSpeedMs.toStringAsFixed(2)} m/s)',
              color: _windIntensityColor(result.windIntensityStatus),
            ),
            ResultCard(title: 'Wind Direction', value: result.windDirection),
            ResultCard(
              title: 'Wind Intensity',
              value: result.windIntensityStatus,
              color: _windIntensityColor(result.windIntensityStatus),
            ),
            ResultCard(
              title: 'Headwind Component',
              value: '${result.headwindComponentMs.toStringAsFixed(2)} m/s',
              color: result.headwindComponentMs > 0
                  ? Colors.orange
                  : const Color(0xFF627D98),
            ),
            ResultCard(
              title: 'Tailwind Component',
              value: '${result.tailwindComponentMs.toStringAsFixed(2)} m/s',
              color: result.tailwindComponentMs > 0
                  ? Colors.orange
                  : const Color(0xFF627D98),
            ),
            ResultCard(
              title: 'Crosswind Component',
              value:
                  '${result.crosswindComponentMs.toStringAsFixed(2)} m/s'
                  ' • ${result.crosswindDirection}',
              color: _crosswindColor(result.crosswindComponentMs),
            ),
          ]),
          const SizedBox(height: 24),
          const Text(
            'Airspeed & Ground Speed',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF102A43),
            ),
          ),
          const SizedBox(height: 14),
          _buildGrid([
            ResultCard(
              title: 'Commanded Airspeed',
              value: '${result.commandedAirspeedMs.toStringAsFixed(2)} m/s',
            ),
            ResultCard(
              title: 'Effective Airspeed',
              value: '${result.effectiveAirspeedMs.toStringAsFixed(2)} m/s',
              color: _effectiveAirspeedColor(
                result.commandedAirspeedMs,
                result.effectiveAirspeedMs,
              ),
            ),
            ResultCard(
              title: 'Estimated Ground Speed',
              value: '${result.estimatedGroundSpeedMs.toStringAsFixed(2)} m/s',
            ),
            ResultCard(
              title: 'Wind Safety',
              value: result.windSafetyStatus,
              color: result.isWindWithinSupportedLimits
                  ? _windSafetyColor(result.windSafetyStatus)
                  : Colors.red,
            ),
          ]),
        ],
      ),
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

    final liftCoefficientUsagePercent =
        result.liftCoefficientUsageRatio * 100.0;

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
          title: 'Lift / Drag',
          value: result.liftToDragRatio.toStringAsFixed(2),
          color: _liftToDragColor(result.liftToDragRatio),
        ),
        ResultCard(
          title: 'Cruise Speed',
          value: '${result.cruiseSpeedMs.toStringAsFixed(1)} m/s',
        ),
        ResultCard(
          title: 'Dynamic Pressure',
          value: '${result.dynamicPressurePa.toStringAsFixed(1)} Pa',
        ),
        ResultCard(
          title: 'Cruise CL',
          value: result.requiredLiftCoefficient.toStringAsFixed(3),
          color: _liftCoefficientColor(result.liftCoefficientUsageRatio),
        ),
        ResultCard(
          title: 'Cruise CD',
          value: result.dragCoefficient.toStringAsFixed(4),
        ),
        ResultCard(
          title: 'Induced Drag Factor',
          value: result.inducedDragFactor.toStringAsFixed(4),
        ),
        ResultCard(
          title: 'CL / CLmax Usage',
          value: '${liftCoefficientUsagePercent.toStringAsFixed(1)}%',
          color: _liftCoefficientColor(result.liftCoefficientUsageRatio),
        ),
        ResultCard(
          title: 'Cruise Validity',
          value: result.isCruiseAerodynamicallyValid
              ? 'Geçerli'
              : 'CLmax Aşıldı',
          color: result.isCruiseAerodynamicallyValid
              ? Colors.green
              : Colors.red,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGrid([
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
          const SizedBox(height: 24),
          const Text(
            'Propulsion Power Chain',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF102A43),
            ),
          ),
          const SizedBox(height: 14),
          _buildGrid([
            ResultCard(
              title: 'ESC Output Power',
              value: '${result.escOutputPowerW.toStringAsFixed(1)} W',
            ),
            ResultCard(
              title: 'Motor Shaft Power',
              value: '${result.motorShaftPowerW.toStringAsFixed(1)} W',
            ),
            ResultCard(
              title: 'Useful Propulsive Power',
              value: '${result.usefulPropulsivePowerW.toStringAsFixed(1)} W',
            ),
            ResultCard(
              title: 'Total Propulsion Efficiency',
              value:
                  '${(result.totalPropulsionEfficiency * 100).toStringAsFixed(1)}%',
              color: _propulsionEfficiencyColor(
                result.totalPropulsionEfficiency,
              ),
            ),
          ]),
          const SizedBox(height: 24),
          const Text(
            'Motor Load Analysis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF102A43),
            ),
          ),
          const SizedBox(height: 14),
          _buildGrid([
            ResultCard(
              title: 'Average Continuous Load',
              value:
                  '${(result.averageContinuousLoadRatio * 100).toStringAsFixed(1)}%',
              color: _motorLoadColor(result.averageContinuousLoadRatio),
            ),
            ResultCard(
              title: 'Peak Maximum Load',
              value:
                  '${(result.peakMaximumLoadRatio * 100).toStringAsFixed(1)}%',
              color: _motorLoadColor(result.peakMaximumLoadRatio),
            ),
            ResultCard(
              title: 'Continuous Power Reserve',
              value: '${result.continuousPowerReserveW.toStringAsFixed(1)} W',
              color: _powerReserveWColor(result.continuousPowerReserveW),
            ),
            ResultCard(
              title: 'Maximum Power Reserve',
              value: '${result.maximumPowerReserveW.toStringAsFixed(1)} W',
              color: _powerReserveWColor(result.maximumPowerReserveW),
            ),
            ResultCard(
              title: 'Propulsion System Status',
              value: result.propulsionSystemStatus,
              color: result.isPropulsionSystemSafe ? Colors.green : Colors.red,
            ),
          ]),
        ],
      ),
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
    return ResultSection(
      title: 'Energy & Battery System',
      icon: Icons.battery_charging_full,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGrid([
            ResultCard(
              title: 'Estimated Flight Time',
              value: '${result.estimatedFlightTime.toStringAsFixed(1)} min',
            ),
            ResultCard(
              title: 'Average Battery Current',
              value: '${result.averageBatteryCurrentA.toStringAsFixed(2)} A',
            ),
            ResultCard(
              title: 'Peak Battery Current',
              value: '${result.peakBatteryCurrentA.toStringAsFixed(2)} A',
            ),
            ResultCard(
              title: 'Nominal Battery Energy',
              value: '${result.nominalBatteryEnergyWh.toStringAsFixed(1)} Wh',
            ),
            ResultCard(
              title: 'Real Usable Energy',
              value: '${result.usableBatteryEnergyWh.toStringAsFixed(1)} Wh',
            ),
            ResultCard(
              title: 'Battery Load Efficiency',
              value:
                  '${(result.batteryLoadEfficiency * 100).toStringAsFixed(1)}%',
              color: _batteryEfficiencyColor(result.batteryLoadEfficiency),
            ),
          ]),
          const SizedBox(height: 24),
          const Text(
            'Cell & Pack Voltage',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF102A43),
            ),
          ),
          const SizedBox(height: 14),
          _buildGrid([
            ResultCard(
              title: 'Full Pack Voltage',
              value: '${result.fullPackVoltageV.toStringAsFixed(2)} V',
            ),
            ResultCard(
              title: 'Nominal Pack Voltage',
              value: '${result.nominalPackVoltageV.toStringAsFixed(2)} V',
            ),
            ResultCard(
              title: 'Minimum Safe Pack Voltage',
              value: '${result.minimumSafePackVoltageV.toStringAsFixed(2)} V',
            ),
            ResultCard(
              title: 'Pack Internal Resistance',
              value:
                  '${(result.packInternalResistanceOhm * 1000).toStringAsFixed(1)} mΩ',
            ),
          ]),
          const SizedBox(height: 24),
          const Text(
            'Loaded Voltage & C-rate',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF102A43),
            ),
          ),
          const SizedBox(height: 14),
          _buildGrid([
            ResultCard(
              title: 'Average Loaded Voltage',
              value: '${result.averageLoadedVoltageV.toStringAsFixed(2)} V',
              color: _loadedVoltageColor(result.averageLoadedVoltageV),
            ),
            ResultCard(
              title: 'Peak Loaded Voltage',
              value: '${result.peakLoadedVoltageV.toStringAsFixed(2)} V',
              color: _loadedVoltageColor(result.peakLoadedVoltageV),
            ),
            ResultCard(
              title: 'Average Voltage Sag',
              value: '${result.averageVoltageSagV.toStringAsFixed(2)} V',
              color: _voltageSagColor(
                result.averageVoltageSagV,
                result.nominalPackVoltageV,
              ),
            ),
            ResultCard(
              title: 'Peak Voltage Sag',
              value: '${result.peakVoltageSagV.toStringAsFixed(2)} V',
              color: _voltageSagColor(
                result.peakVoltageSagV,
                result.nominalPackVoltageV,
              ),
            ),
            ResultCard(
              title: 'Average C-rate',
              value: '${result.averageCRate.toStringAsFixed(2)} C',
              color: _cRateColor(result.averageCRate),
            ),
            ResultCard(
              title: 'Peak C-rate',
              value: '${result.peakCRate.toStringAsFixed(2)} C',
              color: _cRateColor(result.peakCRate),
            ),
            ResultCard(
              title: 'Battery System Status',
              value: result.batterySystemStatus,
              color: result.isBatterySystemSafe ? Colors.green : Colors.red,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildBatteryRecommendationSection() {
    final recommendationColor = result.isBatteryRecommendationSafe
        ? Colors.green
        : Colors.red;

    return ResultSection(
      title: 'Battery Safety Recommendation',
      icon: Icons.battery_alert_outlined,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: recommendationColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: recommendationColor.withValues(alpha: 0.30),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.batteryRecommendationTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: recommendationColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              result.batteryRecommendationMessage,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Color(0xFF486581),
              ),
            ),
            const SizedBox(height: 16),
            _buildGrid([
              ResultCard(
                title: 'Battery Score',
                value: '${result.batteryScore}/100',
                color: _scoreColor(result.batteryScore),
              ),
              ResultCard(
                title: 'Battery Score Status',
                value: result.batteryScoreStatus,
                color: _scoreColor(result.batteryScore),
              ),
            ]),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: recommendationColor.withValues(alpha: 0.28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Battery Safety',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF627D98),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.batterySafetyMessage,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.45,
                      fontWeight: FontWeight.w700,
                      color: result.isBatterySystemSafe
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

  String _formatMetersWithoutNegativeZero(double value) {
    final normalizedValue = value.abs() < 0.5 ? 0.0 : value;
    return '${normalizedValue.toStringAsFixed(0)} m';
  }

  String _formatSignedMetersWithoutNegativeZero(double value) {
    final normalizedValue = value.abs() < 0.5 ? 0.0 : value;
    final sign = normalizedValue > 0 ? '+' : '';
    return '$sign${normalizedValue.toStringAsFixed(0)} m';
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

  Color _densityAltitudeColor(double differenceM) {
    if (differenceM <= 300) {
      return Colors.green;
    }

    if (differenceM <= 1000) {
      return Colors.orange;
    }

    return Colors.red;
  }

  Color _temperatureDeviationColor(double deviationC) {
    final absoluteDeviation = deviationC.abs();

    if (absoluteDeviation <= 5) {
      return Colors.green;
    }

    if (absoluteDeviation <= 15) {
      return Colors.orange;
    }

    return Colors.red;
  }

  Color _pressureDeviationColor(double deviationPercent) {
    final absoluteDeviation = deviationPercent.abs();

    if (absoluteDeviation <= 3) {
      return Colors.green;
    }

    if (absoluteDeviation <= 8) {
      return Colors.orange;
    }

    return Colors.red;
  }

  Color _densityDeviationColor(double deviationPercent) {
    if (deviationPercent >= -3) {
      return Colors.green;
    }

    if (deviationPercent >= -10) {
      return Colors.orange;
    }

    return Colors.red;
  }

  Color _atmosphereStatusColor(bool isSupported, String status) {
    if (!isSupported) {
      return Colors.red;
    }

    final normalizedStatus = status.toLowerCase();

    if (normalizedStatus.contains('normal') ||
        normalizedStatus.contains('uygun') ||
        normalizedStatus.contains('standart')) {
      return Colors.green;
    }

    if (normalizedStatus.contains('kritik') ||
        normalizedStatus.contains('yüksek risk') ||
        normalizedStatus.contains('desteklenmiyor')) {
      return Colors.red;
    }

    return Colors.orange;
  }

  Color _windIntensityColor(String status) {
    final normalizedStatus = status.toLowerCase();

    if (normalizedStatus.contains('sakin') ||
        normalizedStatus.contains('hafif')) {
      return Colors.green;
    }

    if (normalizedStatus.contains('orta')) {
      return Colors.orange;
    }

    return Colors.red;
  }

  Color _crosswindColor(double crosswindMs) {
    if (crosswindMs <= 3) {
      return Colors.green;
    }

    if (crosswindMs <= 8) {
      return Colors.orange;
    }

    return Colors.red;
  }

  Color _effectiveAirspeedColor(
    double commandedAirspeedMs,
    double effectiveAirspeedMs,
  ) {
    if (commandedAirspeedMs <= 0) {
      return const Color(0xFF627D98);
    }

    final differenceRatio =
        (effectiveAirspeedMs - commandedAirspeedMs).abs() / commandedAirspeedMs;

    if (differenceRatio <= 0.10) {
      return Colors.green;
    }

    if (differenceRatio <= 0.30) {
      return Colors.orange;
    }

    return Colors.red;
  }

  Color _windSafetyColor(String status) {
    final normalizedStatus = status.toLowerCase();

    if (normalizedStatus.contains('güvenli')) {
      return Colors.green;
    }

    if (normalizedStatus.contains('dikkat') ||
        normalizedStatus.contains('sınırlı')) {
      return Colors.orange;
    }

    return Colors.red;
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

  Color _liftToDragColor(double liftToDragRatio) {
    if (liftToDragRatio >= 12) {
      return Colors.green;
    }

    if (liftToDragRatio >= 8) {
      return Colors.orange;
    }

    return Colors.red;
  }

  Color _liftCoefficientColor(double usageRatio) {
    if (usageRatio <= 0.70) {
      return Colors.green;
    }

    if (usageRatio <= 0.90) {
      return Colors.orange;
    }

    return Colors.red;
  }

  Color _batteryEfficiencyColor(double efficiency) {
    if (efficiency >= 0.95) {
      return Colors.green;
    }

    if (efficiency >= 0.85) {
      return Colors.orange;
    }

    return Colors.red;
  }

  Color _loadedVoltageColor(double loadedVoltageV) {
    if (loadedVoltageV >= result.minimumSafePackVoltageV) {
      return Colors.green;
    }

    return Colors.red;
  }

  Color _voltageSagColor(double voltageSagV, double nominalVoltageV) {
    if (nominalVoltageV <= 0) {
      return Colors.red;
    }

    final sagRatio = voltageSagV / nominalVoltageV;

    if (sagRatio <= 0.05) {
      return Colors.green;
    }

    if (sagRatio <= 0.10) {
      return Colors.orange;
    }

    return Colors.red;
  }

  Color _cRateColor(double cRate) {
    if (cRate <= 5.0) {
      return Colors.green;
    }

    if (cRate <= 15.0) {
      return Colors.orange;
    }

    return Colors.red;
  }

  Color _propulsionEfficiencyColor(double efficiency) {
    if (efficiency >= 0.60) {
      return Colors.green;
    }

    if (efficiency >= 0.45) {
      return Colors.orange;
    }

    return Colors.red;
  }

  Color _motorLoadColor(double loadRatio) {
    if (loadRatio <= 0.70) {
      return Colors.green;
    }

    if (loadRatio <= 0.90) {
      return Colors.orange;
    }

    return Colors.red;
  }

  Color _powerReserveWColor(double reserveW) {
    if (reserveW > 0) {
      return Colors.green;
    }

    if (reserveW == 0) {
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
}
