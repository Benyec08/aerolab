import 'dart:math';

class AerodynamicPerformanceService {
  static const double gravityMS2 = 9.80665;

  AerodynamicPerformanceResult calculateCruise({
    required double weightKg,
    required double airDensityKgM3,
    required double cruiseSpeedMs,
    required double wingAreaM2,
    required double aspectRatio,
    required double zeroLiftDragCoefficient,
    required double maxLiftCoefficient,
    required double oswaldEfficiencyFactor,
  }) {
    _validateInputs(
      weightKg: weightKg,
      airDensityKgM3: airDensityKgM3,
      cruiseSpeedMs: cruiseSpeedMs,
      wingAreaM2: wingAreaM2,
      aspectRatio: aspectRatio,
      zeroLiftDragCoefficient: zeroLiftDragCoefficient,
      maxLiftCoefficient: maxLiftCoefficient,
      oswaldEfficiencyFactor: oswaldEfficiencyFactor,
    );

    //--------------------------------------------------------------
    // Araç ağırlığı (Newton)
    //--------------------------------------------------------------

    final weightN = weightKg * gravityMS2;

    //--------------------------------------------------------------
    // Dinamik basınç
    //
    // q = 1/2 ρV²
    //--------------------------------------------------------------

    final dynamicPressurePa =
        0.5 * airDensityKgM3 * cruiseSpeedMs * cruiseSpeedMs;

    //--------------------------------------------------------------
    // Düz ve dengeli uçuşta:
    //
    // Lift = Weight
    //
    // CL = W / (qS)
    //--------------------------------------------------------------

    final requiredLiftCoefficient = weightN / (dynamicPressurePa * wingAreaM2);

    //--------------------------------------------------------------
    // İndüklenmiş sürükleme katsayısı
    //
    // k = 1 / (π e AR)
    //--------------------------------------------------------------

    final inducedDragFactor = 1.0 / (pi * oswaldEfficiencyFactor * aspectRatio);

    //--------------------------------------------------------------
    // Parabolik sürükleme poları
    //
    // CD = CD0 + kCL²
    //--------------------------------------------------------------

    final dragCoefficient =
        zeroLiftDragCoefficient +
        inducedDragFactor * requiredLiftCoefficient * requiredLiftCoefficient;

    //--------------------------------------------------------------
    // Lift
    //--------------------------------------------------------------

    final liftN = dynamicPressurePa * wingAreaM2 * requiredLiftCoefficient;

    //--------------------------------------------------------------
    // Drag
    //--------------------------------------------------------------

    final dragN = dynamicPressurePa * wingAreaM2 * dragCoefficient;

    //--------------------------------------------------------------
    // Lift / Drag
    //--------------------------------------------------------------

    final liftToDragRatio = dragCoefficient > 0
        ? requiredLiftCoefficient / dragCoefficient
        : 0.0;

    //--------------------------------------------------------------
    // CL kullanım oranı
    //--------------------------------------------------------------

    final stallMarginRatio = maxLiftCoefficient > 0
        ? requiredLiftCoefficient / maxLiftCoefficient
        : 0.0;

    return AerodynamicPerformanceResult(
      dynamicPressurePa: dynamicPressurePa,
      requiredLiftCoefficient: requiredLiftCoefficient,
      dragCoefficient: dragCoefficient,
      inducedDragFactor: inducedDragFactor,
      liftToDragRatio: liftToDragRatio,
      liftN: liftN,
      dragN: dragN,
      stallMarginRatio: stallMarginRatio,
      isBelowMaximumLiftCoefficient:
          requiredLiftCoefficient < maxLiftCoefficient,
    );
  }

  void _validateInputs({
    required double weightKg,
    required double airDensityKgM3,
    required double cruiseSpeedMs,
    required double wingAreaM2,
    required double aspectRatio,
    required double zeroLiftDragCoefficient,
    required double maxLiftCoefficient,
    required double oswaldEfficiencyFactor,
  }) {
    _validatePositive(weightKg, 'weightKg', 'Araç ağırlığı');
    _validatePositive(airDensityKgM3, 'airDensityKgM3', 'Hava yoğunluğu');
    _validatePositive(cruiseSpeedMs, 'cruiseSpeedMs', 'Seyir hızı');
    _validatePositive(wingAreaM2, 'wingAreaM2', 'Kanat alanı');
    _validatePositive(aspectRatio, 'aspectRatio', 'Aspect Ratio');
    _validatePositive(
      zeroLiftDragCoefficient,
      'zeroLiftDragCoefficient',
      'Sıfır kaldırma sürükleme katsayısı',
    );
    _validatePositive(
      maxLiftCoefficient,
      'maxLiftCoefficient',
      'Maksimum kaldırma katsayısı',
    );

    if (!oswaldEfficiencyFactor.isFinite ||
        oswaldEfficiencyFactor <= 0 ||
        oswaldEfficiencyFactor > 1) {
      throw ArgumentError.value(
        oswaldEfficiencyFactor,
        'oswaldEfficiencyFactor',
        'Oswald verim katsayısı 0 ile 1 arasında olmalıdır.',
      );
    }
  }

  void _validatePositive(
    double value,
    String parameterName,
    String description,
  ) {
    if (!value.isFinite || value <= 0) {
      throw ArgumentError.value(
        value,
        parameterName,
        '$description sıfırdan büyük olmalıdır.',
      );
    }
  }
}

class AerodynamicPerformanceResult {
  final double dynamicPressurePa;

  final double requiredLiftCoefficient;

  final double dragCoefficient;

  final double inducedDragFactor;

  final double liftToDragRatio;

  final double liftN;

  final double dragN;

  final double stallMarginRatio;

  final bool isBelowMaximumLiftCoefficient;

  const AerodynamicPerformanceResult({
    required this.dynamicPressurePa,
    required this.requiredLiftCoefficient,
    required this.dragCoefficient,
    required this.inducedDragFactor,
    required this.liftToDragRatio,
    required this.liftN,
    required this.dragN,
    required this.stallMarginRatio,
    required this.isBelowMaximumLiftCoefficient,
  });
}
