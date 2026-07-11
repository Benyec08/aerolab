class MotorEfficiencyService {
  static const double defaultEfficiency = 0.85;
  static const double minimumEfficiency = 0.50;
  static const double maximumEfficiency = 0.98;

  /// Elektriksel giriş gücünü mekanik şaft gücüne dönüştürür.
  ///
  /// P_shaft = P_electrical × η_motor
  ///
  /// [electricalPowerW] toplam elektriksel motor gücüdür.
  /// [efficiency] 0 ile 1 arasında boyutsuz verim katsayısıdır.
  double calculateShaftPowerW({
    required double electricalPowerW,
    double efficiency = defaultEfficiency,
  }) {
    _validatePower(electricalPowerW);
    _validateEfficiency(efficiency);

    return electricalPowerW * efficiency;
  }

  void _validatePower(double powerW) {
    if (!powerW.isFinite || powerW <= 0) {
      throw ArgumentError.value(
        powerW,
        'electricalPowerW',
        'Motor gücü sıfırdan büyük ve sonlu olmalıdır.',
      );
    }
  }

  void _validateEfficiency(double efficiency) {
    if (!efficiency.isFinite ||
        efficiency < minimumEfficiency ||
        efficiency > maximumEfficiency) {
      throw ArgumentError.value(
        efficiency,
        'efficiency',
        'Motor verimi $minimumEfficiency ile '
            '$maximumEfficiency arasında olmalıdır.',
      );
    }
  }
}
