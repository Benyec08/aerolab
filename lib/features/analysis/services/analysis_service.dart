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

class AnalysisService {
  final AirDensityService airDensityService = AirDensityService();
  final LiftService liftService = LiftService();
  final DragService dragService = DragService();
  final StallService stallService = StallService();
  final FlightTimeService flightTimeService = FlightTimeService();
  final RiskService riskService = RiskService();

  AnalysisResult analyze(
    Aircraft aircraft,
    Environment environment,
  ) {
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

    final double wingLoading = aircraft.weightKg / aircraft.wingAreaM2;

    final double stallSpeed = stallService.calculate(
      weightKg: aircraft.weightKg,
      wingAreaM2: aircraft.wingAreaM2,
      airDensity: airDensity,
      clMax: clMax,
    );

    final double thrustToWeight =
        aircraft.motorPowerW / (aircraft.weightKg * 100);

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
      riskScore: riskScore,
      status: status,
      recommendation: recommendation,
    );
  }
}