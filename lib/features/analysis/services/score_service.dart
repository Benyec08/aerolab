class ScoreService {
  int? aerodynamicScore({
    required bool isApplicable,
    required double wingLoading,
    required double stallSpeed,
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
