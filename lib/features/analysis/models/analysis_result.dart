import 'climb_performance_result.dart';
import 'endurance_range_result.dart';
import 'glide_performance_result.dart';
import 'stability_result.dart';
import 'flight_envelope_result.dart';

class AnalysisResult {
  final String aircraftType;
  final bool hasFixedWingAerodynamics;

  final double liftN;
  final double dragN;
  final double wingLoading;
  final double stallSpeed;
  final double thrustToWeight;
  final double estimatedFlightTime;
  final double aspectRatio;
  final double powerToWeight;
  final double estimatedThrustN;

  // Sprint 10A
  final String missionPowerModelName;

  final double hoverPowerW;
  final double cruisePowerW;
  final double averageMissionPowerW;
  final double peakMissionPowerW;

  final double peakPowerUsageRatio;
  final double installedPowerReserveW;
  final double installedPowerReservePercent;
  final bool hasSufficientInstalledPower;

  final double averageBatteryCurrentA;
  final double nominalBatteryEnergyWh;
  final double usableBatteryEnergyWh;

  // Sprint 10B
  final double cruiseSpeedMs;
  final double dynamicPressurePa;
  final double requiredLiftCoefficient;
  final double dragCoefficient;
  final double inducedDragFactor;
  final double liftToDragRatio;
  final double liftCoefficientUsageRatio;
  final bool isCruiseAerodynamicallyValid;

  // Sprint 11
  final double escOutputPowerW;
  final double motorShaftPowerW;
  final double usefulPropulsivePowerW;
  final double totalPropulsionEfficiency;
  final double averageContinuousLoadRatio;
  final double peakMaximumLoadRatio;
  final double continuousPowerReserveW;
  final double maximumPowerReserveW;
  final bool isPropulsionSystemSafe;
  final String propulsionSystemStatus;

  // Sprint 12
  final double fullPackVoltageV;
  final double nominalPackVoltageV;
  final double minimumSafePackVoltageV;
  final double packInternalResistanceOhm;
  final double averageLoadedVoltageV;
  final double peakLoadedVoltageV;
  final double averageVoltageSagV;
  final double peakVoltageSagV;
  final double peakBatteryCurrentA;
  final double averageCRate;
  final double peakCRate;
  final double batteryLoadEfficiency;
  final bool isBatterySystemSafe;
  final String batterySystemStatus;

  // Sprint 12D
  final int batteryScore;
  final String batteryScoreStatus;
  final String batterySafetyMessage;
  final String batteryRecommendationTitle;
  final String batteryRecommendationMessage;
  final bool isBatteryRecommendationSafe;

  // Sprint 13A
  final double geometricAltitudeM;
  final double environmentTemperatureC;
  final double environmentPressureHpa;
  final double relativeHumidityPercent;
  final double isaTemperatureC;
  final double isaPressureHpa;
  final double isaDensityKgM3;
  final double temperatureDeviationC;
  final double pressureDeviationHpa;
  final double pressureDeviationPercent;
  final double densityDeviationKgM3;
  final double densityDeviationPercent;
  final double saturationVaporPressureHpa;
  final double vaporPressureHpa;
  final double dryAirPartialPressureHpa;
  final double humidAirDensityKgM3;
  final double densityAltitudeM;
  final double densityAltitudeDifferenceM;
  final String atmosphereStatus;
  final bool isAtmosphereWithinSupportedLimits;

  // Sprint 13B
  final double windSpeedKmh;
  final double windSpeedMs;
  final String windDirection;
  final double headwindComponentMs;
  final double tailwindComponentMs;
  final double crosswindComponentMs;
  final String crosswindDirection;
  final double commandedAirspeedMs;
  final double effectiveAirspeedMs;
  final double estimatedGroundSpeedMs;
  final String windIntensityStatus;
  final String windSafetyStatus;
  final bool isWindWithinSupportedLimits;

  // Sprint 14E
  //
  // Gerçek motor-pervane performans tablosunun araç analizine aktarılması.
  // Bu alanlar varsayılan değerlere sahip olduğu için manuel analiz akışı ve
  // eski AnalysisResult oluşturma noktaları geriye dönük olarak korunur.
  final bool usesComponentDatabase;
  final bool hasRealMotorPropellerData;
  final String? motorComponentId;
  final String? propellerComponentId;
  final String? motorPropellerCombinationId;
  final String componentDataSource;
  final String componentTestConditions;

  /// Seçilen test tablosundaki tek motor için maksimum itki.
  final double realTestMaximumThrustPerMotorN;

  /// Motor sayısı dikkate alınarak hesaplanan toplam maksimum gerçek itki.
  final double realTestTotalMaximumThrustN;

  final double realTestMaximumCurrentPerMotorA;
  final double realTestTotalMaximumCurrentA;
  final double realTestMaximumPowerPerMotorW;
  final double realTestTotalMaximumPowerW;
  final double realTestVoltageV;
  final double realTestThrustToWeight;

  /// Gerçek test tablosu ile manuel araç girdilerinin uyumluluk puanı.
  final int componentCompatibilityScore;
  final String componentCompatibilityStatus;
  final String componentCompatibilityMessage;
  final bool isComponentSelectionCompatible;

  // Sprint 15B
  // Fazla güç yöntemiyle hesaplanan tırmanma performansı.
  final ClimbPerformanceResult climbPerformance;

  // Sprint 15C
  // Enerji ve yer hızı üzerinden hesaplanan endurance ve menzil sonucu.
  final EnduranceRangeResult enduranceRange;

  // Sprint 15D
  // Parabolik sürükleme poları üzerinden hesaplanan süzülme performansı.
  final GlidePerformanceResult glidePerformance;

  // Sprint 15E
  // Bileşen ağırlıkları ve boylamsal moment kollarından hesaplanan
  // ağırlık merkezi ve statik marj sonucu.
  final StabilityResult stability;

  // Sprint 15F
  // Stall, manevra ve maksimum işletme sınırlarını içeren uçuş zarfı.
  final FlightEnvelopeResult flightEnvelope;

  final String wingLoadingStatus;
  final String powerToWeightStatus;
  final String thrustToWeightStatus;

  final int? aerodynamicScore;
  final int propulsionScore;
  final int energyScore;
  final int overallScore;

  final int riskScore;
  final String status;
  final String recommendation;

  const AnalysisResult({
    required this.aircraftType,
    required this.hasFixedWingAerodynamics,
    required this.liftN,
    required this.dragN,
    required this.wingLoading,
    required this.stallSpeed,
    required this.thrustToWeight,
    required this.estimatedFlightTime,
    required this.aspectRatio,
    required this.powerToWeight,
    required this.estimatedThrustN,
    required this.missionPowerModelName,
    required this.hoverPowerW,
    required this.cruisePowerW,
    required this.averageMissionPowerW,
    required this.peakMissionPowerW,
    required this.peakPowerUsageRatio,
    required this.installedPowerReserveW,
    required this.installedPowerReservePercent,
    required this.hasSufficientInstalledPower,
    required this.averageBatteryCurrentA,
    required this.nominalBatteryEnergyWh,
    required this.usableBatteryEnergyWh,
    required this.cruiseSpeedMs,
    required this.dynamicPressurePa,
    required this.requiredLiftCoefficient,
    required this.dragCoefficient,
    required this.inducedDragFactor,
    required this.liftToDragRatio,
    required this.liftCoefficientUsageRatio,
    required this.isCruiseAerodynamicallyValid,
    required this.escOutputPowerW,
    required this.motorShaftPowerW,
    required this.usefulPropulsivePowerW,
    required this.totalPropulsionEfficiency,
    required this.averageContinuousLoadRatio,
    required this.peakMaximumLoadRatio,
    required this.continuousPowerReserveW,
    required this.maximumPowerReserveW,
    required this.isPropulsionSystemSafe,
    required this.propulsionSystemStatus,
    required this.fullPackVoltageV,
    required this.nominalPackVoltageV,
    required this.minimumSafePackVoltageV,
    required this.packInternalResistanceOhm,
    required this.averageLoadedVoltageV,
    required this.peakLoadedVoltageV,
    required this.averageVoltageSagV,
    required this.peakVoltageSagV,
    required this.peakBatteryCurrentA,
    required this.averageCRate,
    required this.peakCRate,
    required this.batteryLoadEfficiency,
    required this.isBatterySystemSafe,
    required this.batterySystemStatus,
    required this.batteryScore,
    required this.batteryScoreStatus,
    required this.batterySafetyMessage,
    required this.batteryRecommendationTitle,
    required this.batteryRecommendationMessage,
    required this.isBatteryRecommendationSafe,
    required this.geometricAltitudeM,
    required this.environmentTemperatureC,
    required this.environmentPressureHpa,
    required this.relativeHumidityPercent,
    required this.isaTemperatureC,
    required this.isaPressureHpa,
    required this.isaDensityKgM3,
    required this.temperatureDeviationC,
    required this.pressureDeviationHpa,
    required this.pressureDeviationPercent,
    required this.densityDeviationKgM3,
    required this.densityDeviationPercent,
    required this.saturationVaporPressureHpa,
    required this.vaporPressureHpa,
    required this.dryAirPartialPressureHpa,
    required this.humidAirDensityKgM3,
    required this.densityAltitudeM,
    required this.densityAltitudeDifferenceM,
    required this.atmosphereStatus,
    required this.isAtmosphereWithinSupportedLimits,
    this.windSpeedKmh = 0.0,
    this.windSpeedMs = 0.0,
    this.windDirection = 'Sakin',
    this.headwindComponentMs = 0.0,
    this.tailwindComponentMs = 0.0,
    this.crosswindComponentMs = 0.0,
    this.crosswindDirection = 'Yok',
    this.commandedAirspeedMs = 0.0,
    this.effectiveAirspeedMs = 0.0,
    this.estimatedGroundSpeedMs = 0.0,
    this.windIntensityStatus = 'Sakin',
    this.windSafetyStatus = 'Güvenli - sakin hava',
    this.isWindWithinSupportedLimits = true,
    this.usesComponentDatabase = false,
    this.hasRealMotorPropellerData = false,
    this.motorComponentId,
    this.propellerComponentId,
    this.motorPropellerCombinationId,
    this.componentDataSource = 'Manuel giriş',
    this.componentTestConditions = '',
    this.realTestMaximumThrustPerMotorN = 0.0,
    this.realTestTotalMaximumThrustN = 0.0,
    this.realTestMaximumCurrentPerMotorA = 0.0,
    this.realTestTotalMaximumCurrentA = 0.0,
    this.realTestMaximumPowerPerMotorW = 0.0,
    this.realTestTotalMaximumPowerW = 0.0,
    this.realTestVoltageV = 0.0,
    this.realTestThrustToWeight = 0.0,
    this.componentCompatibilityScore = 100,
    this.componentCompatibilityStatus = 'Manuel Giriş',
    this.componentCompatibilityMessage =
        'Komponent veritabanı seçimi kullanılmadı.',
    this.isComponentSelectionCompatible = true,
    this.climbPerformance = const ClimbPerformanceResult.notApplicable(),
    this.enduranceRange = const EnduranceRangeResult.notApplicable(),
    this.glidePerformance = const GlidePerformanceResult.notApplicable(),
    this.stability = const StabilityResult.notApplicable(),
    this.flightEnvelope = const FlightEnvelopeResult.notApplicable(),
    required this.wingLoadingStatus,
    required this.powerToWeightStatus,
    required this.thrustToWeightStatus,
    required this.aerodynamicScore,
    required this.propulsionScore,
    required this.energyScore,
    required this.overallScore,
    required this.riskScore,
    required this.status,
    required this.recommendation,
  });
}
