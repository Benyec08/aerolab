import 'dart:math' as math;

import '../models/climb_performance_result.dart';

class ClimbPerformanceService {
  static const double _gravityMs2 = 9.80665;
  static const double _metersPerSecondToFeetPerMinute = 196.850394;
  static const double _targetAltitudeM = 1000.0;

  const ClimbPerformanceService();

  ClimbPerformanceResult calculate({
    required double massKg,
    required double availablePropulsivePowerW,
    required double requiredLevelFlightPowerW,
    required double flightSpeedMs,
  }) {
    if (!_inputsAreValid(
      massKg: massKg,
      availablePropulsivePowerW: availablePropulsivePowerW,
      requiredLevelFlightPowerW: requiredLevelFlightPowerW,
      flightSpeedMs: flightSpeedMs,
    )) {
      return const ClimbPerformanceResult.notApplicable(
        message:
            'Tırmanma hesabı için kütle, güç ve uçuş hızı girdileri '
            'geçerli ve pozitif olmalıdır.',
      );
    }

    final weightN = massKg * _gravityMs2;
    final excessPowerW = availablePropulsivePowerW - requiredLevelFlightPowerW;

    final rateOfClimbMs = excessPowerW > 0.0 ? excessPowerW / weightN : 0.0;

    final rateOfClimbFpm = rateOfClimbMs * _metersPerSecondToFeetPerMinute;

    final climbAngleDeg = _calculateClimbAngleDeg(
      rateOfClimbMs: rateOfClimbMs,
      flightSpeedMs: flightSpeedMs,
    );

    final timeTo1000MMinutes = rateOfClimbMs > 0.0
        ? (_targetAltitudeM / rateOfClimbMs) / 60.0
        : 0.0;

    final status = _buildStatus(
      excessPowerW: excessPowerW,
      rateOfClimbMs: rateOfClimbMs,
    );

    final message = _buildMessage(
      excessPowerW: excessPowerW,
      rateOfClimbMs: rateOfClimbMs,
    );

    return ClimbPerformanceResult(
      isApplicable: true,
      availablePropulsivePowerW: availablePropulsivePowerW,
      requiredLevelFlightPowerW: requiredLevelFlightPowerW,
      excessPowerW: excessPowerW,
      rateOfClimbMs: rateOfClimbMs,
      rateOfClimbFpm: rateOfClimbFpm,
      climbAngleDeg: climbAngleDeg,
      timeTo1000MMinutes: timeTo1000MMinutes,
      status: status,
      message: message,
    );
  }

  bool _inputsAreValid({
    required double massKg,
    required double availablePropulsivePowerW,
    required double requiredLevelFlightPowerW,
    required double flightSpeedMs,
  }) {
    return massKg.isFinite &&
        availablePropulsivePowerW.isFinite &&
        requiredLevelFlightPowerW.isFinite &&
        flightSpeedMs.isFinite &&
        massKg > 0.0 &&
        availablePropulsivePowerW > 0.0 &&
        requiredLevelFlightPowerW >= 0.0 &&
        flightSpeedMs > 0.0;
  }

  double _calculateClimbAngleDeg({
    required double rateOfClimbMs,
    required double flightSpeedMs,
  }) {
    if (rateOfClimbMs <= 0.0) {
      return 0.0;
    }

    final ratio = (rateOfClimbMs / flightSpeedMs).clamp(0.0, 1.0);
    return math.asin(ratio) * 180.0 / math.pi;
  }

  String _buildStatus({
    required double excessPowerW,
    required double rateOfClimbMs,
  }) {
    if (excessPowerW <= 0.0 || rateOfClimbMs <= 0.0) {
      return 'Tırmanamaz';
    }

    if (rateOfClimbMs < 1.0) {
      return 'Düşük Tırmanma';
    }

    if (rateOfClimbMs < 3.0) {
      return 'Orta Tırmanma';
    }

    if (rateOfClimbMs < 6.0) {
      return 'İyi Tırmanma';
    }

    return 'Yüksek Tırmanma';
  }

  String _buildMessage({
    required double excessPowerW,
    required double rateOfClimbMs,
  }) {
    if (excessPowerW <= 0.0 || rateOfClimbMs <= 0.0) {
      return 'Kullanılabilir faydalı güç, düz uçuş için gereken gücü '
          'karşılamadığı için pozitif tırmanma mümkün değildir.';
    }

    return 'Pozitif fazla güç mevcut. Hesaplanan tırmanma oranı '
        '${rateOfClimbMs.toStringAsFixed(2)} m/s değerindedir.';
  }
}
