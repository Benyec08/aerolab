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

  // Sprint 10B
  // Gerçekçi seyir aerodinamiği sonuçları.
  final double cruiseSpeedMs;
  final double dynamicPressurePa;
  final double requiredLiftCoefficient;
  final double dragCoefficient;
  final double inducedDragFactor;
  final double liftToDragRatio;
  final double liftCoefficientUsageRatio;
  final bool isCruiseAerodynamicallyValid;

  // Sprint 11
  // Propulsion güç zinciri ve motor yük analizi sonuçları.

  /// Ortalama görev gücü altında ESC çıkışındaki elektriksel güç.
  final double escOutputPowerW;

  /// Ortalama görev gücü altında motor milindeki mekanik güç.
  final double motorShaftPowerW;

  /// Ortalama görev gücü altında pervaneye aktarılan faydalı güç.
  final double usefulPropulsivePowerW;

  /// ESC, motor ve pervane toplam verimi.
  ///
  /// Değer 0–1 aralığındadır.
  final double totalPropulsionEfficiency;

  /// Ortalama görev gücünün sürekli motor gücüne oranı.
  ///
  /// Değer 0–1 aralığında olabilir; limit aşımında 1’den büyük olabilir.
  final double averageContinuousLoadRatio;

  /// Peak görev gücünün maksimum motor gücüne oranı.
  ///
  /// Değer 0–1 aralığında olabilir; limit aşımında 1’den büyük olabilir.
  final double peakMaximumLoadRatio;

  /// Sürekli motor gücü ile ortalama görev gücü arasındaki rezerv.
  final double continuousPowerReserveW;

  /// Maksimum motor gücü ile peak görev gücü arasındaki rezerv.
  final double maximumPowerReserveW;

  final bool isPropulsionSystemSafe;
  final String propulsionSystemStatus;

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
