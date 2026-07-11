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

  // Sprint 10A-2
  // Görev gücü ve enerji detayları.
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
