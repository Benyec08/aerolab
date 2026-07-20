import 'dart:math' as math;

import '../models/glide_performance_result.dart';

class GlidePerformanceService {
  static const double _gravityMs2 = 9.80665;
  static const double _referenceAltitudeM = 1000.0;

  const GlidePerformanceService();

  GlidePerformanceResult calculate({
    required double massKg,
    required double airDensityKgM3,
    required double wingAreaM2,
    required double aspectRatio,
    required double zeroLiftDragCoefficient,
    required double oswaldEfficiencyFactor,
  }) {
    if (!_inputsAreValid(
      massKg: massKg,
      airDensityKgM3: airDensityKgM3,
      wingAreaM2: wingAreaM2,
      aspectRatio: aspectRatio,
      zeroLiftDragCoefficient: zeroLiftDragCoefficient,
      oswaldEfficiencyFactor: oswaldEfficiencyFactor,
    )) {
      return const GlidePerformanceResult.notApplicable(
        message:
            'Süzülme hesabı için kütle, hava yoğunluğu, kanat alanı, '
            'aspect ratio, CD0 ve Oswald verimi geçerli olmalıdır.',
      );
    }

    final weightN = massKg * _gravityMs2;

    final inducedDragFactor =
        1.0 / (math.pi * oswaldEfficiencyFactor * aspectRatio);

    final bestGlideRatio =
        1.0 / (2.0 * math.sqrt(zeroLiftDragCoefficient * inducedDragFactor));

    final bestGlideSpeedMs = math.sqrt(
      (2.0 * weightN / (airDensityKgM3 * wingAreaM2)) *
          math.sqrt(inducedDragFactor / zeroLiftDragCoefficient),
    );

    final bestGlideSpeedKmh = bestGlideSpeedMs * 3.6;

    final glideAngleRad = math.atan(1.0 / bestGlideRatio);
    final glideAngleDeg = glideAngleRad * 180.0 / math.pi;

    final sinkRateMs = bestGlideSpeedMs * math.sin(glideAngleRad);

    final glideDistanceFrom1000M = _referenceAltitudeM * bestGlideRatio;

    final glideTimeFrom1000MMinutes = sinkRateMs > 0.0
        ? (_referenceAltitudeM / sinkRateMs) / 60.0
        : 0.0;

    final status = _buildStatus(bestGlideRatio);
    final message = _buildMessage(
      bestGlideRatio: bestGlideRatio,
      bestGlideSpeedMs: bestGlideSpeedMs,
      glideDistanceFrom1000M: glideDistanceFrom1000M,
    );

    return GlidePerformanceResult(
      isApplicable: true,
      bestGlideRatio: bestGlideRatio,
      bestGlideSpeedMs: bestGlideSpeedMs,
      bestGlideSpeedKmh: bestGlideSpeedKmh,
      sinkRateMs: sinkRateMs,
      glideAngleDeg: glideAngleDeg,
      glideDistanceFrom1000M: glideDistanceFrom1000M,
      glideTimeFrom1000MMinutes: glideTimeFrom1000MMinutes,
      status: status,
      message: message,
    );
  }

  bool _inputsAreValid({
    required double massKg,
    required double airDensityKgM3,
    required double wingAreaM2,
    required double aspectRatio,
    required double zeroLiftDragCoefficient,
    required double oswaldEfficiencyFactor,
  }) {
    return massKg.isFinite &&
        airDensityKgM3.isFinite &&
        wingAreaM2.isFinite &&
        aspectRatio.isFinite &&
        zeroLiftDragCoefficient.isFinite &&
        oswaldEfficiencyFactor.isFinite &&
        massKg > 0.0 &&
        airDensityKgM3 > 0.0 &&
        wingAreaM2 > 0.0 &&
        aspectRatio > 0.0 &&
        zeroLiftDragCoefficient > 0.0 &&
        oswaldEfficiencyFactor > 0.0 &&
        oswaldEfficiencyFactor <= 1.0;
  }

  String _buildStatus(double bestGlideRatio) {
    if (bestGlideRatio < 5.0) {
      return 'Düşük';
    }

    if (bestGlideRatio < 8.0) {
      return 'Orta';
    }

    if (bestGlideRatio < 12.0) {
      return 'İyi';
    }

    return 'Yüksek';
  }

  String _buildMessage({
    required double bestGlideRatio,
    required double bestGlideSpeedMs,
    required double glideDistanceFrom1000M,
  }) {
    return 'En iyi süzülme oranı '
        '${bestGlideRatio.toStringAsFixed(1)}:1, '
        'en iyi süzülme hızı '
        '${bestGlideSpeedMs.toStringAsFixed(1)} m/s ve '
        '1000 m irtifadan teorik süzülme mesafesi '
        '${(glideDistanceFrom1000M / 1000.0).toStringAsFixed(1)} km '
        'olarak hesaplanmıştır.';
  }
}
