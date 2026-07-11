/*
====================================================================

Project
AeroLab

Module
Aerodynamics Engine

File
analysis_service.dart

Description

Bu servis AeroLab analiz motorunun ana yöneticisidir.

Tek başına hesaplama yapmaz.
Diğer servisleri çağırarak analiz sonucunu oluşturur.

====================================================================
*/

import '../models/aircraft.dart';
import '../models/environment.dart';
import '../models/analysis_result.dart';

import 'air_density_service.dart';
import 'lift_service.dart';
import 'drag_service.dart';
import 'stall_service.dart';
import 'flight_time_service.dart';
import 'risk_service.dart';
import 'aspect_ratio_service.dart';
import 'wing_loading_service.dart';
import 'power_to_weight_service.dart';
import 'thrust_service.dart';
import 'recommendation_service.dart';
import 'score_service.dart';
import 'mission_power_service.dart';

class AnalysisService {
  final _aspectRatioService = AspectRatioService();
  final _wingLoadingService = WingLoadingService();
  final _powerToWeightService = PowerToWeightService();
  final _thrustService = ThrustService();
  final AirDensityService airDensityService = AirDensityService();
  final LiftService liftService = LiftService();
  final DragService dragService = DragService();
  final StallService stallService = StallService();
  final FlightTimeService flightTimeService = FlightTimeService();
  final RiskService riskService = RiskService();
  final _recommendationService = RecommendationService();
  final _scoreService = ScoreService();
  final _missionPowerService = MissionPowerService();

  AnalysisResult analyze(Aircraft aircraft, Environment environment) {
    const double flightSpeedMs = 15;
    const double liftCoefficient = 1.1;
    const double dragCoefficient = 0.045;
    const double clMax = 1.4;

    final bool hasFixedWingAerodynamics =
        aircraft.type == 'Sabit Kanat' ||
        (aircraft.type == 'VTOL' &&
            aircraft.wingAreaM2 > 0 &&
            aircraft.wingSpanM > 0);

    final double airDensity = airDensityService.calculateWithAltitude(
      altitudeM: environment.altitudeM,
      temperatureC: environment.temperatureC,
    );

    final double lift = hasFixedWingAerodynamics
        ? liftService.calculate(
            airDensity: airDensity,
            velocityMs: flightSpeedMs,
            wingAreaM2: aircraft.wingAreaM2,
            liftCoefficient: liftCoefficient,
          )
        : 0;

    final double drag = hasFixedWingAerodynamics
        ? dragService.calculate(
            airDensity: airDensity,
            velocityMs: flightSpeedMs,
            wingAreaM2: aircraft.wingAreaM2,
            dragCoefficient: dragCoefficient,
          )
        : 0;

    final double aspectRatio = hasFixedWingAerodynamics
        ? _aspectRatioService.calculate(
            wingSpanM: aircraft.wingSpanM,
            wingAreaM2: aircraft.wingAreaM2,
          )
        : 0;

    final double wingLoading = hasFixedWingAerodynamics
        ? _wingLoadingService.calculate(
            weightKg: aircraft.weightKg,
            wingAreaM2: aircraft.wingAreaM2,
          )
        : 0;

    final String wingLoadingStatus = hasFixedWingAerodynamics
        ? _wingLoadingService.evaluate(wingLoading)
        : 'Uygulanamaz';

    final double powerToWeight = _powerToWeightService.calculate(
      motorPowerW: aircraft.motorPowerW,
      weightKg: aircraft.weightKg,
    );

    final String powerToWeightStatus = _powerToWeightService.evaluate(
      powerToWeight,
    );

    final double estimatedThrust = _thrustService.calculate(
      totalElectricalPowerW: aircraft.motorPowerW,
      motorCount: aircraft.motorCount,
      propellerDiameterInch: aircraft.propellerDiameterInch,
      airDensityKgM3: airDensity,
    );

    final double thrustToWeight = _thrustService.thrustToWeight(
      thrustN: estimatedThrust,
      weightKg: aircraft.weightKg,
    );

    final String thrustToWeightStatus = _thrustService.evaluate(thrustToWeight);

    final double stallSpeed = hasFixedWingAerodynamics
        ? stallService.calculate(
            weightKg: aircraft.weightKg,
            wingAreaM2: aircraft.wingAreaM2,
            airDensity: airDensity,
            clMax: clMax,
          )
        : 0;

    final MissionPowerResult missionPowerResult = _missionPowerService
        .calculate(
          aircraft: aircraft,
          airDensityKgM3: airDensity,
          flightSpeedMs: flightSpeedMs,
          dragN: drag,
        );

    final FlightTimeResult flightTimeResult = flightTimeService
        .calculateDetailed(
          batteryCapacityMah: aircraft.batteryCapacityMah,
          batteryVoltageV: aircraft.batteryVoltageV,
          averagePowerConsumptionW: missionPowerResult.averageMissionPowerW,
        );

    final double estimatedFlightTime =
        flightTimeResult.estimatedFlightTimeMinutes;

    final int riskScore = riskService.calculateRiskScore(
      windSpeedKmh: environment.windSpeedKmh,
      thrustToWeight: thrustToWeight,
      evaluateFixedWingAerodynamics: hasFixedWingAerodynamics,
      wingLoading: wingLoading,
      flightSpeedMs: flightSpeedMs,
      stallSpeedMs: stallSpeed,
    );

    final String status = riskService.getStatus(riskScore);

    final String recommendation = _recommendationService.generate(
      aircraftType: aircraft.type,
      hasFixedWingAerodynamics: hasFixedWingAerodynamics,
      wingLoading: wingLoading,
      stallSpeed: stallSpeed,
      powerToWeight: powerToWeight,
      thrustToWeight: thrustToWeight,
    );

    final int? aerodynamicScore = _scoreService.aerodynamicScore(
      isApplicable: hasFixedWingAerodynamics,
      wingLoading: wingLoading,
      stallSpeed: stallSpeed,
    );

    final int propulsionScore = _scoreService.propulsionScore(
      powerToWeight: powerToWeight,
      thrustToWeight: thrustToWeight,
    );

    final int energyScore = _scoreService.energyScore(
      flightTimeMinutes: estimatedFlightTime,
    );

    final int overallScore = _scoreService.overallScore(
      aerodynamicScore: aerodynamicScore,
      propulsionScore: propulsionScore,
      energyScore: energyScore,
    );

    return AnalysisResult(
      aircraftType: aircraft.type,
      hasFixedWingAerodynamics: hasFixedWingAerodynamics,
      liftN: lift,
      dragN: drag,
      wingLoading: wingLoading,
      stallSpeed: stallSpeed,
      thrustToWeight: thrustToWeight,
      estimatedFlightTime: estimatedFlightTime,
      aspectRatio: aspectRatio,
      powerToWeight: powerToWeight,
      estimatedThrustN: estimatedThrust,
      missionPowerModelName: missionPowerResult.modelName,
      hoverPowerW: missionPowerResult.hoverPowerW,
      cruisePowerW: missionPowerResult.cruisePowerW,
      averageMissionPowerW: missionPowerResult.averageMissionPowerW,
      peakMissionPowerW: missionPowerResult.peakMissionPowerW,
      peakPowerUsageRatio: missionPowerResult.peakPowerUsageRatio,
      installedPowerReserveW: missionPowerResult.installedPowerReserveW,
      installedPowerReservePercent:
          missionPowerResult.installedPowerReservePercent,
      hasSufficientInstalledPower:
          missionPowerResult.hasSufficientInstalledPower,
      averageBatteryCurrentA: flightTimeResult.estimatedAverageCurrentA,
      nominalBatteryEnergyWh: flightTimeResult.nominalEnergyWh,
      usableBatteryEnergyWh: flightTimeResult.effectiveEnergyWh,
      wingLoadingStatus: wingLoadingStatus,
      powerToWeightStatus: powerToWeightStatus,
      thrustToWeightStatus: thrustToWeightStatus,
      aerodynamicScore: aerodynamicScore,
      propulsionScore: propulsionScore,
      energyScore: energyScore,
      overallScore: overallScore,
      riskScore: riskScore,
      status: status,
      recommendation: recommendation,
    );
  }
}
