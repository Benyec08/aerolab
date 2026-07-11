class Aircraft {
  final String name;
  final String type;
  final double weightKg;
  final double wingAreaM2;
  final double wingSpanM;
  final int motorCount;
  final double motorPowerW;
  final double propellerDiameterInch;
  final double batteryCapacityMah;
  final double batteryVoltageV;
  final String batteryType;
  final int batteryCellCount;

  // Sprint 10B-1
  // Sabit kanat ve kanatlı VTOL araçları için aerodinamik girdiler.
  //
  // Drone araçlarında bu alanlar analiz sırasında kullanılmaz.
  final double cruiseSpeedMs;
  final double zeroLiftDragCoefficient;
  final double maxLiftCoefficient;
  final double oswaldEfficiencyFactor;

  const Aircraft({
    required this.name,
    required this.type,
    required this.weightKg,
    required this.wingAreaM2,
    required this.wingSpanM,
    required this.motorCount,
    required this.motorPowerW,
    required this.propellerDiameterInch,
    required this.batteryCapacityMah,
    required this.batteryVoltageV,
    required this.batteryType,
    required this.batteryCellCount,
    this.cruiseSpeedMs = 15.0,
    this.zeroLiftDragCoefficient = 0.030,
    this.maxLiftCoefficient = 1.4,
    this.oswaldEfficiencyFactor = 0.80,
  });
}
