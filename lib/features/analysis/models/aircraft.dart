class Aircraft {
  final String name;
  final String type;
  final double weightKg;
  final double wingAreaM2;
  final double wingSpanM;
  final int motorCount;
  final double motorPowerW;
  final double batteryCapacityMah;
  final double batteryVoltageV;

  const Aircraft({
    required this.name,
    required this.type,
    required this.weightKg,
    required this.wingAreaM2,
    required this.wingSpanM,
    required this.motorCount,
    required this.motorPowerW,
    required this.batteryCapacityMah,
    required this.batteryVoltageV,
  });
}