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
  });
}
