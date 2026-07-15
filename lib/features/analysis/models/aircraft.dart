class Aircraft {
  final String name;
  final String type;
  final double weightKg;
  final double wingAreaM2;
  final double wingSpanM;
  final int motorCount;

  /// Toplam kurulu nominal motor gücü.
  ///
  /// Önceki sprintlerden gelen mevcut alan korunmaktadır.
  final double motorPowerW;

  final double propellerDiameterInch;
  final double batteryCapacityMah;
  final double batteryVoltageV;
  final String batteryType;
  final int batteryCellCount;

  // Sprint 12A
  //
  // Hücre başına iç direnç değeri mΩ cinsindedir.
  //
  // Örnek:
  // 4.0 mΩ / cell
  final double cellInternalResistanceMilliOhm;

  // Sprint 10B
  // Sabit kanat ve kanatlı VTOL araçları için aerodinamik girdiler.
  //
  // Drone araçlarında bu alanlar aerodinamik seyir analizinde kullanılmaz.
  final double cruiseSpeedMs;
  final double zeroLiftDragCoefficient;
  final double maxLiftCoefficient;
  final double oswaldEfficiencyFactor;

  // Sprint 11A
  //
  // Verim değerleri yüzde olarak değil, 0–1 aralığında saklanır.
  //
  // Örnek:
  // %95 ESC verimi   -> 0.95
  // %85 motor verimi -> 0.85
  final double escEfficiency;
  final double motorEfficiency;

  /// Motor sisteminin güvenli biçimde sürekli sağlayabildiği toplam güç.
  final double continuousMotorPowerW;

  /// Motor sisteminin kısa süreli sağlayabildiği toplam maksimum güç.
  final double maximumMotorPowerW;

  Aircraft({
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
    double? cellInternalResistanceMilliOhm,
    this.cruiseSpeedMs = 15.0,
    this.zeroLiftDragCoefficient = 0.030,
    this.maxLiftCoefficient = 1.4,
    this.oswaldEfficiencyFactor = 0.80,
    this.escEfficiency = 0.95,
    this.motorEfficiency = 0.85,
    double? continuousMotorPowerW,
    double? maximumMotorPowerW,
  }) : cellInternalResistanceMilliOhm =
           cellInternalResistanceMilliOhm ??
           _defaultCellInternalResistanceMilliOhm(batteryType),
       continuousMotorPowerW = continuousMotorPowerW ?? motorPowerW,
       maximumMotorPowerW = maximumMotorPowerW ?? motorPowerW;

  static double _defaultCellInternalResistanceMilliOhm(String batteryType) {
    final normalizedType = batteryType
        .trim()
        .toLowerCase()
        .replaceAll('-', '')
        .replaceAll(' ', '');

    switch (normalizedType) {
      case 'liion':
      case 'lion':
        return 18.0;

      case 'lihv':
        return 4.5;

      case 'lipo':
      default:
        return 4.0;
    }
  }
}
