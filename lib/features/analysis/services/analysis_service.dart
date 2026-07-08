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

  AnalysisResult analyze(Aircraft aircraft, Environment environment) {
    const double flightSpeedMs = 15;
    const double liftCoefficient = 1.1;
    const double dragCoefficient = 0.045;
    const double clMax = 1.4;

    final double airDensity = airDensityService.calculate(
      temperatureC: environment.temperatureC,
      pressureHpa: environment.pressureHpa,
    );

    final double lift = liftService.calculate(
      airDensity: airDensity,
      velocityMs: flightSpeedMs,
      wingAreaM2: aircraft.wingAreaM2,
      liftCoefficient: liftCoefficient,
    );

    final double drag = dragService.calculate(
      airDensity: airDensity,
      velocityMs: flightSpeedMs,
      wingAreaM2: aircraft.wingAreaM2,
      dragCoefficient: dragCoefficient,
    );

    final double aspectRatio = _aspectRatioService.calculate(
      wingSpanM: aircraft.wingSpanM,
      wingAreaM2: aircraft.wingAreaM2,
    );

    final double wingLoading = _wingLoadingService.calculate(
      weightKg: aircraft.weightKg,
      wingAreaM2: aircraft.wingAreaM2,
    );

    final String wingLoadingStatus = _wingLoadingService.evaluate(wingLoading);

    final double powerToWeight = _powerToWeightService.calculate(
      motorPowerW: aircraft.motorPowerW,
      weightKg: aircraft.weightKg,
    );

    final String powerToWeightStatus = _powerToWeightService.evaluate(
      powerToWeight,
    );

    final double estimatedThrust = _thrustService.calculate(
      motorPowerW: aircraft.motorPowerW,
      motorCount: aircraft.motorCount,
    );

    final double thrustToWeight = _thrustService.thrustToWeight(
      thrustN: estimatedThrust,
      weightKg: aircraft.weightKg,
    );

    final String thrustToWeightStatus = _thrustService.evaluate(thrustToWeight);

    final double stallSpeed = stallService.calculate(
      weightKg: aircraft.weightKg,
      wingAreaM2: aircraft.wingAreaM2,
      airDensity: airDensity,
      clMax: clMax,
    );

    final double estimatedFlightTime = flightTimeService.calculateMinutes(
      batteryCapacityMah: aircraft.batteryCapacityMah,
      batteryVoltageV: aircraft.batteryVoltageV,
      averagePowerConsumptionW: aircraft.motorPowerW * 0.65,
    );

    final int riskScore = riskService.calculateRiskScore(
      windSpeedKmh: environment.windSpeedKmh,
      thrustToWeight: thrustToWeight,
      wingLoading: wingLoading,
      flightSpeedMs: flightSpeedMs,
      stallSpeedMs: stallSpeed,
    );

    final String status = riskService.getStatus(riskScore);

    final String recommendation = riskService.getRecommendation(
      riskScore: riskScore,
      windSpeedKmh: environment.windSpeedKmh,
      flightSpeedMs: flightSpeedMs,
      stallSpeedMs: stallSpeed,
    );

    return AnalysisResult(
      liftN: lift,
      dragN: drag,
      wingLoading: wingLoading,
      stallSpeed: stallSpeed,
      thrustToWeight: thrustToWeight,
      estimatedFlightTime: estimatedFlightTime,
      aspectRatio: aspectRatio,
      powerToWeight: powerToWeight,
      estimatedThrustN: estimatedThrust,
      wingLoadingStatus: wingLoadingStatus,
      powerToWeightStatus: powerToWeightStatus,
      thrustToWeightStatus: thrustToWeightStatus,
      riskScore: riskScore,
      status: status,
      recommendation: recommendation,
    );
  }
}
