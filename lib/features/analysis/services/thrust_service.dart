import 'dart:math';

import 'motor_efficiency_service.dart';

class ThrustService {
  final MotorEfficiencyService _motorEfficiencyService;

  ThrustService({MotorEfficiencyService? motorEfficiencyService})
    : _motorEfficiencyService =
          motorEfficiencyService ?? MotorEfficiencyService();

  /// Statik itkiyi actuator-disk momentum teorisiyle tahmin eder.
  ///
  /// İdeal indüklenmiş güç bağıntısı:
  ///
  /// P = T^(3/2) / sqrt(2 × ρ × A)
  ///
  /// Buradan:
  ///
  /// T = [P × sqrt(2 × ρ × A)]^(2/3)
  ///
  /// [totalElectricalPowerW] tüm motor sisteminin toplam elektriksel gücüdür.
  /// [motorCount] toplam motor/pervane sayısıdır.
  /// [propellerDiameterInch] tek pervanenin çapıdır.
  /// [airDensityKgM3] ortam hava yoğunluğudur.
  ///
  /// Bu yöntem ideal momentum teorisine dayalı fiziksel bir tahmindir.
  /// Gerçek üretici thrust tabloları bulunduğunda tablo verisi tercih edilmelidir.
  double calculate({
    required double totalElectricalPowerW,
    required int motorCount,
    required double propellerDiameterInch,
    required double airDensityKgM3,
    double motorEfficiency = MotorEfficiencyService.defaultEfficiency,
    double staticFigureOfMerit = 0.72,
  }) {
    _validateInputs(
      totalElectricalPowerW: totalElectricalPowerW,
      motorCount: motorCount,
      propellerDiameterInch: propellerDiameterInch,
      airDensityKgM3: airDensityKgM3,
      staticFigureOfMerit: staticFigureOfMerit,
    );

    final shaftPowerW = _motorEfficiencyService.calculateShaftPowerW(
      electricalPowerW: totalElectricalPowerW,
      efficiency: motorEfficiency,
    );

    // İdeal olmayan gerçek pervane/rotor kayıplarını temsil eder.
    final effectiveInducedPowerW = shaftPowerW * staticFigureOfMerit;

    final diameterM = propellerDiameterInch * 0.0254;
    final radiusM = diameterM / 2.0;

    final singleDiskAreaM2 = pi * radiusM * radiusM;
    final totalDiskAreaM2 = singleDiskAreaM2 * motorCount;

    final momentumTerm =
        effectiveInducedPowerW * sqrt(2.0 * airDensityKgM3 * totalDiskAreaM2);

    return pow(momentumTerm, 2.0 / 3.0).toDouble();
  }

  double thrustToWeight({required double thrustN, required double weightKg}) {
    if (!thrustN.isFinite || thrustN < 0) {
      throw ArgumentError.value(
        thrustN,
        'thrustN',
        'İtki negatif olamaz ve sonlu olmalıdır.',
      );
    }

    if (!weightKg.isFinite || weightKg <= 0) {
      return 0;
    }

    const gravityMS2 = 9.80665;

    return thrustN / (weightKg * gravityMS2);
  }

  String evaluate(double ratio) {
    if (!ratio.isFinite || ratio < 0) {
      return 'Geçersiz';
    }

    if (ratio < 0.8) {
      return 'Yetersiz';
    }

    if (ratio < 1.2) {
      return 'Yeterli';
    }

    if (ratio < 2.0) {
      return 'İyi';
    }

    return 'Çok Güçlü';
  }

  void _validateInputs({
    required double totalElectricalPowerW,
    required int motorCount,
    required double propellerDiameterInch,
    required double airDensityKgM3,
    required double staticFigureOfMerit,
  }) {
    if (!totalElectricalPowerW.isFinite || totalElectricalPowerW <= 0) {
      throw ArgumentError.value(
        totalElectricalPowerW,
        'totalElectricalPowerW',
        'Toplam motor gücü sıfırdan büyük olmalıdır.',
      );
    }

    if (motorCount <= 0) {
      throw ArgumentError.value(
        motorCount,
        'motorCount',
        'Motor sayısı en az 1 olmalıdır.',
      );
    }

    if (!propellerDiameterInch.isFinite || propellerDiameterInch <= 0) {
      throw ArgumentError.value(
        propellerDiameterInch,
        'propellerDiameterInch',
        'Pervane çapı sıfırdan büyük olmalıdır.',
      );
    }

    if (!airDensityKgM3.isFinite || airDensityKgM3 <= 0) {
      throw ArgumentError.value(
        airDensityKgM3,
        'airDensityKgM3',
        'Hava yoğunluğu sıfırdan büyük olmalıdır.',
      );
    }

    if (!staticFigureOfMerit.isFinite ||
        staticFigureOfMerit <= 0 ||
        staticFigureOfMerit > 1) {
      throw ArgumentError.value(
        staticFigureOfMerit,
        'staticFigureOfMerit',
        'Statik figure of merit 0 ile 1 arasında olmalıdır.',
      );
    }
  }
}
