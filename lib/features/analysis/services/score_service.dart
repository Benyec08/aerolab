class ScoreService {
  int? aerodynamicScore({
    required bool isApplicable,
    required double wingLoading,
    required double stallSpeed,
    double densityAltitudeDifferenceM = 0.0,
    double densityDeviationPercent = 0.0,
    double temperatureDeviationC = 0.0,
    String atmosphereStatus = 'Normal Atmosfer',
    bool isAtmosphereWithinSupportedLimits = true,
    String windSafetyStatus = 'Güvenli - sakin hava',
    bool isWindWithinSupportedLimits = true,
    double headwindComponentMs = 0.0,
    double tailwindComponentMs = 0.0,
    double crosswindComponentMs = 0.0,
  }) {
    if (!isApplicable) {
      return null;
    }

    int score = 100;

    if (wingLoading > 8) {
      score -= 15;
    }

    if (wingLoading > 12) {
      score -= 20;
    }

    if (stallSpeed > 12) {
      score -= 20;
    }

    score -= _atmospherePenalty(
      densityAltitudeDifferenceM: densityAltitudeDifferenceM,
      densityDeviationPercent: densityDeviationPercent,
      temperatureDeviationC: temperatureDeviationC,
      atmosphereStatus: atmosphereStatus,
      isAtmosphereWithinSupportedLimits: isAtmosphereWithinSupportedLimits,
    );

    score -= _windPenalty(
      windSafetyStatus: windSafetyStatus,
      isWindWithinSupportedLimits: isWindWithinSupportedLimits,
      headwindComponentMs: headwindComponentMs,
      tailwindComponentMs: tailwindComponentMs,
      crosswindComponentMs: crosswindComponentMs,
    );

    return _clamp(score);
  }

  int propulsionScore({
    required double powerToWeight,
    required double thrustToWeight,
  }) {
    int score = 100;

    if (powerToWeight < 250) {
      score -= 25;
    }

    if (thrustToWeight < 1.2) {
      score -= 30;
    }

    if (thrustToWeight > 3.0) {
      score -= 10;
    }

    return _clamp(score);
  }

  int energyScore({required double flightTimeMinutes}) {
    int score = 100;

    if (flightTimeMinutes < 10) {
      score -= 30;
    }

    if (flightTimeMinutes < 5) {
      score -= 30;
    }

    return _clamp(score);
  }

  int overallScore({
    required int? aerodynamicScore,
    required int propulsionScore,
    required int energyScore,
  }) {
    final applicableScores = <int>[
      propulsionScore,
      energyScore,
      ?aerodynamicScore,
    ];

    final total = applicableScores.fold<int>(0, (sum, score) => sum + score);

    return (total / applicableScores.length).round();
  }

  int _atmospherePenalty({
    required double densityAltitudeDifferenceM,
    required double densityDeviationPercent,
    required double temperatureDeviationC,
    required String atmosphereStatus,
    required bool isAtmosphereWithinSupportedLimits,
  }) {
    int penalty = 0;

    if (!isAtmosphereWithinSupportedLimits) {
      penalty += 35;
    }

    if (densityAltitudeDifferenceM >= 1500) {
      penalty += 25;
    } else if (densityAltitudeDifferenceM >= 500) {
      penalty += 10;
    }

    if (densityDeviationPercent <= -15) {
      penalty += 20;
    } else if (densityDeviationPercent <= -7) {
      penalty += 10;
    }

    final absoluteTemperatureDeviation = temperatureDeviationC.abs();

    if (absoluteTemperatureDeviation >= 25) {
      penalty += 10;
    } else if (absoluteTemperatureDeviation >= 15) {
      penalty += 5;
    }

    final normalizedStatus = atmosphereStatus.toLowerCase();

    final hasCriticalStatus =
        normalizedStatus.contains('kritik') ||
        normalizedStatus.contains('yüksek risk');

    final hasMeasuredAtmospherePenalty =
        densityAltitudeDifferenceM >= 500 ||
        densityDeviationPercent <= -7 ||
        absoluteTemperatureDeviation >= 15;

    if (hasCriticalStatus && !hasMeasuredAtmospherePenalty) {
      penalty += 10;
    }

    return penalty;
  }

  int _windPenalty({
    required String windSafetyStatus,
    required bool isWindWithinSupportedLimits,
    required double headwindComponentMs,
    required double tailwindComponentMs,
    required double crosswindComponentMs,
  }) {
    int penalty = 0;

    if (!isWindWithinSupportedLimits) {
      penalty += 30;
    }

    if (tailwindComponentMs >= 8) {
      penalty += 20;
    } else if (tailwindComponentMs >= 4) {
      penalty += 10;
    }

    if (headwindComponentMs >= 10) {
      penalty += 10;
    } else if (headwindComponentMs >= 5) {
      penalty += 5;
    }

    if (crosswindComponentMs >= 8) {
      penalty += 20;
    } else if (crosswindComponentMs >= 4) {
      penalty += 10;
    }

    final normalizedStatus = windSafetyStatus.toLowerCase();

    final hasCriticalStatus =
        normalizedStatus.contains('kritik') ||
        normalizedStatus.contains('yüksek risk');

    final hasMeasuredWindPenalty =
        headwindComponentMs >= 5 ||
        tailwindComponentMs >= 4 ||
        crosswindComponentMs >= 4;

    if (hasCriticalStatus && !hasMeasuredWindPenalty) {
      penalty += 10;
    }

    return penalty;
  }

  int _clamp(int score) {
    if (score < 0) {
      return 0;
    }

    if (score > 100) {
      return 100;
    }

    return score;
  }
}
