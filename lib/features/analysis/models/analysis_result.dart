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
