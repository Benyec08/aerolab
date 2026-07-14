/// Bataryadan pervaneye kadar propulsion güç zincirini analiz eder.
///
/// Güç akışı:
///
/// Battery Electrical Power
/// → ESC Output Power
/// → Motor Shaft Power
/// → Useful Propulsive Power
///
/// Verim değerleri yüzde olarak değil, 0–1 aralığında verilmelidir.
///
/// Örnek:
///
/// %95 ESC verimi   → 0.95
/// %88 motor verimi → 0.88
/// %72 pervane      → 0.72
class PropulsionPowerChainService {
  static const double defaultPropellerEfficiency = 0.72;

  PropulsionPowerChainResult calculate({
    required double batteryElectricalPowerW,
    required double escEfficiency,
    required double motorEfficiency,
    double propellerEfficiency = defaultPropellerEfficiency,
  }) {
    _validatePower(batteryElectricalPowerW);
    _validateEfficiency(value: escEfficiency, parameterName: 'escEfficiency');
    _validateEfficiency(
      value: motorEfficiency,
      parameterName: 'motorEfficiency',
    );
    _validateEfficiency(
      value: propellerEfficiency,
      parameterName: 'propellerEfficiency',
    );

    final escOutputPowerW = batteryElectricalPowerW * escEfficiency;

    final motorShaftPowerW = escOutputPowerW * motorEfficiency;

    final usefulPropulsivePowerW = motorShaftPowerW * propellerEfficiency;

    final escPowerLossW = batteryElectricalPowerW - escOutputPowerW;

    final motorPowerLossW = escOutputPowerW - motorShaftPowerW;

    final propellerPowerLossW = motorShaftPowerW - usefulPropulsivePowerW;

    final totalPowerLossW = batteryElectricalPowerW - usefulPropulsivePowerW;

    final totalPropulsionEfficiency =
        escEfficiency * motorEfficiency * propellerEfficiency;

    return PropulsionPowerChainResult(
      batteryElectricalPowerW: batteryElectricalPowerW,
      escEfficiency: escEfficiency,
      motorEfficiency: motorEfficiency,
      propellerEfficiency: propellerEfficiency,
      escOutputPowerW: escOutputPowerW,
      motorShaftPowerW: motorShaftPowerW,
      usefulPropulsivePowerW: usefulPropulsivePowerW,
      escPowerLossW: escPowerLossW,
      motorPowerLossW: motorPowerLossW,
      propellerPowerLossW: propellerPowerLossW,
      totalPowerLossW: totalPowerLossW,
      totalPropulsionEfficiency: totalPropulsionEfficiency,
    );
  }

  void _validatePower(double value) {
    if (!value.isFinite || value < 0) {
      throw ArgumentError.value(
        value,
        'batteryElectricalPowerW',
        'Batarya elektrik gücü sıfır veya pozitif olmalıdır.',
      );
    }
  }

  void _validateEfficiency({
    required double value,
    required String parameterName,
  }) {
    if (!value.isFinite || value <= 0 || value > 1) {
      throw ArgumentError.value(
        value,
        parameterName,
        'Verim değeri 0 ile 1 arasında olmalıdır.',
      );
    }
  }
}

class PropulsionPowerChainResult {
  /// Bataryadan çekilen elektriksel güç.
  final double batteryElectricalPowerW;

  final double escEfficiency;
  final double motorEfficiency;
  final double propellerEfficiency;

  /// ESC çıkışındaki elektriksel güç.
  final double escOutputPowerW;

  /// Motor milindeki mekanik güç.
  final double motorShaftPowerW;

  /// Pervanenin ürettiği faydalı propulsion gücü.
  final double usefulPropulsivePowerW;

  final double escPowerLossW;
  final double motorPowerLossW;
  final double propellerPowerLossW;
  final double totalPowerLossW;

  /// ESC × motor × pervane toplam verimi.
  ///
  /// Değer 0–1 aralığındadır.
  final double totalPropulsionEfficiency;

  const PropulsionPowerChainResult({
    required this.batteryElectricalPowerW,
    required this.escEfficiency,
    required this.motorEfficiency,
    required this.propellerEfficiency,
    required this.escOutputPowerW,
    required this.motorShaftPowerW,
    required this.usefulPropulsivePowerW,
    required this.escPowerLossW,
    required this.motorPowerLossW,
    required this.propellerPowerLossW,
    required this.totalPowerLossW,
    required this.totalPropulsionEfficiency,
  });
}
