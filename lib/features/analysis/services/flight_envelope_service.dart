import 'dart:math' as math;

import '../models/flight_envelope_result.dart';

class FlightEnvelopeService {
  static const double _minimumOperatingSpeedFactor = 1.20;

  const FlightEnvelopeService();

  FlightEnvelopeResult calculate({
    required double airDensityKgM3,
    required double stallSpeedMs,
    required double cruiseSpeedMs,
    required double maximumOperatingSpeedMs,
    required double positiveLimitLoadFactor,
    required double negativeLimitLoadFactor,
  }) {
    if (!_inputsAreValid(
      airDensityKgM3: airDensityKgM3,
      stallSpeedMs: stallSpeedMs,
      cruiseSpeedMs: cruiseSpeedMs,
      maximumOperatingSpeedMs: maximumOperatingSpeedMs,
      positiveLimitLoadFactor: positiveLimitLoadFactor,
      negativeLimitLoadFactor: negativeLimitLoadFactor,
    )) {
      return const FlightEnvelopeResult.notApplicable(
        message:
            'Uçuş zarfı hesabı için hava yoğunluğu, stall hızı, seyir '
            'hızı, maksimum işletme hızı ve limit yük faktörleri '
            'geçerli olmalıdır.',
      );
    }

    final minimumOperatingSpeedMs = stallSpeedMs * _minimumOperatingSpeedFactor;

    final maneuveringSpeedMs =
        stallSpeedMs * math.sqrt(positiveLimitLoadFactor);

    final maximumDynamicPressurePa =
        0.5 *
        airDensityKgM3 *
        maximumOperatingSpeedMs *
        maximumOperatingSpeedMs;

    final isCruiseInsideEnvelope =
        cruiseSpeedMs >= minimumOperatingSpeedMs &&
        cruiseSpeedMs <= maximumOperatingSpeedMs;

    final status = _buildStatus(
      isCruiseInsideEnvelope: isCruiseInsideEnvelope,
      cruiseSpeedMs: cruiseSpeedMs,
      minimumOperatingSpeedMs: minimumOperatingSpeedMs,
      maneuveringSpeedMs: maneuveringSpeedMs,
      maximumOperatingSpeedMs: maximumOperatingSpeedMs,
    );

    final message = _buildMessage(
      isCruiseInsideEnvelope: isCruiseInsideEnvelope,
      cruiseSpeedMs: cruiseSpeedMs,
      minimumOperatingSpeedMs: minimumOperatingSpeedMs,
      maneuveringSpeedMs: maneuveringSpeedMs,
      maximumOperatingSpeedMs: maximumOperatingSpeedMs,
    );

    return FlightEnvelopeResult(
      isApplicable: true,
      minimumOperatingSpeedMs: minimumOperatingSpeedMs,
      stallSpeedMs: stallSpeedMs,
      maneuveringSpeedMs: maneuveringSpeedMs,
      cruiseSpeedMs: cruiseSpeedMs,
      maximumOperatingSpeedMs: maximumOperatingSpeedMs,
      positiveLimitLoadFactor: positiveLimitLoadFactor,
      negativeLimitLoadFactor: negativeLimitLoadFactor,
      maximumDynamicPressurePa: maximumDynamicPressurePa,
      isCruiseInsideEnvelope: isCruiseInsideEnvelope,
      status: status,
      message: message,
    );
  }

  bool _inputsAreValid({
    required double airDensityKgM3,
    required double stallSpeedMs,
    required double cruiseSpeedMs,
    required double maximumOperatingSpeedMs,
    required double positiveLimitLoadFactor,
    required double negativeLimitLoadFactor,
  }) {
    return airDensityKgM3.isFinite &&
        stallSpeedMs.isFinite &&
        cruiseSpeedMs.isFinite &&
        maximumOperatingSpeedMs.isFinite &&
        positiveLimitLoadFactor.isFinite &&
        negativeLimitLoadFactor.isFinite &&
        airDensityKgM3 > 0.0 &&
        stallSpeedMs > 0.0 &&
        cruiseSpeedMs > 0.0 &&
        maximumOperatingSpeedMs > stallSpeedMs &&
        positiveLimitLoadFactor > 1.0 &&
        negativeLimitLoadFactor < 0.0;
  }

  String _buildStatus({
    required bool isCruiseInsideEnvelope,
    required double cruiseSpeedMs,
    required double minimumOperatingSpeedMs,
    required double maneuveringSpeedMs,
    required double maximumOperatingSpeedMs,
  }) {
    if (!isCruiseInsideEnvelope) {
      if (cruiseSpeedMs < minimumOperatingSpeedMs) {
        return 'Stall Marjı Yetersiz';
      }

      return 'Maksimum Hız Aşımı';
    }

    if (cruiseSpeedMs > maneuveringSpeedMs) {
      return 'Zarf İçinde — Manevra Kısıtlı';
    }

    if (cruiseSpeedMs >= maximumOperatingSpeedMs * 0.90) {
      return 'Zarf İçinde — Hız Limiti Yakın';
    }

    return 'Zarf İçinde';
  }

  String _buildMessage({
    required bool isCruiseInsideEnvelope,
    required double cruiseSpeedMs,
    required double minimumOperatingSpeedMs,
    required double maneuveringSpeedMs,
    required double maximumOperatingSpeedMs,
  }) {
    if (!isCruiseInsideEnvelope) {
      if (cruiseSpeedMs < minimumOperatingSpeedMs) {
        return 'Seyir hızı ${cruiseSpeedMs.toStringAsFixed(1)} m/s, '
            'önerilen minimum işletme hızı '
            '${minimumOperatingSpeedMs.toStringAsFixed(1)} m/s değerinin '
            'altındadır.';
      }

      return 'Seyir hızı ${cruiseSpeedMs.toStringAsFixed(1)} m/s, '
          'maksimum işletme hızı '
          '${maximumOperatingSpeedMs.toStringAsFixed(1)} m/s değerini '
          'aşmaktadır.';
    }

    if (cruiseSpeedMs > maneuveringSpeedMs) {
      return 'Seyir hızı uçuş zarfı içindedir ancak manevra hızı '
          '${maneuveringSpeedMs.toStringAsFixed(1)} m/s değerinin '
          'üzerindedir. Bu hızda tam kumanda girdileri limit yük '
          'faktörünün aşılmasına neden olabilir.';
    }

    return 'Seyir hızı ${cruiseSpeedMs.toStringAsFixed(1)} m/s, '
        '${minimumOperatingSpeedMs.toStringAsFixed(1)}–'
        '${maximumOperatingSpeedMs.toStringAsFixed(1)} m/s işletme '
        'aralığındadır ve manevra hızı sınırının altındadır.';
  }
}
