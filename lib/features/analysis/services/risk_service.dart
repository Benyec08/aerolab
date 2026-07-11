class RiskService {
  int calculateRiskScore({
    required double windSpeedKmh,
    required double thrustToWeight,
    required bool evaluateFixedWingAerodynamics,
    required double wingLoading,
    required double flightSpeedMs,
    required double stallSpeedMs,
  }) {
    int score = 100;

    if (windSpeedKmh > 20) {
      score -= 20;
    }

    if (thrustToWeight < 1.0) {
      score -= 30;
    }

    if (evaluateFixedWingAerodynamics) {
      if (wingLoading > 70) {
        score -= 20;
      }

      if (flightSpeedMs <= stallSpeedMs) {
        score -= 35;
      }
    }

    if (score < 0) {
      score = 0;
    }

    return score;
  }

  String getStatus(int riskScore) {
    if (riskScore >= 80) {
      return 'Güvenli';
    }

    if (riskScore >= 60) {
      return 'Dikkat';
    }

    return 'Riskli';
  }
}
