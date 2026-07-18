import '../models/wind_system_result.dart';

class WindSystemService {
  static const double _kilometersPerHourToMetersPerSecond = 1 / 3.6;
  static const double _minimumEffectiveAirspeedMs = 0.1;
  static const double _maximumSupportedWindSpeedKmh = 120.0;

  const WindSystemService();

  WindSystemResult calculate({
    required double windSpeedKmh,
    required String windDirection,
    required double commandedAirspeedMs,
  }) {
    _validateInputs(
      windSpeedKmh: windSpeedKmh,
      windDirection: windDirection,
      commandedAirspeedMs: commandedAirspeedMs,
    );

    final normalizedDirection = _normalizeDirection(windDirection);
    final effectiveWindSpeedKmh = normalizedDirection == 'Sakin'
        ? 0.0
        : windSpeedKmh;
    final windSpeedMs =
        effectiveWindSpeedKmh * _kilometersPerHourToMetersPerSecond;

    final components = _resolveWindComponents(
      windSpeedMs: windSpeedMs,
      windDirection: normalizedDirection,
    );

    final rawEffectiveAirspeedMs =
        commandedAirspeedMs + components.headwindMs - components.tailwindMs;
    final effectiveAirspeedMs = rawEffectiveAirspeedMs.clamp(
      _minimumEffectiveAirspeedMs,
      double.infinity,
    );

    final estimatedGroundSpeedMs =
        (commandedAirspeedMs - components.headwindMs + components.tailwindMs)
            .clamp(0.0, double.infinity);

    final windIntensityStatus = _classifyWindIntensity(effectiveWindSpeedKmh);
    final windSafetyStatus = _classifyWindSafety(
      windSpeedMs: windSpeedMs,
      commandedAirspeedMs: commandedAirspeedMs,
      headwindComponentMs: components.headwindMs,
      tailwindComponentMs: components.tailwindMs,
      crosswindComponentMs: components.crosswindMs,
      rawEffectiveAirspeedMs: rawEffectiveAirspeedMs,
    );

    final isWindWithinSupportedLimits =
        effectiveWindSpeedKmh <= _maximumSupportedWindSpeedKmh &&
        rawEffectiveAirspeedMs > 0.0;

    return WindSystemResult(
      windSpeedKmh: effectiveWindSpeedKmh,
      windSpeedMs: windSpeedMs,
      windDirection: normalizedDirection,
      headwindComponentMs: components.headwindMs,
      tailwindComponentMs: components.tailwindMs,
      crosswindComponentMs: components.crosswindMs,
      crosswindDirection: components.crosswindDirection,
      commandedAirspeedMs: commandedAirspeedMs,
      effectiveAirspeedMs: effectiveAirspeedMs,
      estimatedGroundSpeedMs: estimatedGroundSpeedMs,
      windIntensityStatus: windIntensityStatus,
      windSafetyStatus: windSafetyStatus,
      isWindWithinSupportedLimits: isWindWithinSupportedLimits,
    );
  }

  void _validateInputs({
    required double windSpeedKmh,
    required String windDirection,
    required double commandedAirspeedMs,
  }) {
    if (!windSpeedKmh.isFinite || windSpeedKmh < 0.0) {
      throw ArgumentError.value(
        windSpeedKmh,
        'windSpeedKmh',
        'Rüzgâr hızı sonlu ve sıfırdan büyük veya eşit olmalıdır.',
      );
    }

    if (!commandedAirspeedMs.isFinite || commandedAirspeedMs <= 0.0) {
      throw ArgumentError.value(
        commandedAirspeedMs,
        'commandedAirspeedMs',
        'Komutlanan hava hızı sonlu ve sıfırdan büyük olmalıdır.',
      );
    }

    final normalizedDirection = _normalizeDirection(windDirection);
    if (!_supportedDirections.contains(normalizedDirection)) {
      throw ArgumentError.value(
        windDirection,
        'windDirection',
        'Desteklenmeyen rüzgâr yönü.',
      );
    }
  }

  String _normalizeDirection(String direction) {
    final trimmedDirection = direction.trim();

    for (final supportedDirection in _supportedDirections) {
      if (supportedDirection.toLowerCase() == trimmedDirection.toLowerCase()) {
        return supportedDirection;
      }
    }

    return trimmedDirection;
  }

  _WindComponents _resolveWindComponents({
    required double windSpeedMs,
    required String windDirection,
  }) {
    switch (windDirection) {
      case 'Karşıdan':
        return _WindComponents(
          headwindMs: windSpeedMs,
          tailwindMs: 0.0,
          crosswindMs: 0.0,
          crosswindDirection: 'Yok',
        );
      case 'Arkadan':
        return _WindComponents(
          headwindMs: 0.0,
          tailwindMs: windSpeedMs,
          crosswindMs: 0.0,
          crosswindDirection: 'Yok',
        );
      case 'Soldan':
        return _WindComponents(
          headwindMs: 0.0,
          tailwindMs: 0.0,
          crosswindMs: windSpeedMs,
          crosswindDirection: 'Soldan',
        );
      case 'Sağdan':
        return _WindComponents(
          headwindMs: 0.0,
          tailwindMs: 0.0,
          crosswindMs: windSpeedMs,
          crosswindDirection: 'Sağdan',
        );
      case 'Sakin':
        return const _WindComponents(
          headwindMs: 0.0,
          tailwindMs: 0.0,
          crosswindMs: 0.0,
          crosswindDirection: 'Yok',
        );
      default:
        throw StateError('Rüzgâr yönü bileşenlere ayrılamadı.');
    }
  }

  String _classifyWindIntensity(double windSpeedKmh) {
    if (windSpeedKmh < 1.0) {
      return 'Sakin';
    }
    if (windSpeedKmh < 20.0) {
      return 'Hafif';
    }
    if (windSpeedKmh < 40.0) {
      return 'Orta';
    }
    if (windSpeedKmh < 65.0) {
      return 'Kuvvetli';
    }
    if (windSpeedKmh <= _maximumSupportedWindSpeedKmh) {
      return 'Çok kuvvetli';
    }
    return 'Desteklenen sınırın üzerinde';
  }

  String _classifyWindSafety({
    required double windSpeedMs,
    required double commandedAirspeedMs,
    required double headwindComponentMs,
    required double tailwindComponentMs,
    required double crosswindComponentMs,
    required double rawEffectiveAirspeedMs,
  }) {
    if (windSpeedMs == 0.0) {
      return 'Güvenli - sakin hava';
    }

    if (rawEffectiveAirspeedMs <= 0.0 ||
        windSpeedMs * 3.6 > _maximumSupportedWindSpeedKmh) {
      return 'Kritik - analiz sınırı aşıldı';
    }

    final totalWindRatio = windSpeedMs / commandedAirspeedMs;
    final crosswindRatio = crosswindComponentMs / commandedAirspeedMs;
    final tailwindRatio = tailwindComponentMs / commandedAirspeedMs;
    final headwindRatio = headwindComponentMs / commandedAirspeedMs;

    if (totalWindRatio >= 0.75 ||
        crosswindRatio >= 0.60 ||
        tailwindRatio >= 0.60 ||
        headwindRatio >= 0.90) {
      return 'Kritik';
    }

    if (totalWindRatio >= 0.50 ||
        crosswindRatio >= 0.40 ||
        tailwindRatio >= 0.40 ||
        headwindRatio >= 0.60) {
      return 'Yüksek risk';
    }

    if (totalWindRatio >= 0.25 ||
        crosswindRatio >= 0.20 ||
        tailwindRatio >= 0.20 ||
        headwindRatio >= 0.30) {
      return 'Dikkat';
    }

    return 'Güvenli';
  }

  static const Set<String> _supportedDirections = {
    'Karşıdan',
    'Arkadan',
    'Soldan',
    'Sağdan',
    'Sakin',
  };
}

class _WindComponents {
  final double headwindMs;
  final double tailwindMs;
  final double crosswindMs;
  final String crosswindDirection;

  const _WindComponents({
    required this.headwindMs,
    required this.tailwindMs,
    required this.crosswindMs,
    required this.crosswindDirection,
  });
}
