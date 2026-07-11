import 'dart:math';

import '../models/aircraft.dart';

/// Uçuş görevi boyunca ihtiyaç duyulan elektriksel gücü araç tipine göre
/// hesaplayan mühendislik servisidir.
///
/// Desteklenen modeller:
///
/// - Drone: rotor hover gücü ve ileri uçuş görev profili
/// - Sabit Kanat: sürükleme × hız temelli seyir gücü
/// - VTOL: dikey uçuş ve sabit kanat seyir gücünün birleşimi
class MissionPowerService {
  static const double gravityMS2 = 9.80665;

  static const double defaultMotorEfficiency = 0.85;
  static const double defaultPropellerEfficiency = 0.72;
  static const double defaultRotorFigureOfMerit = 0.72;

  /// Araç tipine göre uygun görev güç modelini seçer.
  MissionPowerResult calculate({
    required Aircraft aircraft,
    required double airDensityKgM3,
    required double flightSpeedMs,
    required double dragN,
    double motorEfficiency = defaultMotorEfficiency,
    double propellerEfficiency = defaultPropellerEfficiency,
    double rotorFigureOfMerit = defaultRotorFigureOfMerit,
  }) {
    _validateCommonInputs(
      aircraft: aircraft,
      airDensityKgM3: airDensityKgM3,
      flightSpeedMs: flightSpeedMs,
      dragN: dragN,
      motorEfficiency: motorEfficiency,
      propellerEfficiency: propellerEfficiency,
      rotorFigureOfMerit: rotorFigureOfMerit,
    );

    switch (aircraft.type) {
      case 'Drone':
        return _calculateDrone(
          aircraft: aircraft,
          airDensityKgM3: airDensityKgM3,
          motorEfficiency: motorEfficiency,
          rotorFigureOfMerit: rotorFigureOfMerit,
        );

      case 'Sabit Kanat':
        return _calculateFixedWing(
          aircraft: aircraft,
          dragN: dragN,
          flightSpeedMs: flightSpeedMs,
          motorEfficiency: motorEfficiency,
          propellerEfficiency: propellerEfficiency,
        );

      case 'VTOL':
        return _calculateVtol(
          aircraft: aircraft,
          airDensityKgM3: airDensityKgM3,
          dragN: dragN,
          flightSpeedMs: flightSpeedMs,
          motorEfficiency: motorEfficiency,
          propellerEfficiency: propellerEfficiency,
          rotorFigureOfMerit: rotorFigureOfMerit,
        );

      default:
        throw ArgumentError.value(
          aircraft.type,
          'aircraft.type',
          'Desteklenmeyen araç tipi.',
        );
    }
  }

  MissionPowerResult _calculateDrone({
    required Aircraft aircraft,
    required double airDensityKgM3,
    required double motorEfficiency,
    required double rotorFigureOfMerit,
  }) {
    final hoverPowerW = _calculateHoverElectricalPower(
      weightKg: aircraft.weightKg,
      motorCount: aircraft.motorCount,
      propellerDiameterInch: aircraft.propellerDiameterInch,
      airDensityKgM3: airDensityKgM3,
      motorEfficiency: motorEfficiency,
      rotorFigureOfMerit: rotorFigureOfMerit,
    );

    // Drone görev profili:
    //
    // %10 kalkış / tırmanış
    // %75 hover / ileri uçuş
    // %15 alçalma / iniş
    //
    // Güç katsayıları hover gücüne göre tanımlanmıştır.
    const takeoffFraction = 0.10;
    const cruiseFraction = 0.75;
    const landingFraction = 0.15;

    final takeoffPowerW = hoverPowerW * 1.20;
    final cruisePowerW = hoverPowerW * 1.08;
    final landingPowerW = hoverPowerW * 0.80;

    final averageMissionPowerW =
        (takeoffPowerW * takeoffFraction) +
        (cruisePowerW * cruiseFraction) +
        (landingPowerW * landingFraction);

    final peakMissionPowerW = takeoffPowerW;

    return _buildResult(
      modelName: 'Multikopter Hover Görev Modeli',
      installedPowerW: aircraft.motorPowerW,
      hoverPowerW: hoverPowerW,
      cruisePowerW: cruisePowerW,
      averageMissionPowerW: averageMissionPowerW,
      peakMissionPowerW: peakMissionPowerW,
    );
  }

  MissionPowerResult _calculateFixedWing({
    required Aircraft aircraft,
    required double dragN,
    required double flightSpeedMs,
    required double motorEfficiency,
    required double propellerEfficiency,
  }) {
    final cruisePowerW = _calculateFixedWingElectricalPower(
      dragN: dragN,
      flightSpeedMs: flightSpeedMs,
      motorEfficiency: motorEfficiency,
      propellerEfficiency: propellerEfficiency,
    );

    // Sabit kanat görev profili:
    //
    // %15 kalkış / tırmanış
    // %70 seyir
    // %10 loiter
    // %5 yaklaşma / iniş
    const climbFraction = 0.15;
    const cruiseFraction = 0.70;
    const loiterFraction = 0.10;
    const landingFraction = 0.05;

    final climbPowerW = cruisePowerW * 1.65;
    final loiterPowerW = cruisePowerW * 0.85;
    final landingPowerW = cruisePowerW * 0.55;

    final averageMissionPowerW =
        (climbPowerW * climbFraction) +
        (cruisePowerW * cruiseFraction) +
        (loiterPowerW * loiterFraction) +
        (landingPowerW * landingFraction);

    final peakMissionPowerW = climbPowerW;

    return _buildResult(
      modelName: 'Sabit Kanat Seyir Görev Modeli',
      installedPowerW: aircraft.motorPowerW,
      hoverPowerW: 0,
      cruisePowerW: cruisePowerW,
      averageMissionPowerW: averageMissionPowerW,
      peakMissionPowerW: peakMissionPowerW,
    );
  }

  MissionPowerResult _calculateVtol({
    required Aircraft aircraft,
    required double airDensityKgM3,
    required double dragN,
    required double flightSpeedMs,
    required double motorEfficiency,
    required double propellerEfficiency,
    required double rotorFigureOfMerit,
  }) {
    final hoverPowerW = _calculateHoverElectricalPower(
      weightKg: aircraft.weightKg,
      motorCount: aircraft.motorCount,
      propellerDiameterInch: aircraft.propellerDiameterInch,
      airDensityKgM3: airDensityKgM3,
      motorEfficiency: motorEfficiency,
      rotorFigureOfMerit: rotorFigureOfMerit,
    );

    final cruisePowerW = dragN > 0
        ? _calculateFixedWingElectricalPower(
            dragN: dragN,
            flightSpeedMs: flightSpeedMs,
            motorEfficiency: motorEfficiency,
            propellerEfficiency: propellerEfficiency,
          )
        : hoverPowerW * 0.75;

    // VTOL görev profili:
    //
    // %10 dikey kalkış
    // %10 geçiş
    // %65 kanatlı seyir
    // %5 geri geçiş
    // %10 dikey iniş
    const verticalTakeoffFraction = 0.10;
    const transitionFraction = 0.10;
    const cruiseFraction = 0.65;
    const returnTransitionFraction = 0.05;
    const verticalLandingFraction = 0.10;

    final verticalTakeoffPowerW = hoverPowerW * 1.20;
    final transitionPowerW = max(hoverPowerW, cruisePowerW) * 1.10;
    final returnTransitionPowerW = max(hoverPowerW, cruisePowerW);
    final verticalLandingPowerW = hoverPowerW * 0.80;

    final averageMissionPowerW =
        (verticalTakeoffPowerW * verticalTakeoffFraction) +
        (transitionPowerW * transitionFraction) +
        (cruisePowerW * cruiseFraction) +
        (returnTransitionPowerW * returnTransitionFraction) +
        (verticalLandingPowerW * verticalLandingFraction);

    final peakMissionPowerW = max(verticalTakeoffPowerW, transitionPowerW);

    return _buildResult(
      modelName: 'VTOL Karma Görev Modeli',
      installedPowerW: aircraft.motorPowerW,
      hoverPowerW: hoverPowerW,
      cruisePowerW: cruisePowerW,
      averageMissionPowerW: averageMissionPowerW,
      peakMissionPowerW: peakMissionPowerW,
    );
  }

  /// Momentum teorisine göre hover için gerekli elektriksel gücü hesaplar.
  ///
  /// P_ideal = T^(3/2) / sqrt(2 × rho × A)
  ///
  /// P_electrical =
  /// P_ideal / (motorEfficiency × rotorFigureOfMerit)
  double _calculateHoverElectricalPower({
    required double weightKg,
    required int motorCount,
    required double propellerDiameterInch,
    required double airDensityKgM3,
    required double motorEfficiency,
    required double rotorFigureOfMerit,
  }) {
    final requiredThrustN = weightKg * gravityMS2;

    final diameterM = propellerDiameterInch * 0.0254;
    final radiusM = diameterM / 2.0;

    final singleRotorDiskAreaM2 = pi * radiusM * radiusM;
    final totalRotorDiskAreaM2 = singleRotorDiskAreaM2 * motorCount;

    final idealHoverPowerW =
        pow(requiredThrustN, 1.5).toDouble() /
        sqrt(2.0 * airDensityKgM3 * totalRotorDiskAreaM2);

    return idealHoverPowerW / (motorEfficiency * rotorFigureOfMerit);
  }

  /// Sabit kanatlı uçuşta sürüklemeyi yenmek için gerekli elektriksel gücü
  /// hesaplar.
  ///
  /// P_aerodynamic = Drag × Velocity
  ///
  /// P_electrical =
  /// P_aerodynamic / (motorEfficiency × propellerEfficiency)
  double _calculateFixedWingElectricalPower({
    required double dragN,
    required double flightSpeedMs,
    required double motorEfficiency,
    required double propellerEfficiency,
  }) {
    final aerodynamicPowerW = dragN * flightSpeedMs;

    return aerodynamicPowerW / (motorEfficiency * propellerEfficiency);
  }

  MissionPowerResult _buildResult({
    required String modelName,
    required double installedPowerW,
    required double hoverPowerW,
    required double cruisePowerW,
    required double averageMissionPowerW,
    required double peakMissionPowerW,
  }) {
    final peakPowerUsageRatio = peakMissionPowerW / installedPowerW;

    final installedPowerReserveW = installedPowerW - peakMissionPowerW;

    final installedPowerReservePercent =
        (installedPowerReserveW / installedPowerW) * 100.0;

    return MissionPowerResult(
      modelName: modelName,
      hoverPowerW: hoverPowerW,
      cruisePowerW: cruisePowerW,
      averageMissionPowerW: averageMissionPowerW,
      peakMissionPowerW: peakMissionPowerW,
      peakPowerUsageRatio: peakPowerUsageRatio,
      installedPowerReserveW: installedPowerReserveW,
      installedPowerReservePercent: installedPowerReservePercent,
      hasSufficientInstalledPower: installedPowerReserveW >= 0,
    );
  }

  void _validateCommonInputs({
    required Aircraft aircraft,
    required double airDensityKgM3,
    required double flightSpeedMs,
    required double dragN,
    required double motorEfficiency,
    required double propellerEfficiency,
    required double rotorFigureOfMerit,
  }) {
    if (!aircraft.weightKg.isFinite || aircraft.weightKg <= 0) {
      throw ArgumentError.value(
        aircraft.weightKg,
        'aircraft.weightKg',
        'Araç ağırlığı sıfırdan büyük olmalıdır.',
      );
    }

    if (aircraft.motorCount <= 0) {
      throw ArgumentError.value(
        aircraft.motorCount,
        'aircraft.motorCount',
        'Motor sayısı en az 1 olmalıdır.',
      );
    }

    if (!aircraft.motorPowerW.isFinite || aircraft.motorPowerW <= 0) {
      throw ArgumentError.value(
        aircraft.motorPowerW,
        'aircraft.motorPowerW',
        'Kurulu motor gücü sıfırdan büyük olmalıdır.',
      );
    }

    if (!aircraft.propellerDiameterInch.isFinite ||
        aircraft.propellerDiameterInch <= 0) {
      throw ArgumentError.value(
        aircraft.propellerDiameterInch,
        'aircraft.propellerDiameterInch',
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

    if (!flightSpeedMs.isFinite || flightSpeedMs <= 0) {
      throw ArgumentError.value(
        flightSpeedMs,
        'flightSpeedMs',
        'Uçuş hızı sıfırdan büyük olmalıdır.',
      );
    }

    if (!dragN.isFinite || dragN < 0) {
      throw ArgumentError.value(
        dragN,
        'dragN',
        'Sürükleme kuvveti negatif olamaz.',
      );
    }

    _validateEfficiency(motorEfficiency, 'motorEfficiency', 'Motor verimi');

    _validateEfficiency(
      propellerEfficiency,
      'propellerEfficiency',
      'Pervane verimi',
    );

    _validateEfficiency(
      rotorFigureOfMerit,
      'rotorFigureOfMerit',
      'Rotor figure of merit',
    );
  }

  void _validateEfficiency(
    double value,
    String parameterName,
    String description,
  ) {
    if (!value.isFinite || value <= 0 || value > 1) {
      throw ArgumentError.value(
        value,
        parameterName,
        '$description 0 ile 1 arasında olmalıdır.',
      );
    }
  }
}

/// Görev güç hesabının detaylı sonucudur.
class MissionPowerResult {
  final String modelName;

  final double hoverPowerW;
  final double cruisePowerW;

  final double averageMissionPowerW;
  final double peakMissionPowerW;

  final double peakPowerUsageRatio;

  final double installedPowerReserveW;
  final double installedPowerReservePercent;

  final bool hasSufficientInstalledPower;

  const MissionPowerResult({
    required this.modelName,
    required this.hoverPowerW,
    required this.cruisePowerW,
    required this.averageMissionPowerW,
    required this.peakMissionPowerW,
    required this.peakPowerUsageRatio,
    required this.installedPowerReserveW,
    required this.installedPowerReservePercent,
    required this.hasSufficientInstalledPower,
  });
}
