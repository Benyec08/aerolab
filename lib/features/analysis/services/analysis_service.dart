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
import 'aerodynamic_performance_service.dart';
import 'propulsion_system_service.dart';

class AnalysisService {
  final _aspectRatioService = AspectRatioService();
  final _wingLoadingService = WingLoadingService();
  final _powerToWeightService = PowerToWeightService();
  final _thrustService = ThrustService();
  final AirDensityService airDensityService = AirDensityService();
  final StallService stallService = StallService();
  final FlightTimeService flightTimeService = FlightTimeService();
  final RiskService riskService = RiskService();
  final _recommendationService = RecommendationService();
  final _scoreService = ScoreService();
  final _missionPowerService = MissionPowerService();
  final _aerodynamicPerformanceService = AerodynamicPerformanceService();
  final _propulsionSystemService = PropulsionSystemService();

  AnalysisResult analyze(Aircraft aircraft, Environment environment) {
    final bool hasFixedWingAerodynamics =
        aircraft.type == 'Sabit Kanat' ||
        (aircraft.type == 'VTOL' &&
            aircraft.wingAreaM2 > 0 &&
            aircraft.wingSpanM > 0);

    final double cruiseSpeedMs = aircraft.cruiseSpeedMs;

    final double airDensity = airDensityService.calculateWithAltitude(
      altitudeM: environment.altitudeM,
      temperatureC: environment.temperatureC,
    );

    final double aspectRatio = hasFixedWingAerodynamics
        ? _aspectRatioService.calculate(
            wingSpanM: aircraft.wingSpanM,
            wingAreaM2: aircraft.wingAreaM2,
          )
        : 0;

    AerodynamicPerformanceResult? aerodynamicPerformance;

    if (hasFixedWingAerodynamics) {
      aerodynamicPerformance = _aerodynamicPerformanceService.calculateCruise(
        weightKg: aircraft.weightKg,
        airDensityKgM3: airDensity,
        cruiseSpeedMs: cruiseSpeedMs,
        wingAreaM2: aircraft.wingAreaM2,
        aspectRatio: aspectRatio,
        zeroLiftDragCoefficient: aircraft.zeroLiftDragCoefficient,
        maxLiftCoefficient: aircraft.maxLiftCoefficient,
        oswaldEfficiencyFactor: aircraft.oswaldEfficiencyFactor,
      );
    }

    final double lift = aerodynamicPerformance?.liftN ?? 0;
    final double drag = aerodynamicPerformance?.dragN ?? 0;

    final double dynamicPressurePa =
        aerodynamicPerformance?.dynamicPressurePa ?? 0;

    final double requiredLiftCoefficient =
        aerodynamicPerformance?.requiredLiftCoefficient ?? 0;

    final double dragCoefficient = aerodynamicPerformance?.dragCoefficient ?? 0;

    final double inducedDragFactor =
        aerodynamicPerformance?.inducedDragFactor ?? 0;

    final double liftToDragRatio = aerodynamicPerformance?.liftToDragRatio ?? 0;

    final double liftCoefficientUsageRatio =
        aerodynamicPerformance?.stallMarginRatio ?? 0;

    final bool isCruiseAerodynamicallyValid =
        aerodynamicPerformance?.isBelowMaximumLiftCoefficient ?? true;

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
            clMax: aircraft.maxLiftCoefficient,
          )
        : 0;

    final MissionPowerResult missionPowerResult = _missionPowerService
        .calculate(
          aircraft: aircraft,
          airDensityKgM3: airDensity,
          flightSpeedMs: cruiseSpeedMs,
          dragN: drag,
          motorEfficiency: aircraft.motorEfficiency,
          propellerEfficiency: MissionPowerService.defaultPropellerEfficiency,
        );

    // MissionPowerService motor girişindeki elektriksel gücü hesaplar.
    // Bataryadan çekilen gerçek gücü bulmak için ESC kaybı da eklenir.
    final double batteryHoverPowerW =
        missionPowerResult.hoverPowerW / aircraft.escEfficiency;

    final double batteryCruisePowerW =
        missionPowerResult.cruisePowerW / aircraft.escEfficiency;

    final double batteryAverageMissionPowerW =
        missionPowerResult.averageMissionPowerW / aircraft.escEfficiency;

    final double batteryPeakMissionPowerW =
        missionPowerResult.peakMissionPowerW / aircraft.escEfficiency;

    final double peakPowerUsageRatio =
        batteryPeakMissionPowerW / aircraft.motorPowerW;

    final double installedPowerReserveW =
        aircraft.motorPowerW - batteryPeakMissionPowerW;

    final double installedPowerReservePercent =
        installedPowerReserveW / aircraft.motorPowerW * 100;

    final bool hasSufficientInstalledPower =
        batteryPeakMissionPowerW <= aircraft.motorPowerW;

    final propulsionSystemResult = _propulsionSystemService.calculate(
      averageMissionPowerW: batteryAverageMissionPowerW,
      peakMissionPowerW: batteryPeakMissionPowerW,
      escEfficiency: aircraft.escEfficiency,
      motorEfficiency: aircraft.motorEfficiency,
      propellerEfficiency: MissionPowerService.defaultPropellerEfficiency,
      continuousMotorPowerW: aircraft.continuousMotorPowerW,
      maximumMotorPowerW: aircraft.maximumMotorPowerW,
    );

    final FlightTimeResult flightTimeResult = flightTimeService
        .calculateDetailed(
          batteryCapacityMah: aircraft.batteryCapacityMah,
          batteryVoltageV: aircraft.batteryVoltageV,
          averagePowerConsumptionW: batteryAverageMissionPowerW,
        );

    final double estimatedFlightTime =
        flightTimeResult.estimatedFlightTimeMinutes;

    final int riskScore = riskService.calculateRiskScore(
      windSpeedKmh: environment.windSpeedKmh,
      thrustToWeight: thrustToWeight,
      evaluateFixedWingAerodynamics: hasFixedWingAerodynamics,
      wingLoading: wingLoading,
      flightSpeedMs: cruiseSpeedMs,
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
      hoverPowerW: batteryHoverPowerW,
      cruisePowerW: batteryCruisePowerW,
      averageMissionPowerW: batteryAverageMissionPowerW,
      peakMissionPowerW: batteryPeakMissionPowerW,
      peakPowerUsageRatio: peakPowerUsageRatio,
      installedPowerReserveW: installedPowerReserveW,
      installedPowerReservePercent: installedPowerReservePercent,
      hasSufficientInstalledPower: hasSufficientInstalledPower,
      averageBatteryCurrentA: flightTimeResult.estimatedAverageCurrentA,
      nominalBatteryEnergyWh: flightTimeResult.nominalEnergyWh,
      usableBatteryEnergyWh: flightTimeResult.effectiveEnergyWh,
      cruiseSpeedMs: cruiseSpeedMs,
      dynamicPressurePa: dynamicPressurePa,
      requiredLiftCoefficient: requiredLiftCoefficient,
      dragCoefficient: dragCoefficient,
      inducedDragFactor: inducedDragFactor,
      liftToDragRatio: liftToDragRatio,
      liftCoefficientUsageRatio: liftCoefficientUsageRatio,
      isCruiseAerodynamicallyValid: isCruiseAerodynamicallyValid,
      escOutputPowerW: propulsionSystemResult.averagePowerChain.escOutputPowerW,
      motorShaftPowerW:
          propulsionSystemResult.averagePowerChain.motorShaftPowerW,
      usefulPropulsivePowerW:
          propulsionSystemResult.averagePowerChain.usefulPropulsivePowerW,
      totalPropulsionEfficiency:
          propulsionSystemResult.totalPropulsionEfficiency,
      averageContinuousLoadRatio:
          propulsionSystemResult.loadAnalysis.averageContinuousLoadRatio,
      peakMaximumLoadRatio:
          propulsionSystemResult.loadAnalysis.peakMaximumLoadRatio,
      continuousPowerReserveW:
          propulsionSystemResult.loadAnalysis.continuousPowerReserveW,
      maximumPowerReserveW:
          propulsionSystemResult.loadAnalysis.maximumPowerReserveW,
      isPropulsionSystemSafe: propulsionSystemResult.status.isSafe,
      propulsionSystemStatus: propulsionSystemResult.status.label,
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
