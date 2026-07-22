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
import '../models/climb_performance_result.dart';
import '../models/endurance_range_result.dart';
import '../models/glide_performance_result.dart';
import '../models/stability_result.dart';
import '../models/flight_envelope_result.dart';
import '../../components/data/motor_propeller/motor_propeller_data_catalog.dart';
import '../../components/models/motor_propeller_combination.dart';

import 'air_density_service.dart';
import 'stall_service.dart';
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
import 'battery_recommendation_service.dart';
import 'battery_score_service.dart';
import 'battery_system_service.dart';
import 'atmosphere_system_service.dart';
import 'wind_system_service.dart';
import 'climb_performance_service.dart';
import 'endurance_range_service.dart';
import 'glide_performance_service.dart';
import 'stability_service.dart';
import 'flight_envelope_service.dart';

class AnalysisService {
  final _aspectRatioService = AspectRatioService();
  final _wingLoadingService = WingLoadingService();
  final _powerToWeightService = PowerToWeightService();
  final _thrustService = ThrustService();
  final AirDensityService airDensityService = AirDensityService();
  final StallService stallService = StallService();
  final RiskService riskService = RiskService();
  final _recommendationService = RecommendationService();
  final _scoreService = ScoreService();
  final _missionPowerService = MissionPowerService();
  final _aerodynamicPerformanceService = AerodynamicPerformanceService();
  final _propulsionSystemService = PropulsionSystemService();
  final _batterySystemService = BatterySystemService();
  final _batteryScoreService = BatteryScoreService();
  final _batteryRecommendationService = BatteryRecommendationService();
  final _atmosphereSystemService = AtmosphereSystemService();
  final _windSystemService = const WindSystemService();
  final _climbPerformanceService = const ClimbPerformanceService();
  final _enduranceRangeService = const EnduranceRangeService();
  final _glidePerformanceService = const GlidePerformanceService();
  final _stabilityService = const StabilityService();
  final _flightEnvelopeService = const FlightEnvelopeService();

  AnalysisResult analyze(Aircraft aircraft, Environment environment) {
    final bool hasFixedWingAerodynamics =
        aircraft.type == 'Sabit Kanat' ||
        (aircraft.type == 'VTOL' &&
            aircraft.wingAreaM2 > 0 &&
            aircraft.wingSpanM > 0);

    final double cruiseSpeedMs = aircraft.cruiseSpeedMs;

    final windSystemResult = _windSystemService.calculate(
      windSpeedKmh: environment.windSpeedKmh,
      windDirection: environment.windDirection,
      commandedAirspeedMs: cruiseSpeedMs,
    );

    // Sprint 13B: Sabit kanat ve kanatlı VTOL aerodinamik hesaplarında
    // rüzgâr bileşenleriyle düzeltilmiş etkin hava hızı kullanılır.
    final double aerodynamicAirspeedMs = hasFixedWingAerodynamics
        ? windSystemResult.effectiveAirspeedMs
        : cruiseSpeedMs;

    final atmosphereSystemResult = _atmosphereSystemService.calculate(
      altitudeM: environment.altitudeM,
      temperatureC: environment.temperatureC,
      pressureHpa: environment.pressureHpa,
      relativeHumidityPercent: environment.humidityPercent,
    );

    // Sprint 13A: Tüm aerodinamik ve itki hesaplarında gerçek ortam
    // basıncı, sıcaklığı ve nemiyle hesaplanan nemli hava yoğunluğu kullanılır.
    final double airDensity = atmosphereSystemResult.humidAirDensityKgM3;

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
        cruiseSpeedMs: aerodynamicAirspeedMs,
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

    // Sprint 14E: Seçilen gerçek motor-pervane test tablosu, manuel
    // mühendislik hesaplarını değiştirmeden ek bir doğrulama katmanı olarak
    // değerlendirilir.
    final componentAnalysis = _analyzeComponentSelection(aircraft);

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
          flightSpeedMs: aerodynamicAirspeedMs,
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

    final double availableClimbPropulsivePowerW =
        aircraft.maximumMotorPowerW *
        aircraft.escEfficiency *
        aircraft.motorEfficiency *
        MissionPowerService.defaultPropellerEfficiency;

    final double requiredLevelFlightPowerW = hasFixedWingAerodynamics
        ? drag * aerodynamicAirspeedMs
        : 0.0;

    final ClimbPerformanceResult climbPerformanceResult =
        hasFixedWingAerodynamics
        ? _climbPerformanceService.calculate(
            massKg: aircraft.weightKg,
            availablePropulsivePowerW: availableClimbPropulsivePowerW,
            requiredLevelFlightPowerW: requiredLevelFlightPowerW,
            flightSpeedMs: aerodynamicAirspeedMs,
          )
        : const ClimbPerformanceResult.notApplicable(
            message:
                'Tırmanma performansı yalnızca sabit kanat veya '
                'kanatlı VTOL araçlar için hesaplanır.',
          );

    final GlidePerformanceResult glidePerformanceResult =
        hasFixedWingAerodynamics
        ? _glidePerformanceService.calculate(
            massKg: aircraft.weightKg,
            airDensityKgM3: airDensity,
            wingAreaM2: aircraft.wingAreaM2,
            aspectRatio: aspectRatio,
            zeroLiftDragCoefficient: aircraft.zeroLiftDragCoefficient,
            oswaldEfficiencyFactor: aircraft.oswaldEfficiencyFactor,
          )
        : const GlidePerformanceResult.notApplicable(
            message:
                'Süzülme performansı yalnızca sabit kanat veya '
                'kanatlı VTOL araçlar için hesaplanır.',
          );

    final StabilityResult stabilityResult =
        hasFixedWingAerodynamics && aircraft.hasStabilityInputs
        ? _stabilityService.calculate(
            massStations: aircraft.massStations
                .map(
                  (station) => MassStation(
                    name: station.name,
                    massKg: station.massKg,
                    armFromDatumM: station.armFromDatumM,
                  ),
                )
                .toList(growable: false),
            meanAerodynamicChordM: aircraft.meanAerodynamicChordM,
            macLeadingEdgeFromDatumM: aircraft.macLeadingEdgeFromDatumM,
            neutralPointPercentMac: aircraft.neutralPointPercentMac,
            minimumCgPercentMac: aircraft.minimumCgPercentMac,
            maximumCgPercentMac: aircraft.maximumCgPercentMac,
          )
        : StabilityResult.notApplicable(
            message: hasFixedWingAerodynamics
                ? 'CG ve statik marj hesabı için kütle istasyonları, '
                      'MAC ve nötr nokta girdileri tamamlanmalıdır.'
                : 'CG ve statik marj analizi yalnızca sabit kanat veya '
                      'kanatlı VTOL araçlar için hesaplanır.',
          );

    final FlightEnvelopeResult flightEnvelopeResult =
        hasFixedWingAerodynamics && aircraft.hasFlightEnvelopeInputs
        ? _flightEnvelopeService.calculate(
            airDensityKgM3: airDensity,
            stallSpeedMs: stallSpeed,
            cruiseSpeedMs: cruiseSpeedMs,
            maximumOperatingSpeedMs: aircraft.maximumOperatingSpeedMs,
            positiveLimitLoadFactor: aircraft.positiveLimitLoadFactor,
            negativeLimitLoadFactor: aircraft.negativeLimitLoadFactor,
          )
        : FlightEnvelopeResult.notApplicable(
            message: hasFixedWingAerodynamics
                ? 'Uçuş zarfı için maksimum işletme hızı ve limit '
                      'yük faktörleri geçerli olmalıdır.'
                : 'Uçuş zarfı yalnızca sabit kanat veya kanatlı VTOL '
                      'araçlar için hesaplanır.',
          );

    final batterySystemResult = _batterySystemService.calculate(
      batteryType: aircraft.batteryType,
      cellCount: aircraft.batteryCellCount,
      capacityMah: aircraft.batteryCapacityMah,
      cellInternalResistanceMilliOhm: aircraft.cellInternalResistanceMilliOhm,
      averageMissionPowerW: batteryAverageMissionPowerW,
      peakMissionPowerW: batteryPeakMissionPowerW,
    );

    final double estimatedFlightTime =
        batterySystemResult.estimatedFlightTimeMinutes;

    final EnduranceRangeResult enduranceRangeResult = hasFixedWingAerodynamics
        ? _enduranceRangeService.calculate(
            usableEnergyWh: batterySystemResult.realUsableEnergyWh,
            cruisePowerW: missionPowerResult.cruisePowerW,
            cruiseSpeedMs: cruiseSpeedMs,
            estimatedGroundSpeedMs: windSystemResult.estimatedGroundSpeedMs,
          )
        : const EnduranceRangeResult.notApplicable(
            message:
                'Menzil ve havada kalış analizi yalnızca sabit kanat '
                'veya kanatlı VTOL araçlar için hesaplanır.',
          );

    final batteryScoreResult = _batteryScoreService.calculate(
      batterySystemResult: batterySystemResult,
    );

    final batteryRecommendationResult = _batteryRecommendationService.generate(
      batterySystemResult: batterySystemResult,
      batteryScoreResult: batteryScoreResult,
    );

    final int riskScore = riskService.calculateRiskScore(
      windSpeedKmh: environment.windSpeedKmh,
      thrustToWeight: thrustToWeight,
      evaluateFixedWingAerodynamics: hasFixedWingAerodynamics,
      wingLoading: wingLoading,
      flightSpeedMs: aerodynamicAirspeedMs,
      stallSpeedMs: stallSpeed,
      isAtmosphereWithinSupportedLimits:
          atmosphereSystemResult.isAtmosphereWithinSupportedLimits,
      isWindWithinSupportedLimits: windSystemResult.isWindWithinSupportedLimits,
      hasSufficientInstalledPower: hasSufficientInstalledPower,
      isPropulsionSystemSafe: propulsionSystemResult.status.isSafe,
      isBatterySystemSafe: batterySystemResult.status.isSafe,
      isStabilityApplicable: stabilityResult.isApplicable,
      isCenterOfGravityWithinLimits:
          stabilityResult.isCenterOfGravityWithinLimits,
      isStaticallyStable: stabilityResult.isStaticallyStable,
      staticMarginPercent: stabilityResult.staticMarginPercent,
      isFlightEnvelopeApplicable: flightEnvelopeResult.isApplicable,
      isCruiseInsideEnvelope: flightEnvelopeResult.isCruiseInsideEnvelope,
      usesComponentDatabase: aircraft.usesComponentDatabase,
      isComponentSelectionCompatible: componentAnalysis.isCompatible,
    );

    final String status = riskService.getStatus(riskScore);

    final baseRecommendation = _recommendationService.generate(
      aircraftType: aircraft.type,
      hasFixedWingAerodynamics: hasFixedWingAerodynamics,
      wingLoading: wingLoading,
      stallSpeed: stallSpeed,
      powerToWeight: powerToWeight,
      thrustToWeight: thrustToWeight,
      atmosphereStatus: atmosphereSystemResult.atmosphereStatus,
      isAtmosphereWithinSupportedLimits:
          atmosphereSystemResult.isAtmosphereWithinSupportedLimits,
      densityAltitudeDifferenceM:
          atmosphereSystemResult.densityAltitudeDifferenceM,
      densityDeviationPercent: atmosphereSystemResult.densityDeviationPercent,
      temperatureDeviationC: atmosphereSystemResult.temperatureDeviationC,
      windSafetyStatus: windSystemResult.windSafetyStatus,
      isWindWithinSupportedLimits: windSystemResult.isWindWithinSupportedLimits,
      headwindComponentMs: windSystemResult.headwindComponentMs,
      tailwindComponentMs: windSystemResult.tailwindComponentMs,
      crosswindComponentMs: windSystemResult.crosswindComponentMs,
    );

    final safetyRecommendations = <String>[];

    if (!hasSufficientInstalledPower) {
      safetyRecommendations.add(
        'Kurulu motor gücü tepe görev gücünü karşılamıyor; motor ve görev '
        'güç gereksinimi yeniden boyutlandırılmalıdır.',
      );
    }

    if (!propulsionSystemResult.status.isSafe) {
      safetyRecommendations.add(
        'İtki sistemi güvenli değil: ${propulsionSystemResult.status.label}.',
      );
    }

    if (!batterySystemResult.status.isSafe) {
      safetyRecommendations.add(
        'Batarya sistemi güvenli değil: ${batterySystemResult.status.label}.',
      );
    }

    if (stabilityResult.isApplicable &&
        (!stabilityResult.isCenterOfGravityWithinLimits ||
            !stabilityResult.isStaticallyStable ||
            stabilityResult.staticMarginPercent < 5.0)) {
      safetyRecommendations.add(stabilityResult.message);
    }

    if (flightEnvelopeResult.isApplicable &&
        !flightEnvelopeResult.isCruiseInsideEnvelope) {
      safetyRecommendations.add(flightEnvelopeResult.message);
    }

    if (aircraft.usesComponentDatabase && !componentAnalysis.isCompatible) {
      safetyRecommendations.add(componentAnalysis.compatibilityMessage);
    }

    final String recommendation = safetyRecommendations.isEmpty
        ? baseRecommendation
        : '$baseRecommendation ${safetyRecommendations.join(' ')}';

    final int? aerodynamicScore = _scoreService.aerodynamicScore(
      isApplicable: hasFixedWingAerodynamics,
      wingLoading: wingLoading,
      stallSpeed: stallSpeed,
      densityAltitudeDifferenceM:
          atmosphereSystemResult.densityAltitudeDifferenceM,
      densityDeviationPercent: atmosphereSystemResult.densityDeviationPercent,
      temperatureDeviationC: atmosphereSystemResult.temperatureDeviationC,
      atmosphereStatus: atmosphereSystemResult.atmosphereStatus,
      isAtmosphereWithinSupportedLimits:
          atmosphereSystemResult.isAtmosphereWithinSupportedLimits,
      windSafetyStatus: windSystemResult.windSafetyStatus,
      isWindWithinSupportedLimits: windSystemResult.isWindWithinSupportedLimits,
      headwindComponentMs: windSystemResult.headwindComponentMs,
      tailwindComponentMs: windSystemResult.tailwindComponentMs,
      crosswindComponentMs: windSystemResult.crosswindComponentMs,
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
      batteryScore: batteryScoreResult.score,
      isAtmosphereWithinSupportedLimits:
          atmosphereSystemResult.isAtmosphereWithinSupportedLimits,
      isWindWithinSupportedLimits: windSystemResult.isWindWithinSupportedLimits,
      hasSufficientInstalledPower: hasSufficientInstalledPower,
      isPropulsionSystemSafe: propulsionSystemResult.status.isSafe,
      isBatterySystemSafe: batterySystemResult.status.isSafe,
      isStabilityApplicable: stabilityResult.isApplicable,
      isCenterOfGravityWithinLimits:
          stabilityResult.isCenterOfGravityWithinLimits,
      isStaticallyStable: stabilityResult.isStaticallyStable,
      staticMarginPercent: stabilityResult.staticMarginPercent,
      isFlightEnvelopeApplicable: flightEnvelopeResult.isApplicable,
      isCruiseInsideEnvelope: flightEnvelopeResult.isCruiseInsideEnvelope,
      usesComponentDatabase: aircraft.usesComponentDatabase,
      isComponentSelectionCompatible: componentAnalysis.isCompatible,
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
      averageBatteryCurrentA:
          batterySystemResult.averageElectricalResult.currentA,
      nominalBatteryEnergyWh: batterySystemResult.nominalEnergyWh,
      usableBatteryEnergyWh: batterySystemResult.realUsableEnergyWh,
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
      fullPackVoltageV: batterySystemResult.fullPackVoltageV,
      nominalPackVoltageV: batterySystemResult.nominalPackVoltageV,
      minimumSafePackVoltageV: batterySystemResult.minimumSafePackVoltageV,
      packInternalResistanceOhm: batterySystemResult.packInternalResistanceOhm,
      averageLoadedVoltageV:
          batterySystemResult.averageElectricalResult.loadedVoltageV,
      peakLoadedVoltageV:
          batterySystemResult.peakElectricalResult.loadedVoltageV,
      averageVoltageSagV:
          batterySystemResult.averageElectricalResult.voltageSagV,
      peakVoltageSagV: batterySystemResult.peakElectricalResult.voltageSagV,
      peakBatteryCurrentA: batterySystemResult.peakElectricalResult.currentA,
      averageCRate: batterySystemResult.averageElectricalResult.cRate,
      peakCRate: batterySystemResult.peakElectricalResult.cRate,
      batteryLoadEfficiency: batterySystemResult.loadEfficiencyFactor,
      isBatterySystemSafe: batterySystemResult.status.isSafe,
      batterySystemStatus: batterySystemResult.status.label,
      batteryScore: batteryScoreResult.score,
      batteryScoreStatus: batteryScoreResult.status.label,
      batterySafetyMessage: batteryScoreResult.safetyMessage,
      batteryRecommendationTitle: batteryRecommendationResult.title,
      batteryRecommendationMessage: batteryRecommendationResult.message,
      isBatteryRecommendationSafe: batteryRecommendationResult.severity.isSafe,
      geometricAltitudeM: atmosphereSystemResult.geometricAltitudeM,
      environmentTemperatureC: atmosphereSystemResult.temperatureC,
      environmentPressureHpa: atmosphereSystemResult.pressureHpa,
      relativeHumidityPercent: atmosphereSystemResult.relativeHumidityPercent,
      isaTemperatureC: atmosphereSystemResult.isaTemperatureC,
      isaPressureHpa: atmosphereSystemResult.isaPressureHpa,
      isaDensityKgM3: atmosphereSystemResult.isaDensityKgM3,
      temperatureDeviationC: atmosphereSystemResult.temperatureDeviationC,
      pressureDeviationHpa: atmosphereSystemResult.pressureDeviationHpa,
      pressureDeviationPercent: atmosphereSystemResult.pressureDeviationPercent,
      densityDeviationKgM3: atmosphereSystemResult.densityDeviationKgM3,
      densityDeviationPercent: atmosphereSystemResult.densityDeviationPercent,
      saturationVaporPressureHpa:
          atmosphereSystemResult.saturationVaporPressureHpa,
      vaporPressureHpa: atmosphereSystemResult.vaporPressureHpa,
      dryAirPartialPressureHpa: atmosphereSystemResult.dryAirPartialPressureHpa,
      humidAirDensityKgM3: atmosphereSystemResult.humidAirDensityKgM3,
      densityAltitudeM: atmosphereSystemResult.densityAltitudeM,
      densityAltitudeDifferenceM:
          atmosphereSystemResult.densityAltitudeDifferenceM,
      atmosphereStatus: atmosphereSystemResult.atmosphereStatus,
      isAtmosphereWithinSupportedLimits:
          atmosphereSystemResult.isAtmosphereWithinSupportedLimits,
      windSpeedKmh: windSystemResult.windSpeedKmh,
      windSpeedMs: windSystemResult.windSpeedMs,
      windDirection: windSystemResult.windDirection,
      headwindComponentMs: windSystemResult.headwindComponentMs,
      tailwindComponentMs: windSystemResult.tailwindComponentMs,
      crosswindComponentMs: windSystemResult.crosswindComponentMs,
      crosswindDirection: windSystemResult.crosswindDirection,
      commandedAirspeedMs: windSystemResult.commandedAirspeedMs,
      effectiveAirspeedMs: windSystemResult.effectiveAirspeedMs,
      estimatedGroundSpeedMs: windSystemResult.estimatedGroundSpeedMs,
      windIntensityStatus: windSystemResult.windIntensityStatus,
      windSafetyStatus: windSystemResult.windSafetyStatus,
      isWindWithinSupportedLimits: windSystemResult.isWindWithinSupportedLimits,
      usesComponentDatabase: aircraft.usesComponentDatabase,
      hasRealMotorPropellerData: componentAnalysis.hasRealData,
      motorComponentId: componentAnalysis.motorComponentId,
      propellerComponentId: componentAnalysis.propellerComponentId,
      motorPropellerCombinationId:
          componentAnalysis.motorPropellerCombinationId,
      componentDataSource: componentAnalysis.dataSource,
      componentTestConditions: componentAnalysis.testConditions,
      realTestMaximumThrustPerMotorN: componentAnalysis.maximumThrustPerMotorN,
      realTestTotalMaximumThrustN: componentAnalysis.totalMaximumThrustN,
      realTestMaximumCurrentPerMotorA:
          componentAnalysis.maximumCurrentPerMotorA,
      realTestTotalMaximumCurrentA: componentAnalysis.totalMaximumCurrentA,
      realTestMaximumPowerPerMotorW: componentAnalysis.maximumPowerPerMotorW,
      realTestTotalMaximumPowerW: componentAnalysis.totalMaximumPowerW,
      realTestVoltageV: componentAnalysis.testVoltageV,
      realTestThrustToWeight: componentAnalysis.thrustToWeight,
      componentCompatibilityScore: componentAnalysis.compatibilityScore,
      componentCompatibilityStatus: componentAnalysis.compatibilityStatus,
      componentCompatibilityMessage: componentAnalysis.compatibilityMessage,
      isComponentSelectionCompatible: componentAnalysis.isCompatible,
      climbPerformance: climbPerformanceResult,
      enduranceRange: enduranceRangeResult,
      glidePerformance: glidePerformanceResult,
      stability: stabilityResult,
      flightEnvelope: flightEnvelopeResult,
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

  _ComponentAnalysisSnapshot _analyzeComponentSelection(Aircraft aircraft) {
    final combinationId = aircraft.motorPropellerCombinationId;

    if (combinationId == null || combinationId.trim().isEmpty) {
      return const _ComponentAnalysisSnapshot.manual();
    }

    final combination = MotorPropellerDataCatalog.findById(combinationId);

    if (combination == null) {
      return _ComponentAnalysisSnapshot(
        hasRealData: false,
        motorComponentId: aircraft.motorComponentId,
        propellerComponentId: aircraft.propellerComponentId,
        motorPropellerCombinationId: combinationId,
        dataSource: 'Katalog kaydı bulunamadı',
        testConditions: '',
        maximumThrustPerMotorN: 0,
        totalMaximumThrustN: 0,
        maximumCurrentPerMotorA: 0,
        totalMaximumCurrentA: 0,
        maximumPowerPerMotorW: 0,
        totalMaximumPowerW: 0,
        testVoltageV: 0,
        thrustToWeight: 0,
        compatibilityScore: 0,
        compatibilityStatus: 'Uyumsuz',
        compatibilityMessage:
            'Seçilen motor-pervane kombinasyonu katalogda bulunamadı.',
        isCompatible: false,
      );
    }

    return _evaluateRealCombination(
      aircraft: aircraft,
      combination: combination,
    );
  }

  _ComponentAnalysisSnapshot _evaluateRealCombination({
    required Aircraft aircraft,
    required MotorPropellerCombination combination,
  }) {
    final issues = <String>[];
    var score = 100;
    var hasCriticalIssue = false;

    final selectedMotorId = aircraft.motorComponentId;
    if (selectedMotorId != null &&
        selectedMotorId.trim().isNotEmpty &&
        selectedMotorId != combination.motorComponentId) {
      score -= 35;
      hasCriticalIssue = true;
      issues.add('Motor kimliği test tablosuyla eşleşmiyor.');
    }

    final selectedPropellerId = aircraft.propellerComponentId;
    if (selectedPropellerId != null &&
        selectedPropellerId.trim().isNotEmpty &&
        selectedPropellerId != combination.propellerComponentId) {
      score -= 35;
      hasCriticalIssue = true;
      issues.add('Pervane kimliği test tablosuyla eşleşmiyor.');
    }

    final voltageToleranceV = aircraft.batteryVoltageV * 0.03 > 0.5
        ? aircraft.batteryVoltageV * 0.03
        : 0.5;

    final hasMatchingVoltage = combination.performancePoints.any(
      (point) =>
          (point.voltageV - aircraft.batteryVoltageV).abs() <=
          voltageToleranceV,
    );

    if (!hasMatchingVoltage) {
      score -= 20;
      issues.add('Batarya voltajı test tablosu voltajıyla eşleşmiyor.');
    }

    final totalMaximumPowerW =
        combination.maximumElectricalPowerW * aircraft.motorCount;

    if (aircraft.maximumMotorPowerW > totalMaximumPowerW * 1.10) {
      score -= 15;
      issues.add('Manuel maksimum güç, gerçek test tablosu değerinden yüksek.');
    }

    final catalogDiameterInch = _extractPropellerDiameter(
      combination.propellerComponentId,
    );

    if (catalogDiameterInch != null &&
        (catalogDiameterInch - aircraft.propellerDiameterInch).abs() > 0.25) {
      score -= 25;
      hasCriticalIssue = true;
      issues.add('Manuel pervane çapı seçilen test tablosuyla eşleşmiyor.');
    }

    score = score.clamp(0, 100);

    final totalMaximumThrustN =
        combination.maximumThrustN * aircraft.motorCount;
    final totalMaximumCurrentA =
        combination.maximumCurrentA * aircraft.motorCount;
    final weightN = aircraft.weightKg * 9.80665;
    final realThrustToWeight = weightN > 0
        ? totalMaximumThrustN / weightN
        : 0.0;

    final isCompatible = !hasCriticalIssue && score >= 60;
    final status = !isCompatible
        ? 'Uyumsuz'
        : issues.isEmpty
        ? 'Uyumlu'
        : 'Koşullu Uyumlu';

    final message = issues.isEmpty
        ? 'Seçilen motor-pervane tablosu araç girdileriyle uyumludur.'
        : issues.join(' ');

    return _ComponentAnalysisSnapshot(
      hasRealData: true,
      motorComponentId: combination.motorComponentId,
      propellerComponentId: combination.propellerComponentId,
      motorPropellerCombinationId: combination.id,
      dataSource: combination.dataSource,
      testConditions: combination.testConditions,
      maximumThrustPerMotorN: combination.maximumThrustN,
      totalMaximumThrustN: totalMaximumThrustN,
      maximumCurrentPerMotorA: combination.maximumCurrentA,
      totalMaximumCurrentA: totalMaximumCurrentA,
      maximumPowerPerMotorW: combination.maximumElectricalPowerW,
      totalMaximumPowerW: totalMaximumPowerW,
      testVoltageV: combination.maximumThrottlePoint.voltageV,
      thrustToWeight: realThrustToWeight,
      compatibilityScore: score,
      compatibilityStatus: status,
      compatibilityMessage: message,
      isCompatible: isCompatible,
    );
  }

  double? _extractPropellerDiameter(String propellerComponentId) {
    final match = RegExp(
      r'(?:^|-)p(\d+(?:\.\d+)?)x',
      caseSensitive: false,
    ).firstMatch(propellerComponentId);

    return double.tryParse(match?.group(1) ?? '');
  }
}

class _ComponentAnalysisSnapshot {
  final bool hasRealData;
  final String? motorComponentId;
  final String? propellerComponentId;
  final String? motorPropellerCombinationId;
  final String dataSource;
  final String testConditions;
  final double maximumThrustPerMotorN;
  final double totalMaximumThrustN;
  final double maximumCurrentPerMotorA;
  final double totalMaximumCurrentA;
  final double maximumPowerPerMotorW;
  final double totalMaximumPowerW;
  final double testVoltageV;
  final double thrustToWeight;
  final int compatibilityScore;
  final String compatibilityStatus;
  final String compatibilityMessage;
  final bool isCompatible;

  const _ComponentAnalysisSnapshot({
    required this.hasRealData,
    required this.motorComponentId,
    required this.propellerComponentId,
    required this.motorPropellerCombinationId,
    required this.dataSource,
    required this.testConditions,
    required this.maximumThrustPerMotorN,
    required this.totalMaximumThrustN,
    required this.maximumCurrentPerMotorA,
    required this.totalMaximumCurrentA,
    required this.maximumPowerPerMotorW,
    required this.totalMaximumPowerW,
    required this.testVoltageV,
    required this.thrustToWeight,
    required this.compatibilityScore,
    required this.compatibilityStatus,
    required this.compatibilityMessage,
    required this.isCompatible,
  });

  const _ComponentAnalysisSnapshot.manual()
    : hasRealData = false,
      motorComponentId = null,
      propellerComponentId = null,
      motorPropellerCombinationId = null,
      dataSource = 'Manuel giriş',
      testConditions = '',
      maximumThrustPerMotorN = 0,
      totalMaximumThrustN = 0,
      maximumCurrentPerMotorA = 0,
      totalMaximumCurrentA = 0,
      maximumPowerPerMotorW = 0,
      totalMaximumPowerW = 0,
      testVoltageV = 0,
      thrustToWeight = 0,
      compatibilityScore = 100,
      compatibilityStatus = 'Manuel Giriş',
      compatibilityMessage = 'Komponent veritabanı seçimi kullanılmadı.',
      isCompatible = true;
}
